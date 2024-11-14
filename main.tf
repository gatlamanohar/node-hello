## Create a resource group
resource "azurerm_resource_group" "tf-rg" {
  name     = "${var.prefix}-terraform-rg"
  location =  var.region.location
}

## Create a virtual machine
resource "azurerm_linux_virtual_machine" "tf-vm" {
  count               = var.vm_list
  name                = "${var.prefix}-VM-${count.index + 1}"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  size                = var.vm_info.size
  admin_username      = var.vm_info.username
  admin_password      = var.vm_info.password
  disable_password_authentication = false
  source_image_reference {
    publisher = var.vm_info.publisher
    offer     = var.vm_info.offer
    sku       = var.vm_info.sku
    version   = var.vm_info.version
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  network_interface_ids = [azurerm_network_interface.tf-nic[count.index].id]
  # depends_on            = [azurerm_network_interface.tf-nic]

  # connection {
  #   type     = "ssh"
  #   user     = var.vm_info.username
  #   host     = self.public_ip_address
  #   password = var.vm_info.password
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update",
  #     "sudo apt install nginx -y"
  #   ]
  # }
}

