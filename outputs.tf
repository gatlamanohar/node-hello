output "rg-id" {
  value = azurerm_resource_group.tf-rg.id
}
output "vm_ips" {
    value = azurerm_public_ip.tf-Pub[*].ip_address 
}
