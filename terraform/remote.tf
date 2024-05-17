data "terraform_remote_state" "firewall_config" {
  backend = "azurerm"

  config = {
    use_oidc             = var.use_oidc
    use_azuread_auth     = true
    storage_account_name = var.firewall_config_storage_account_name
    container_name       = "tfstate"
    key                  = "firewall-config.tfstate"
  }
}

data "terraform_remote_state" "management" {
  backend = "azurerm"

  config = {
    use_oidc             = var.use_oidc
    use_azuread_auth     = true
    storage_account_name = var.management_storage_account_name
    container_name       = "tfstate"
    key                  = "management.tfstate"
  }
}
