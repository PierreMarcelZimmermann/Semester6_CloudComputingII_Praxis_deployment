resource "random_password" "mysql_admin_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric  = true
}

resource "random_id" "server_name" {
  byte_length = 8
}

resource "azurerm_mysql_flexible_server" "example" {
    name                = "digital-bison-${random_id.server_name.hex}"  # Unique server name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "Germany North"
  administrator_login          = "sqladmin"
  administrator_password       = random_password.mysql_admin_password.result  # Dynamically generated password
  version                      = "5.7"
  create_mode                  = "Default"
  sku_name                     = "MO_Standard_E4ds_v4"
}

resource "azurerm_mysql_flexible_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.example.name

  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all_ips" {
  name                 = "allow-all-ips"
  resource_group_name  = azurerm_resource_group.rg.name
  server_name          = azurerm_mysql_flexible_server.example.name
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"  # Allows access from all IPs
}
