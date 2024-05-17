resource "azurerm_resource_group" "hub_ext" {
  name     = "rg-hub-ext-${var.location}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_security_group" "dns_nsg" {
  name                = "nsg-hub-ext-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_ext.name
  tags                = var.tags
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "nsg-hub-ext-bastion-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_ext.name
  tags                = var.tags
  security_rule {
    name                       = "bastion-in-allow"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "bastion-control-in-allow-443"
    priority                   = "120"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "135"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Kerberos-password-change"
    priority                   = "121"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "bastion-vnet-out-allow-22"
    priority                   = "103"
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "bastion-vnet-out-allow-3389"
    priority                   = "101"
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "bastion-azure-out-allow"
    priority                   = "120"
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }
}

resource "azurerm_virtual_network" "hub_ext" {
  name                = "hub-ext-vnet-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_ext.name
  address_space       = var.address_space
  tags                = var.tags

  subnet {
    name           = "snet-dns-resolver-${var.location}-inbound"
    address_prefix = cidrsubnet(var.address_space[0], 1, 0)
    security_group = azurerm_network_security_group.dns_nsg.id
  }
  subnet {
    name           = "snet-dns-resolver-${var.location}-outbound"
    address_prefix = cidrsubnet(var.address_space[0], 1, 1)
    security_group = azurerm_network_security_group.dns_nsg.id
  }
  dynamic "subnet" {
    for_each = var.deploy_bastion==true? [1]:[]
    content {
      name           = "AzureBastionSubnet"
      address_prefix = var.address_space[1]
      security_group = azurerm_network_security_group.bastion_nsg.id
    }
  }
}

resource "azurerm_virtual_hub_connection" "hub_ext" {
  name                      = "hub-ext-${var.location}"
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.hub_ext.id
  internet_security_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "pe_priv_dns_link" {
  for_each              = var.private_dns_zones
  name                  = "alz-connectivity_${azurerm_virtual_network.hub_ext.name}"
  private_dns_zone_name = each.value.name
  resource_group_name   = each.value.resource_group_name
  virtual_network_id    = azurerm_virtual_network.hub_ext.id
  tags                  = var.tags
}
