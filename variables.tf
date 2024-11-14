variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "Tf"
}

variable "region" {
  type = object({
    name = string
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

# variable "subnet_cidr" {
#   type = list(string)
#   default = [ "19" ]
# }
variable "vm_info" {
  type = object({
    size = string
    publisher = string
    offer = string
    sku = string
    version = string
    username = string
    password = string
  })
}

variable "nsg_info" {
  type = object({
    name = string
    rules = list(object({
      name = string
      priority = number
      description = string
      direction = string
      access  = string
      protocal = string
      source_port_range = string
      destination_port_range = string 
      source_address_prefix = string  
      destination_address_prefix = string
    }))
  })
  
}
variable "vm_list" {
  type = number
  description = "It is used for to create the number of vms to be require"
  
}

variable "nic_list" {
  type = number
  description = "It is used for to create the number of nic to be require"
}
variable "subnet_list" {
  type = number
  description = "It is used for to create the number of subnet to be require"
  
}
variable "pub_list" {
  type = number
  description = "It is used for to create the number of vms to be require"
  
}

