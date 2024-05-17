terraform {
  required_version = ">= 1.3.1"

  backend "azurerm" {
    use_oidc         = true
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.40.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.2.26"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.7.0"
    }
  }
}
