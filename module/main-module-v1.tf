#---------------------------------------------------------------------------
#  UAMI Creation
#---------------------------------------------------------------------------

# -------------------------------------------------------------
# Required Providers
# -------------------------------------------------------------

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.45.0, < 6.0.0"
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.app518]
    }
  }
}

provider "github" {
  alias = "ghorg"
  owner = var.owner //"DayforceGlobal" //var.owner // "DayforceGlobal" //var.owner //"DayforceCloud"

  // Use App auth a below
  app_auth {
    id              = var.app_id
    installation_id = var.app_installation_id
    pem_file        = data.azurerm_key_vault_secret.app_pem_file.value
  }
}

data "azurerm_key_vault" "app518-kv-pri" {
  provider            = azurerm.app518
  name                = var.kv_name
  resource_group_name = var.kv_rg_group
}
data "azurerm_key_vault_secret" "app_pem_file" {
  provider     = azurerm.app518
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.app518-kv-pri.id
}

#-------------------------------------------------------------
# Data Reference
#-------------------------------------------------------------


data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

//terraform-azurerm-welcome-kit
//cie-camelot-welcome-kit
//herald build 3 deploy
//SS151
// Build UAMI is only created in NonProd environment


locals {
  local_gh_repos={}
}


module "rg_build" {
  source              = "git@github.com:dayforcecloud/terraform-azurerm-resource-group.git//?ref=v1.0.5"
  resource_group_name = join("-", ["app", var.platform_short_name, "build-uaid-rg"])
  location            = var.location
  tags                = var.tags
}

module "rg_deploy" {
  source              = "git@github.com:dayforcecloud/terraform-azurerm-resource-group.git//?ref=v1.0.5"
  resource_group_name = join("-", ["app", var.platform_short_name, "deploy-uaid-rg"])
  location            = var.location
  tags                = var.tags
}



resource "azurerm_user_assigned_identity" "uaid_build" {
  for_each            = var.gh_repos
  name                = join("-", ["app", var.platform_short_name, "build", each.value.repo_name,"uaid"]) // should these be ss151
  resource_group_name = module.rg_build.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "uaid_deploy_np" {
  for_each            = var.gh_repos
  name                = join("-", ["app", var.platform_short_name,"np-deploy", each.value.repo_name,"uaid"])
  resource_group_name = module.rg_deploy.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "uaid_deploy_pre" {
  for_each            = var.gh_repos
  name                = join("-", ["app", var.platform_short_name, "pre-deploy", each.value.repo_name,"uaid"])
  resource_group_name = module.rg_deploy.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "uaid_deploy_prod" {
  for_each            = var.gh_repos
  name                = join("-", ["app", var.platform_short_name, "prod-deploy", each.value.repo_name,"uaid"])
  resource_group_name = module.rg_deploy.resource_group_name
  location            = var.location
  tags                = var.tags
}

#---------------------------------------------------------------------------
#  Build UAMI GH Actions Variables
#---------------------------------------------------------------------------

resource "github_actions_variable" "uaid_client_id_build_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_build]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_CLIENT_ID_BUILD"
  value         = azurerm_user_assigned_identity.uaid_build[each.key].client_id //principal_id
}

resource "github_actions_variable" "uaid_tenant_id_build_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_build]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_TENANT_ID_BUILD"
  value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_variable" "uaid_subscription_id_build_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_build]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_SUBSCRIPTION_ID_BUILD"
  value         = data.azurerm_client_config.current.subscription_id
}

#---------------------------------------------------------------------------
#  Build UAMI GH Actions Secrets (will be decommissioned)
#---------------------------------------------------------------------------

resource "github_actions_secret" "uaid_build_ghas" {
  provider        = github.ghorg
  depends_on      = [azurerm_user_assigned_identity.uaid_build]
  for_each        = var.gh_repos
  repository      = each.value.repo_name
  secret_name     = "ENV_AZURE_CLIENT_ID_BUILD"
  plaintext_value = azurerm_user_assigned_identity.uaid_build[each.key].client_id //principal_id
}

