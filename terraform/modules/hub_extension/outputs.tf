output "dns_server_ips" {
  value = azurerm_private_dns_resolver_inbound_endpoint.dns_inbound.ip_configurations.*.private_ip_address
}

output "hub_exention_vnet_id" {
  value = azurerm_virtual_network.hub_ext.id
}
