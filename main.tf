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

  provisioner "file" {
    source      = "./deploy.sh"  # Path to your shell script
    destination = "/tmp/deploy.sh"  # Destination path on the VM
  }
  provisioner "file" {
    source      = "./ssl.sh"  # Path to your shell script
    destination = "/home/$VM_USERNAME/node-hello/ssl.sh"  # Destination path on the VM
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod +x /tmp/deploy.sh",
      "sudo chmod +x /home/$VM_USERNAME/node-hello/ssl.sh",
      "bash /tmp/deploy.sh"
     ]
  }

  # Use triggers to ensure it runs when necessary
  triggers = {
    always_run = "${timestamp()}" # Forces re-execution
  }
}
