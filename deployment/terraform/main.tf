terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group 1 (für Infrastruktur)
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Resource Group 2 (für AI Vision)
resource "azurerm_resource_group" "aivision" {
  name     = "aivision-rg"
  location = var.resource_group_location
}

# Virtuelles Netzwerk und Subnetz
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Security Group
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "my_terraform_nic" {
  depends_on = [azurerm_public_ip.my_terraform_public_ip]  # Sicherstellen, dass die öffentliche IP-Adresse erstellt wird

  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}


# Sicherheitsgruppe an das Interface binden
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Storage Account für Boot Diagnostics
resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Virtuelle Maschine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  depends_on = [azurerm_network_interface.my_terraform_nic]  # Sicherstellen, dass das NIC fertig ist

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

# Cognitive Services für AI Vision
resource "random_string" "cognitive_name" {
  length  = 10
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_cognitive_account" "aivision" {
  name                = "aivision-${random_string.cognitive_name.result}"
  location            = azurerm_resource_group.aivision.location
  resource_group_name = azurerm_resource_group.aivision.name
  sku_name            = var.sku
  kind                = "CognitiveServices"
}

# Konfigurationsdatei für AI Vision speichern
resource "local_file" "aivisions_config" {
  filename = "${path.module}/../../app/aivision_config.json"
  content  = jsonencode({
    AI_VISION_API_KEY  = azurerm_cognitive_account.aivision.primary_access_key
    AI_VISION_ENDPOINT = azurerm_cognitive_account.aivision.endpoint
  })
}

resource "local_file" "vm_config" {
  depends_on = [azurerm_public_ip.my_terraform_public_ip]  # Sicherstellen, dass die öffentliche IP-Adresse erstellt wird

  filename = "${path.module}/../../app/vm_config.json"
  content  = jsonencode({
    VM_PUBLIC_IP       = azurerm_public_ip.my_terraform_public_ip.ip_address
    VM_PRIVATE_IP      = azurerm_network_interface.my_terraform_nic.ip_configuration[0].private_ip_address
    VM_USERNAME        = var.username
    VM_NAME            = azurerm_linux_virtual_machine.my_terraform_vm.name
    SSH_PORT           = 22
  })
}
# Output der öffentlichen IP-Adresse
output "vm_public_ip" {
  value = azurerm_public_ip.my_terraform_public_ip.ip_address
}
