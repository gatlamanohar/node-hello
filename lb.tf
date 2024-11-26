resource "azurerm_lb" "ALB" {
  name                = "tf-ALB"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = var.region.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "ALB_IP"
    public_ip_address_id = azurerm_public_ip.tf-Pub[0].id
  }
  depends_on = [azurerm_network_interface.tf-nic, azurerm_lb.ALB]
}

# Backend Address Pool for LB
resource "azurerm_lb_backend_address_pool" "ALB-bp" {
  name            = "tf-b-pool"
  loadbalancer_id = azurerm_lb.ALB.id
  #   virtual_network_id = azurerm_virtual_network.tf-vnet.id
}


# Health Probe for SSH
resource "azurerm_lb_probe" "lb_probes" {
  for_each        = var.lb_probes
  name            = each.value.name
  loadbalancer_id = azurerm_lb.ALB.id
  port            = each.value.port
  protocol        = each.value.protocal
}

# LB Rule for Allowing SSH
resource "azurerm_lb_rule" "lb_rules" {
  #   for_each                       = { for rule in var.lb_rules : rule.name => rule }
  for_each                       = var.lb_rules
  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.ALB.id
  protocol                       = each.value.protocal
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = azurerm_lb.ALB.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ALB-bp.id]
  disable_outbound_snat          = true # Explicitly disable SNAT
  probe_id                       = azurerm_lb_probe.lb_probes[each.key].id
}

# Outbound Rule for LB
resource "azurerm_lb_outbound_rule" "my_lboutbound_rule" {
  count                   = 1
  name                    = "test-outbound"
  loadbalancer_id         = azurerm_lb.ALB.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ALB-bp.id

  frontend_ip_configuration {
    name = azurerm_lb.ALB.frontend_ip_configuration[count.index].name
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-pool" {
  count                   = var.nic_list
  network_interface_id    = azurerm_network_interface.tf-nic[count.index].id
  ip_configuration_name   = azurerm_network_interface.tf-nic[count.index].ip_configuration[count.index].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ALB-bp.id
  depends_on = [ azurerm_network_interface.tf-nic ]

}

