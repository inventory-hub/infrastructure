
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
