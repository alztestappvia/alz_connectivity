variable "connectivity_resources_tags" {
  type        = map(string)
  description = "Set tags to apply to the Resource Group"
  default = {
    WorkloadName        = "ALZ.Connectivity"
    DataClassification  = "General"
    BusinessCriticality = "Mission-critical"
    BusinessUnit        = "Platform Operations"
    OperationsTeam      = "Platform Operations"
  }
}

variable "environment" {
  type        = string
  description = "Sets the environment to deploy the resources into"
}

variable "firewall_config_storage_account_name" {
  type        = string
  description = "Sets the name of the storage account to retrieve the firewall configuration from"
}

variable "management_storage_account_name" {
  type        = string
  description = "Sets the name of the storage account to retrieve the management configuration from"
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
  default     = "uksouth"
}

variable "primary_location_cidr" {
  type        = string
  description = "Sets the address prefix for the primary location"
  default     = "172.28.0.0/23"
}

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
  default     = "alz"
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
  default     = "ukwest"
}

variable "secondary_location_cidr" {
  type        = string
  description = "Sets the address prefix for the secondary location"
  default     = "172.28.128.0/23"
}

variable "use_oidc" {
  type        = bool
  description = "Use OpenID Connect to authenticate to AzureRM"
  default     = false
}

variable "networking_model" {
  type        = string
  description = "Sets the networking model to use for the deployment"
  default     = "virtualwan"
  validation {
    condition     = can(regex("^(virtualwan|basic)$", var.networking_model))
    error_message = "networking_model must be either \"virtualwan\" or \"basic\""
  }
}
