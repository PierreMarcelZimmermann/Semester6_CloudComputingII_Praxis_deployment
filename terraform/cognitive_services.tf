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
