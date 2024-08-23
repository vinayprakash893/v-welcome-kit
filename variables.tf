variable "deploy_region" {
  type = string
  default = "southcentralus"
}

variable "resource_group_name" {
  type = string
  default = "1-eb1bd7c3-playground-sandbox"
}

variable "environment_name" {
  type = string
  default = "dev1"
}

variable "topic" {
  type = string
  default = "vny"
}


variable "owner" {
  type = string
  default = "vinayprakash893"
}

variable "github_token" {
  type = string
  sensitive = true
  default = "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--------------"
}

# variable "build_uami" {
#   description = "Map of GitHub repos to create"
#   type = map(object({
#     app = string
#   }))
#   default = {
#     repo1 = { app = "a" }
#     repo2 = { app = "b" }
#   }
# }

variable "gh_repos" {
  description = "Map of Github repos to create"
  default     = {}
  type = map(object({
    repo_name                   = string
    gh_org                      = string
    description                 = optional(string)
    homepage_url                = optional(string)
    visibility                  = optional(string, "internal")
    has_issues                  = optional(bool, true)
    has_projects                = optional(bool, false)
    has_wiki                    = optional(bool, false)
    is_template                 = optional(bool, false)
    allow_merge_commit          = optional(bool, true)
    allow_squash_merge          = optional(bool, true)
    allow_rebase_merge          = optional(bool, true)
    allow_auto_merge            = optional(bool, false)
    merge_commit_title          = optional(string, "MERGE_MESSAGE")
    merge_commit_message        = optional(string, "PR_TITLE")
    squash_merge_commit_title   = optional(string, "COMMIT_OR_PR_TITLE")
    squash_merge_commit_message = optional(string, "COMMIT_MESSAGES")
    delete_branch_on_merge      = optional(bool, false)
    has_downloads               = optional(bool, false)
    auto_init                   = optional(bool, false)
    gitignore_template          = optional(string, null)
    license_template            = optional(string, null)
    archived                    = optional(bool, false)
    archive_on_destroy          = optional(bool, false)
    pages                       = optional(map(any), {})
    topics                      = optional(list(string), [])
    template                    = optional(map(string), {})
    vulnerability_alerts        = optional(bool, true)
    team_repository_teams = optional(list(object({
      team_id    = string
      permission = string
    })), [])
    actions_secrets   = optional(map(string), {})
    actions_variables = optional(map(string), {})
    workflow_environments = optional(list(object({
      env_name                     = string
      required_reviewer_team_names = optional(list(string), [])
      required_reviewer_usernames  = optional(list(string), [])
    })), [])
  }))
}
