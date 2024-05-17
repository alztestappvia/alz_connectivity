resource "azurerm_resource_group" "bastion" {
  count    = var.deploy_bastion == true ? 1 : 0
  name     = "rg-bastion"
  location = var.location
  tags     = var.tags
}

resource "azurerm_public_ip" "bastion_pip" {
  count               = var.deploy_bastion == true ? 1 : 0
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion_host" {
  count               = var.deploy_bastion == true ? 1 : 0
  name                = "bastion-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.bastion[0].name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_virtual_network.hub_ext.subnet.*.id[2]
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }
}