resource "github_actions_secret" "uaid_tenant_id_build_ghas" {
  provider        = github.ghorg
  depends_on      = [azurerm_user_assigned_identity.uaid_build]
  for_each        = var.gh_repos
  repository      = each.value.repo_name
  secret_name     = "ENV_AZURE_TENANT_ID_BUILD"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "uaid_subscription_id_build_ghas" {
  provider        = github.ghorg
  depends_on      = [azurerm_user_assigned_identity.uaid_build]
  for_each        = var.gh_repos
  repository      = each.value.repo_name
  secret_name     = "ENV_AZURE_SUBSCRIPTION_ID_BUILD"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

#################---environment----non-prod--------###################
#---------------------------------------------------------------------------
#  Deploy NP UAMI GH Actions Variables
#---------------------------------------------------------------------------

resource "github_actions_environment_variable" "uaid_client_id_deploy_np_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "non-prod"
  variable_name = "ENV_AZURE_CLIENT_ID"
  value         = azurerm_user_assigned_identity.uaid_deploy_np[each.key].client_id //principal_id
}

resource "github_actions_environment_variable" "uaid_tenant_id_deploy_np_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "non-prod"
  variable_name = "ENV_AZURE_TENANT_ID"
  value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_variable" "uaid_subscription_id_deploy_np_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "non-prod"
  value         = data.azurerm_client_config.current.subscription_id
}

#---------------------------------------------------------------------------
#  Deploy NP UAMI GH Actions Secrets (will be decommissioned)
#---------------------------------------------------------------------------

resource "github_actions_environment_secret" "uaid_client_id_deploy_np_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "non-prod"
  secret_name = "ENV_AZURE_CLIENT_ID"
  plaintext_value         = azurerm_user_assigned_identity.uaid_deploy_np[each.key].client_id //principal_id
}

resource "github_actions_environment_secret" "uaid_tenant_id_deploy_np_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "non-prod"
  secret_name = "ENV_AZURE_TENANT_ID"
  plaintext_value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_secret" "uaid_subscription_id_deploy_np_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  secret_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "non-prod"
  plaintext_value         = data.azurerm_client_config.current.subscription_id
}

#################---environment----pre-prod--------###################
#---------------------------------------------------------------------------
#  Deploy NP UAMI GH Actions Variables - pre-prod
#---------------------------------------------------------------------------

resource "github_actions_environment_variable" "uaid_client_id_deploy_pre_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "pre-prod"
  variable_name = "ENV_AZURE_CLIENT_ID"
  value         = azurerm_user_assigned_identity.uaid_deploy_pre[each.key].client_id //principal_id
}

resource "github_actions_environment_variable" "uaid_tenant_id_deploy_pre_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "pre-prod"
  variable_name = "ENV_AZURE_TENANT_ID"
  value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_variable" "uaid_subscription_id_deploy_pre_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "pre-prod"
  value         = data.azurerm_client_config.current.subscription_id
}

#---------------------------------------------------------------------------
#  Deploy pre UAMI GH Actions Secrets (will be decommissioned)
#---------------------------------------------------------------------------

resource "github_actions_environment_secret" "uaid_client_id_deploy_pre_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "pre-prod"
  secret_name = "ENV_AZURE_CLIENT_ID"
  plaintext_value         = azurerm_user_assigned_identity.uaid_deploy_pre[each.key].client_id //principal_id
}

resource "github_actions_environment_secret" "uaid_tenant_id_deploy_pre_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "pre-prod"
  secret_name = "ENV_AZURE_TENANT_ID"
  plaintext_value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_secret" "uaid_subscription_id_deploy_pre_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_pre]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  secret_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "pre-prod"
  plaintext_value         = data.azurerm_client_config.current.subscription_id
}

#################---environment----prod--------###################
#---------------------------------------------------------------------------
#  Deploy prod UAMI GH Actions Variables - prod
#---------------------------------------------------------------------------

resource "github_actions_environment_variable" "uaid_client_id_deploy_prod_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "prod"
  variable_name = "ENV_AZURE_CLIENT_ID"
  value         = azurerm_user_assigned_identity.uaid_deploy_prod[each.key].client_id //principal_id
}

resource "github_actions_environment_variable" "uaid_tenant_id_deploy_prod_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "prod"
  variable_name = "ENV_AZURE_TENANT_ID"
  value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_variable" "uaid_subscription_id_deploy_prod_ghav" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  variable_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "prod"
  value         = data.azurerm_client_config.current.subscription_id
}

#---------------------------------------------------------------------------
#  Deploy prod UAMI GH Actions Secrets (will be decommissioned)
#---------------------------------------------------------------------------

resource "github_actions_environment_secret" "uaid_client_id_deploy_prod_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "prod"
  secret_name = "ENV_AZURE_CLIENT_ID"
  plaintext_value         = azurerm_user_assigned_identity.uaid_deploy_prod[each.key].client_id //principal_id
}

