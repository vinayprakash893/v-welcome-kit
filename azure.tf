
resource "azurerm_user_assigned_identity" "uami_identity_build" {
  for_each            = var.gh_repos
  name                = join("-", ["uami-build", each.value.repo_name,"uaid"])
  resource_group_name = var.resource_group_name
  location            = var.deploy_region
  # tags                = var.tags
}

resource "azurerm_user_assigned_identity" "uami_identity_deploy" {
  for_each            = var.gh_repos
  name                = join("-", ["uami-deploy-non-prod", each.value.repo_name,"uaid"])
  resource_group_name = var.resource_group_name
  location            = var.deploy_region
  # tags                = var.tags
}

resource "azurerm_federated_identity_credential" "build_federated_creds_main" {
  depends_on    = [azurerm_user_assigned_identity.uami_identity_build]
  for_each      = var.gh_repos
  name                = each.value.repo_name
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uami_identity_build[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:ref:refs/heads/main"
}

resource "azurerm_federated_identity_credential" "deploy_federated_creds_env_np" {
  depends_on          = [azurerm_user_assigned_identity.uami_identity_deploy]
  for_each            = var.gh_repos
  name                = join("-", [each.value.repo_name,"non-prod"])
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uami_identity_deploy[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:environment:non-prod"
}