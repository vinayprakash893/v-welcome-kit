provider "github" {
  alias = "ghorg"
  token = var.github_token
  owner = "vinayprakash893"
}

data "github_user" "current" {
  username = "vinayprakash893"
}

terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.43.0"
    }
  }
  cloud {
    organization = "Cloudtech"

    workspaces {
      name = "welcome-1"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}


data "azurerm_client_config" "current" {}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}