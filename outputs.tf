output "rg-id" {
  value = azurerm_resource_group.tf-rg.id
}
output "vm_ip" {
    value = azurerm_public_ip.tf-Pub[0].ip_address 
}
