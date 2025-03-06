variable "resource_group_location" {
  description = "Die Region für die Resource Group"
  type        = string
  default     = "westeurope"
}

variable "sku" {
  description = "SKU für den Cognitive Service"
  type        = string
  default     = "S0"
}
