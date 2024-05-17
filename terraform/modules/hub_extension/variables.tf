variable "location" {
  type        = string
  description = "Location of the hub extension."
}

variable "virtual_hub_id" {
  type        = string
  description = "The ID of the virtual hub to extend."
}

variable "address_space" {
  type        = list(string)
  description = "The address space of the hub extension."
}

variable "private_dns_zones" {
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  description = "The private DNS zones to link to the hub extension."
}

variable "tags" {
  type        = map(string)
  description = "Set tags to apply to the resources"
  default     = {}
}

variable "deploy_bastion" {
  type        = bool
  description = "Deploy a bastion for the hub extension."
  default     = false
}