resource "github_actions_environment_secret" "uaid_tenant_id_deploy_prod_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  environment   = "prod"
  secret_name = "ENV_AZURE_TENANT_ID"
  plaintext_value         = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_environment_secret" "uaid_subscription_id_deploy_prod_ghas" {
  provider      = github.ghorg
  depends_on    = [azurerm_user_assigned_identity.uaid_deploy_prod]
  for_each      = var.gh_repos
  repository    = each.value.repo_name
  secret_name = "ENV_AZURE_SUBSCRIPTION_ID"
  environment   = "prod"
  plaintext_value         = data.azurerm_client_config.current.subscription_id
}
#---------------------------------------------------------------------------
#  Add Build UAMI to AAD Group for DUMP ACR (ACR Push)
#---------------------------------------------------------------------------

/// add deploy or build to KV for RE team?

////// add camelot SPNS to AAD groups

# data "azuread_group" "ss151_dump_acr" {
#   display_name     = var.aad_dump_acr
#   security_enabled = true
# }

# resource "azuread_group_member" "ss151_dump_acr_build" {
#   for_each         = var.build_uami
#   group_object_id  = data.azuread_group.ss151_dump_acr.id
#   member_object_id = azurerm_user_assigned_identity.um_identity_build[each.key].principal_id
# }


#---------------------------------------------------------------------------
#  Add Deploy UAMI to AAD Group for Dump ACR (ACR Push) and Deploy ACR (ACR Push)
#---------------------------------------------------------------------------

# data "azuread_group" "deploy_acr_pull_aad" {
#   display_name     = var.aad_deploy_acr
#   security_enabled = true
# }

# resource "azuread_group_member" "ss151_dump_acr_deploy" {
#   for_each         = var.deploy_uami
#   group_object_id  = data.azuread_group.ss151_dump_acr.id
#   member_object_id = azurerm_user_assigned_identity.um_identity_deploy[each.key].principal_id
# }


# resource "azuread_group_member" "acr_uami_deploy" {
#   for_each         = var.deploy_uami
#   group_object_id  = data.azuread_group.deploy_acr_pull_aad.id
#   member_object_id = azurerm_user_assigned_identity.um_identity_deploy[each.key].principal_id
# }

#---------------------------------------------------------------------------
#  Create Federated Credentials for User Assigned Managed Identity
#---------------------------------------------------------------------------

locals {
  uami_environment_name = {
    sb   = "sandbox"
    np   = "non-prod"
    pre  = "pre-prod"
    prod = "prod"
  }
}

#---------------------------------------------------------------------------
# Build -  User Assigned Managed Identity Federated Credentials
#---------------------------------------------------------------------------

resource "azurerm_federated_identity_credential" "build_federated_creds_main" {
  depends_on    = [azurerm_user_assigned_identity.uaid_build]
  for_each      = var.gh_repos
  name                = each.value.repo_name
  resource_group_name = module.rg_build.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uaid_build[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:ref:refs/heads/main"
}


resource "azurerm_federated_identity_credential" "build_federated_creds_pr" {
  depends_on    = [azurerm_user_assigned_identity.uaid_build]
  for_each      = var.gh_repos
  name                = each.value.repo_name
  resource_group_name = module.rg_build.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uaid_build[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:pull_request"
}

#---------------------------------------------------------------------------
# Deploy -  User Assigned Managed Identity Federated Credentials
#---------------------------------------------------------------------------

resource "azurerm_federated_identity_credential" "deploy_federated_creds_env_np" {
  depends_on          = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each            = var.deploy_uami
  name                = join("-", [each.value.repo_name,"non-prod"])
  resource_group_name = module.rg_deploy.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uaid_deploy_np[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:environment:non-prod"
}

resource "azurerm_federated_identity_credential" "deploy_federated_creds_env_pre" {
  depends_on          = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each            = var.deploy_uami
  name                = join("-", [each.value.repo_name,"pre-prod"])
  resource_group_name = module.rg_deploy.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uaid_deploy_np[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:environment:pre-prod"
}

resource "azurerm_federated_identity_credential" "deploy_federated_creds_env_prod" {
  depends_on          = [azurerm_user_assigned_identity.uaid_deploy_np]
  for_each            = var.deploy_uami
  name                = join("-", [each.value.repo_name,"prod"])
  resource_group_name = module.rg_deploy.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.uaid_deploy_np[each.key].id
  subject             = "repo:${each.value.gh_org}/${each.value.repo_name}:environment:prod"
}

   