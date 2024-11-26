## Create a resource group
resource "azurerm_resource_group" "tf-rg" {
  name     = "tf-rg"
  location = var.region.location
}

## Create a virtual machine
resource "azurerm_linux_virtual_machine" "tf-vm" {
  for_each                        = var.vm_info
  name                            = "tf-vm"
  resource_group_name             = azurerm_resource_group.tf-rg.name
  location                        = var.region.location
  size                            = each.value.size
  admin_username                  = each.value.username
  # admin_password                  = each.value.password
  network_interface_ids           = [azurerm_network_interface.tf-nic[0].id]
  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
  # depends_on = [azurerm_network_interface.tf-nic]

  admin_ssh_key {
    username   = each.value.username
    public_key = file("~/.ssh/id_rsa.pub")
  }
}
# Null resource for provisioning
resource "null_resource" "nginx_setup" {
  for_each = azurerm_linux_virtual_machine.tf-vm

  # Common connection configuration
  connection {
    type        = "ssh"
    user        = each.value.admin_username
    host        = azurerm_public_ip.tf-Pub[0].ip_address
    private_key = file("~/.ssh/id_rsa")
    # password = each.value.admin_password
  }

# Provisioners to copy necessary files to the VM
provisioner "file" {
  source      = "./deploy.sh"  # Path to your shell script
  destination = "/tmp/deploy.sh"  # Destination path on the VM
}

# Combined remote-exec provisioner to run everything
provisioner "remote-exec" {
  inline = [
    # Create the node-hello directory first
    "echo 'Creating the node-hello directory...'",
    "mkdir -p /home/$VM_USERNAME/node-hello",  # Ensure the directory exists

    # Execute deploy.sh script first
    "echo 'Running deploy script...'",
    "sudo chmod +x /tmp/deploy.sh",
    "bash /tmp/deploy.sh",  # Execute the deploy script

    # Sync application files to the VM using rsync over SSH
    "echo 'Syncing application files to the VM...'",
    "rsync -avz -e 'ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa' ./ $VM_USERNAME@$VM_IP:/home/$VM_USERNAME/node-hello",

    # Deploy the application using npm and pm2
    "echo 'Installing node modules...'",
    "cd /home/$VM_USERNAME/node-hello && npm install",  # Install node modules
    "echo 'Installing PM2 globally...'",
    "sudo npm install -g pm2",  # Install PM2 globally
    "echo 'Checking if app is already running...'",
    "if pm2 show 'app' > /dev/null; then",
    "  echo 'App is already running. Restarting...'",
    "  pm2 restart 'app'",  # Restart the app if already running
    "else",
    "  echo 'App is not running. Starting the app...'",
    "  pm2 start npm --name 'app' -- start",  # Start the app with PM2
    "fi",
    "echo 'Saving PM2 process list...'",
    "pm2 save",  # Save the PM2 process list

    # Finally, execute the https.sh script for SSL configuration
    "echo 'Running SSL setup...'",
    "sudo chmod +x /home/$VM_USERNAME/node-hello/https.sh",  # Ensure the https.sh script is executable
    "bash /home/$VM_USERNAME/node-hello/https.sh"  # Execute the https.sh script
  ]
}

  # Use triggers to ensure it runs when necessary
  triggers = {
    always_run = "${timestamp()}"  # Forces re-execution
  }
}

