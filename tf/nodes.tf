resource "azurerm_network_interface" "nodenic" {
  count               = var.node_count
  name                = "node${count.index}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "nodevm" {
  count                           = var.node_count
  name                            = "node${count.index}-vm"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  size                            = "Standard_B2s"
  admin_username                  = var.username
  admin_password                  = var.controlplanepassword
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nodenic.*.id[count.index]
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
