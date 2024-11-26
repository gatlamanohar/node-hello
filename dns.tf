## fetch dns zone and create a record 
data "azurerm_dns_zone" "zone_name" {
  name                = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name
}

resource "azurerm_dns_a_record" "A_record" {
  name                = var.dns_zone.record_name
  zone_name           = data.azurerm_dns_zone.zone_name.name
  resource_group_name = data.azurerm_dns_zone.zone_name.resource_group_name
  ttl                 = var.dns_zone.ttl
  records             = [azurerm_public_ip.tf-Pub[0].ip_address]
}

