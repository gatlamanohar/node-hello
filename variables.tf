variable "region" {
  type = object({
    name     = string
    location = string
  })
  # default = "eastus"
}

variable "vnet_cidr" {
  type = object({
    address_space = string
  })
  # default = "192.168.0.0/16"
}

variable "subnet_cidr" {
  type = object({
    address_prefixes = list(string)
  })
}

variable "vm_info" {
  type = map(object({
    username  = string
    size      = string
    sku       = string
    offer     = string
    publisher = string
    version   = string
    # password  = string
  }))

}

variable "nsg_info" {
  type = object({
    name = string
    rules = list(object({
      name                       = string
      priority                   = number
      description                = string
      direction                  = string
      access                     = string
      protocal                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  })

}
variable "vm_list" {
  type        = number
  description = "It is used for to create the number of vms to be require"

}

variable "nic_list" {
  type        = number
  description = "It is used for to create the number of nic to be require"

}
variable "subnet_list" {
  type        = number
  description = "It is used for to create the number of subnet to be require"

}
variable "pub_list" {
  type        = number
  description = "It is used for to create the number of vms to be require"

}

variable "lb_rules" {
  type = map(object({
    name          = string
    protocal      = string
    frontend_port = number
    backend_port  = number
  }))
  description = "rules for load balancer"
}

variable "lb_probes" {
  type = map(object({
    name     = string
    protocal = string
    port     = number
  }))
}

variable "dns_zone" {
  type = object({
    name                = string
    resource_group_name = string
    record_name         = string
    ttl                 = number
  })
}

variable "email" {
  description = "The email address for certbot"
  type        = string
}

variable "server" {
  description = "The server address or IP to proxy to"
  type        = string
}
