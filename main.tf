resource "azurerm_resource_group" "rg" {
  name     = "inventory-hub-rg"
  location = "westeurope"
}

resource "azurerm_communication_service" "communication-service" {
  name                = "inventory-hub-communication-service"
  data_location       = "Europe"
  resource_group_name = azurerm_resource_group.rg.name
}

// Sadly email communication services support is mediocre
// and domains and sender info needs to be added manually
resource "azurerm_email_communication_service" "communication-email" {
  name                = "inventory-hub-communication-email"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = azurerm_communication_service.communication-service.data_location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "inventoryhubstorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  access_tier              = "Hot"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "container"
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "inventory-hub-cdn-profile"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_blob_endpoint" {
  name                = "inventory-hub-cdn-blob-endpoint"
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  origin_host_header  = azurerm_storage_account.storage_account.primary_blob_host

  origin {
    name      = azurerm_storage_account.storage_account.name
    host_name = azurerm_storage_account.storage_account.primary_blob_host
  }
}

resource "azurerm_cdn_endpoint_custom_domain" "cdn_custom_domain" {
  name            = "inventory-hub-cdn-custom-domain"
  cdn_endpoint_id = azurerm_cdn_endpoint.cdn_blob_endpoint.id
  host_name       = "cdn.${var.domain_name}"
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
    tls_version      = "TLS12"
  }
}
