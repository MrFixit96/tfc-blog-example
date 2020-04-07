output "hostname" {
  value = var.azure_resource_group_name
}

output "vm_fqdn" {
  value = azurerm_public_ip.two-tier-tfe-demo-app.fqdn
}