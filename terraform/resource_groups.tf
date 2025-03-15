# Resource Group 1 (for Infrastructure)
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Resource Group 2 (for AI Vision)
resource "azurerm_resource_group" "aivision" {
  name     = "aivision-rg"
  location = var.resource_group_location
}
