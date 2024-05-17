locals {
  vwan_hub_ids = {
    for k, v in module.enterprise_scale.azurerm_virtual_hub.virtual_wan : v.location => k
  }
  vwan_firewall_ids = {
    for k, v in module.enterprise_scale.azurerm_firewall.virtual_wan : v.location => k
  }
}

output "configuration" {
  description = "Configuration settings for the \"connectivity\" resources."
  value       = local.configure_connectivity_resources
}

output "subscription_id" {
  description = "Subscription ID for the \"connectivity\" resources."
  value       = data.azurerm_client_config.current.subscription_id
}

output "azurerm_firewall_ids" {
  description = "Returns a Map of Location => ID for all Azure Firewalls that have been created."
  value       = local.vwan_firewall_ids
}

output "azurerm_virtual_hub_ids" {
  description = "Returns a Map of Location => ID for all Virtual Hubs that have been created."
  value       = local.vwan_hub_ids
}

output "azurerm_private_dns_zone" {
  description = "Returns the Private DNS Zones that has been created."
  value       = module.enterprise_scale.azurerm_private_dns_zone.connectivity
}
