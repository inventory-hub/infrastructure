

output "cdn_cname" {
  value = "Origin: ${azurerm_storage_account.storage_account.primary_blob_host}\nHost  : cdn.${var.domain_name}"
}

output "communication_service_connection_string" {
  value     = azurerm_communication_service.communication-service.primary_connection_string
  sensitive = true
}

output "storage_account_connection_string" {
  value     = azurerm_storage_account.storage_account.primary_connection_string
  sensitive = true
}
