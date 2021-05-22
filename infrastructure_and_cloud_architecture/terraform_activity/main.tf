/**
* Declaracao do plugin
**/
terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

/**
* Declaração do provedor
**/
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

/**
* Declaração do resource group
**/
resource "azurerm_resource_group" "rgProd" {
    name     = "rgProd"
    location = "eastus"

    tags     = {
        "Environment" = "Prodcution"
    }
}