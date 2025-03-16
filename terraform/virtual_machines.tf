resource "random_id" "storage_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "examplestorage${random_id.storage_suffix.hex}" # Append the unique suffix
  resource_group_name       = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier               = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  depends_on = [azurerm_network_interface.my_terraform_nic]  # Ensure NIC is ready

  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}
