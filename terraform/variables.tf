variable "resource_group_location" {
  description = "region for resource group"
  type        = string
  default     = "westeurope"
}

variable "sku" {
  description = "SKU for cognitive service"
  type        = string
  default     = "S0"
}

variable "resource_group_name_prefix" {
  description = "Prefix for the resource group name"
  type        = string
  default     = "my-rg" # Falls kein Wert übergeben wird
}


variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

