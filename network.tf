## Create a virtual network
resource "azurerm_virtual_network" "tf-vnet" {
  resource_group_name = azurerm_resource_group.tf-rg.name
  name               = "${var.prefix}-vnet"
  location           = var.region.location
  address_space      = [var.vnet_cidr.address_space]
}

## Create a subnet
resource "azurerm_subnet" "tf-subnet" {
  count                   = var.subnet_list
  name                    = "${var.prefix}-subnet-${count.index + 1}"
  resource_group_name     = azurerm_resource_group.tf-rg.name
  virtual_network_name    = azurerm_virtual_network.tf-vnet.name
  address_prefixes        = [cidrsubnet(var.vnet_cidr.address_space, 4, count.index)]
  depends_on              = [azurerm_virtual_network.tf-vnet]
}

## Create a public IP
resource "azurerm_public_ip" "tf-Pub" {
  count               = var.pub_list
  name                = "${var.prefix}-pub${count.index + 1}"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Dev"
    CreatedBy   = "Terraform"
  }
  depends_on          = [azurerm_resource_group.tf-rg]
}
## Create network interface
resource "azurerm_network_interface" "tf-nic" {
  count               = var.nic_list
  name                = "${var.prefix}-nic-${count.index + 1}"
  location            = var.region.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.tf-Pub[count.index].id
  }
  depends_on          = [azurerm_public_ip.tf-Pub, azurerm_subnet.tf-subnet]
}

## Create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_info.name
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  depends_on          = [azurerm_resource_group.tf-rg]
}

## Create network security rule
resource "azurerm_network_security_rule" "rules" {
  count                          = length(var.nsg_info.rules)
  resource_group_name            = azurerm_resource_group.tf-rg.name
  network_security_group_name    = azurerm_network_security_group.nsg.name
  name                           = var.nsg_info.rules[count.index].name
  priority                       = var.nsg_info.rules[count.index].priority
  description                    = var.nsg_info.rules[count.index].description
  direction                      = var.nsg_info.rules[count.index].direction
  access                         = var.nsg_info.rules[count.index].access
  protocol                       = var.nsg_info.rules[count.index].protocal
  source_port_range              = var.nsg_info.rules[count.index].source_port_range
  destination_port_range         = var.nsg_info.rules[count.index].destination_port_range
  source_address_prefix          = var.nsg_info.rules[count.index].source_address_prefix
  destination_address_prefix     = var.nsg_info.rules[count.index].destination_address_prefix
  depends_on                     = [azurerm_network_security_group.nsg]
}

## Create network security group association with network interface
resource "azurerm_network_interface_security_group_association" "nsg_acs" {
  count                      = length(azurerm_network_interface.tf-nic)
  network_interface_id       = azurerm_network_interface.tf-nic[count.index].id
  network_security_group_id  = azurerm_network_security_group.nsg.id
  depends_on                 = [azurerm_network_security_group.nsg]
}

# resource "azurerm_ssh_public_key" "sshkey" {
#   name = "ssh"
#   resource_group_name = azurerm_resource_group.tf-rg.name
#   location = var.region.location
#   public_key = file("~/.ssh/id_rsa.pub")
# }