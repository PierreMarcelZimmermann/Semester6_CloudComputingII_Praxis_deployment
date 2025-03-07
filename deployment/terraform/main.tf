terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aivision" {
  name     = "aivision-rg"
  location = var.resource_group_location
}

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

resource "local_file" "config_json" {
  filename = "${path.module}/../../app/config.json"  
  content  = jsonencode({
    AI_VISION_API_KEY  = azurerm_cognitive_account.aivision.primary_access_key
    AI_VISION_ENDPOINT = azurerm_cognitive_account.aivision.endpoint
  })
}
