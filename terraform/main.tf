module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "5.0.3"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  # Base module configuration settings
  root_parent_id   = data.azurerm_client_config.current.tenant_id
  root_id          = var.root_id
  default_location = var.primary_location

  # Disable creation of the core management group hierarchy
  # as this is being created by the core module instance
  deploy_core_landing_zones = false

  # Configuration settings for connectivity resources
  deploy_connectivity_resources    = true
  configure_connectivity_resources = local.configure_connectivity_resources
  subscription_id_connectivity     = data.azurerm_client_config.current.subscription_id
}

module "hub_extension" {
  for_each          = module.enterprise_scale.azurerm_virtual_hub.virtual_wan
  source            = "./modules/hub_extension"
  location          = each.value.location
  virtual_hub_id    = each.value.id
  address_space     = local.hub_extensions[each.value.location].address_space
  deploy_bastion    = try(local.hub_extensions[each.value.location].deploy_bastion,false)
  private_dns_zones = module.enterprise_scale.azurerm_private_dns_zone.connectivity
  tags              = var.connectivity_resources_tags
}
