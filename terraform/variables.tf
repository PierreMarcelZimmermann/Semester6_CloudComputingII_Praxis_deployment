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
