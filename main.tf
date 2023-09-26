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

resource "azurerm_storage_container" "email_assets_storage_container" {
  name                  = "email-assets"
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

resource "azurerm_storage_queue" "email_queues" {
  storage_account_name = azurerm_storage_account.storage_account.name
  for_each             = local.default_queues
  name                 = each.value
}

resource "azurerm_application_insights" "application_insights" {
  name                = "inventory-hub-application-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_service_plan" "serverless_service_plan" {
  name                = "inventory-hub-serverless-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // For function app consumption plan
  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_linux_function_app" "inventory-hub-email-service" {
  name                = "inventory-hub-email-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.serverless_service_plan.id


  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key

  app_settings = {
    "SENDER_ADDRESS"                           = "no-reply@${var.domain_name}"
    "COMMUNICATION_SERVICES_CONNECTION_STRING" = azurerm_communication_service.communication-service.primary_connection_string
  }

  site_config {
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_stack {
      dotnet_version              = "7.0"
      use_dotnet_isolated_runtime = true
    }
  }
}
