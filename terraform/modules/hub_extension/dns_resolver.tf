resource "azurerm_resource_group" "dns" {
  name     = "rg-dns-resolver-${var.location}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_private_dns_resolver" "dns" {
  name                = "prv-dns-resolver-${var.location}"
  resource_group_name = azurerm_resource_group.dns.name
  location            = var.location
  virtual_network_id  = azurerm_virtual_network.hub_ext.id
  tags                = var.tags
}

locals {
  inbound_subnet_id  = [for s in azurerm_virtual_network.hub_ext.subnet : s.id if s.name == "snet-dns-resolver-${var.location}-inbound"][0]
  outbound_subnet_id = [for s in azurerm_virtual_network.hub_ext.subnet : s.id if s.name == "snet-dns-resolver-${var.location}-outbound"][0]
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns_inbound" {
  name                    = "drie-dns-inbound-ep-${var.location}"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns.id
  location                = var.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = local.inbound_subnet_id
  }
  tags = var.tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "dns_outbound" {
  name                    = "droe-dns-outbound-ep-${var.location}"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns.id
  location                = var.location
  subnet_id               = local.outbound_subnet_id
  tags                    = var.tags
}
