resource "random_string" "uniquestring" {
  length  = 20
  special = false
  upper   = false
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "mystoragfdevnyacgtest"
  resource_group_name      = var.resource_group_name
  location                 = var.deploy_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
