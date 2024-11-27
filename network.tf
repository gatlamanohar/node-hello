## Create a virtual network
resource "azurerm_virtual_network" "tf-vnet" {
  resource_group_name = azurerm_resource_group.tf-rg.name
  name                = "tf-vnet"
  location            = var.region.location
  address_space       = [var.vnet_cidr.address_space]
}

## Create a subnet
resource "azurerm_subnet" "tf-subnet" {
  count                = var.subnet_list
  name                 = "tf-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = var.subnet_cidr.address_prefixes
  depends_on           = [azurerm_virtual_network.tf-vnet]
}

## Create a public IP
resource "azurerm_public_ip" "tf-Pub" {
  count               = var.pub_list
  name                = "tf-pub"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Dev"
    CreatedBy   = "Terraform"
  }
  depends_on = [azurerm_resource_group.tf-rg]
}
## Create network interface
resource "azurerm_network_interface" "tf-nic" {
  count               = var.nic_list
  name                = "tf-nic"
  location            = var.region.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id         = azurerm_public_ip.tf-Pub[count.index].id
  }
  depends_on = [azurerm_subnet.tf-subnet]
}

## Create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_info.name
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  # depends_on          = [azurerm_resource_group.tf-rg, azurerm_network_interface.tf-nic, azurerm_virtual_network.tf-vnet]
}

## Create network security rule
resource "azurerm_network_security_rule" "rules" {
  # count                       = length(var.nsg_info.rules)
  for_each                    = { for rule in var.nsg_info.rules : rule.name => rule }
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  name                        = each.value.name
  priority                    = each.value.priority
  description                 = each.value.description
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocal
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  depends_on                  = [azurerm_network_security_group.nsg]
}

## Create network security group association with network interface
resource "azurerm_network_interface_security_group_association" "nsg_acs" {
  count                     = length(azurerm_network_interface.tf-nic)
  network_interface_id      = azurerm_network_interface.tf-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on                = [azurerm_network_security_group.nsg]
}


# ## Add `depends_on` for subnet association if needed
# resource "azurerm_subnet_network_security_group_association" "subnet_nsg_acs" {
#   subnet_id                 = azurerm_subnet.tf-subnet[0].id
#   network_security_group_id = azurerm_network_security_group.nsg.id
#   depends_on                = [azurerm_network_security_group.nsg]
# }
