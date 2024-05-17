data "azuread_service_principal" "vendor" {
  display_name = "id-${var.root_id}-vendor"
}

resource "azurerm_role_assignment" "vendor_network_contributor" {
  for_each             = merge(module.enterprise_scale.azurerm_resource_group.connectivity, module.enterprise_scale.azurerm_resource_group.virtual_wan)
  scope                = each.value.id
  principal_id         = data.azuread_service_principal.vendor.object_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "vendor_private_dns_zone_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  principal_id         = data.azuread_service_principal.vendor.object_id
  role_definition_name = "Private DNS Zone Contributor"
}

data "azuread_service_principal" "bootstrap" {
  display_name = "id-${var.root_id}-bootstrap"
}

# Required to allow bootstrap to peer its network
resource "azurerm_role_assignment" "bootstrap_network_contributor" {
  for_each             = merge(module.enterprise_scale.azurerm_resource_group.connectivity, module.enterprise_scale.azurerm_resource_group.virtual_wan)
  scope                = each.value.id
  principal_id         = data.azuread_service_principal.bootstrap.object_id
  role_definition_name = "Network Contributor"
}

# Currently required to allow SPN used to deploy AKS module to read Private DNS Zone resource ID
resource "azuread_group" "alz_connectivity_private_dns_zone_contributor" {
  display_name     = "alz-connectivity-private-dns-zone-contributor"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Private DNS Zone Contributor used to support future scenarios where a LZ can update private DNS
resource "azurerm_role_assignment" "alz_connectivity_private_dns_zone_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azuread_group.alz_connectivity_private_dns_zone_contributor.object_id
}
