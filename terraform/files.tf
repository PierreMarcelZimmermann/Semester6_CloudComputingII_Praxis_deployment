resource "local_file" "ansible_inventory" {
  depends_on = [azurerm_public_ip.my_terraform_public_ip]

  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<EOT
[web_servers]
${azurerm_linux_virtual_machine.my_terraform_vm.name} ansible_host=${azurerm_public_ip.my_terraform_public_ip.ip_address} ansible_user=${var.username} ansible_ssh_private_key_file=${path.module}/../ansible/id_rsa

[web_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOT
}

resource "local_file" "ansible_private_key" {
  depends_on = [azurerm_linux_virtual_machine.my_terraform_vm]

  filename = "${path.module}/../ansible/id_rsa"
  content  = azapi_resource_action.ssh_public_key_gen.output.privateKey
  file_permission = "0600"
}


resource "local_file" "env_file" {
  filename = "${path.module}/../ansible/.env"
  content  = <<EOT
AI_VISION_API_KEY=${azurerm_cognitive_account.aivision.primary_access_key}
AI_VISIONS_ENDPOINT=${azurerm_cognitive_account.aivision.endpoint}
VM_PUBLIC_IP=${azurerm_public_ip.my_terraform_public_ip.ip_address}
DB_SERVER=${azurerm_mysql_flexible_server.example.fqdn}
DB=${azurerm_mysql_flexible_database.example.name}
DB_ADMIN=${azurerm_mysql_flexible_server.example.administrator_login}
DB_PASSWORD=${azurerm_mysql_flexible_server.example.administrator_password}
NEXT_PUBLIC_VM_PUBLIC_IP=${azurerm_public_ip.my_terraform_public_ip.ip_address}
EOT
}

