# Configure the Azure provider
terraform {
  cloud {
    organization = "prenaissance"
    workspaces {
      name = "inventory-hub"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

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
// and domains and sender info needs to be added manually/ from the cli
resource "azurerm_email_communication_service" "communication-email" {
  name                = "inventory-hub-communication-email"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = "Europe"
}
