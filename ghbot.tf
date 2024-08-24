data "github_repository" "repo" {
  full_name = join("", [var.owner,"/v-welcome-kit"])
  
}

data "github_repositories" "example" {
  query = join("", ["owner:",var.owner," topic:",var.topic])
  include_repo_id = true
}

output "gh-repo-example"{
  value = data.github_repositories.example.names
}

resource "github_actions_variable" "example_variable" {
  for_each      = { for repo in data.github_repositories.example.names : repo => { repo_name = repo }}
  provider      = github.ghorg
  repository       = each.value.repo_name
  variable_name    = "example_variable_name"
  value            = "example_variable_value"
}

# resource "github_actions_variable" "umami_client_id_build_ghav" {
#   provider      = github.ghorg
#   depends_on    = [azurerm_user_assigned_identity.uami_identity_build]
#   for_each      = var.gh_repos
#   repository    = each.value.repo_name
#   variable_name = "ENV_AZURE_CLIENT_ID_BUILD"
#   value         = azurerm_user_assigned_identity.uami_identity_build[each.key].client_id //principal_id
# }

# resource "github_repository_environment" "repo_environment" {
#   provider      = github.ghorg
#   environment  = var.environment_name
#   repository   = data.github_repository.repo.id
#   reviewers {
#     users = var.environment_name == "production" ? [data.github_user.current.id] : null
#   }
# }

# resource "github_actions_environment_variable" "example_variable" {
#   provider      = github.ghorg
#   repository       = data.github_repository.repo.name
#   environment      = github_repository_environment.repo_environment.environment
#   variable_name    = "example_variable_name"
#   value            = "example_variable_value"
# }


# resource "github_actions_variable" "umami_client_id_build_ghav" {
#   provider      = github.ghorg
#   depends_on    = [azurerm_user_assigned_identity.uami_identity_build]
#   for_each      = var.gh_repos
#   repository    = each.value.repo_name
#   variable_name = "ENV_AZURE_CLIENT_ID_BUILD"
#   value         = azurerm_user_assigned_identity.uami_identity_build[each.key].client_id //principal_id
# }

# # STORAGE_CONNECTION
# resource "github_actions_environment_secret" "STORAGE_CONNECTION" {
#   repository       = data.github_repository.main.id
#   environment      = github_repository_environment.main.environment
#   secret_name      = "STORAGE_CONNECTION"
#   plaintext_value  = azurerm_storage_account.main.primary_connection_string
# }



# # Change for federated identities used the below instead of storage connection above



# # ARM_CLIENT_ID
# resource "github_actions_environment_secret" "ARM_CLIENT_ID" {
#   repository       = data.github_repository.main.id
#   environment      = github_repository_environment.main.environment
#   secret_name      = "ARM_CLIENT_ID"
#   plaintext_value  = azuread_application.main.application_id
# }

# # ARM_TENANT_ID
# resource "github_actions_environment_secret" "ARM_TENANT_ID" {
#   repository       = data.github_repository.main.id
#   environment      = github_repository_environment.main.environment
#   secret_name      = "ARM_TENANT_ID"
#   plaintext_value  = data.azurerm_client_config.current.tenant_id
# }

# # ARM_SUBSCRIPTION_ID
# resource "github_actions_environment_secret" "ARM_SUBSCRIPTION_ID" {
#   repository       = data.github_repository.main.id
#   environment      = github_repository_environment.main.environment
#   secret_name      = "ARM_SUBSCRIPTION_ID"
#   plaintext_value  = data.azurerm_client_config.current.subscription_id
# }