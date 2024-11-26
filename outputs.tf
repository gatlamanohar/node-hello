output "rg-id" {
  value = azurerm_resource_group.tf-rg.id
}
output "vm_ip" {
  value = azurerm_public_ip.tf-Pub[0].ip_address
}
# output "vm-ip-1" {
#   value = azurerm_public_ip.tf-Pub[1].ip_address 
# }
output "vm" {
  value = azurerm_linux_virtual_machine.tf-vm["vm1"].private_ip_address
}

output "subdomain" {
  value = "${azurerm_dns_a_record.A_record.name}.${data.azurerm_dns_zone.zone_name.name}"
}
