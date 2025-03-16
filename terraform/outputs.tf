output "ai_vision_api_key" {
  value     = azurerm_cognitive_account.aivision.primary_access_key
  sensitive = true
}

output "ai_visions_endpoint" {
  value     = azurerm_cognitive_account.aivision.endpoint
  sensitive = true
}

output "vm_public_ip" {
  value = azurerm_public_ip.my_terraform_public_ip.ip_address
}

output "db_server" {
  value = azurerm_mysql_flexible_server.example.fqdn
}

output "db" {
  value = azurerm_mysql_flexible_database.example.name
}

output "db_admin" {
  value = azurerm_mysql_flexible_server.example.administrator_login
}

output "db_password" {
  value     = azurerm_mysql_flexible_server.example.administrator_password
  sensitive = true
}