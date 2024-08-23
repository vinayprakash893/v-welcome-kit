

variable "location" {
  description = "Region to deploy service(s) into"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name for application"
  type        = string
  default     = null
}

variable "subscription" {
  description = "Subscription where resource resides"
  type        = string
  default     = null
}

variable "purpose" {
  description = "Reason for building azure resource"
  type        = string
  default     = null
}

variable "build_uami" {
  description = "Build User Assigned Managed Identity"
  default     = null
}

variable "deploy_uami" {
  description = "Deploy User Assigned Managed Identity"
  default     = null
}

variable "platform_short_name" {
  description = "Platform short name"
  default     = null
}

variable "gh_repos" {
  description = "Github Repos"
  default     = null
}
variable "tags" {
  description = "Tags that are added to resource"
  type        = map(string)
  default     = {}
}

variable "app_id" {
  description = "The GitHub App ID"
  type        = string
}

variable "app_installation_id" {
  description = "The GitHub App Installation ID"
  type        = string
}

variable "kv_name" {
  description = "The name of the key vault"
  type        = string
  default     = "app518-iac-ue2-np-pri"
}

variable "kv_rg_group" {
  description = "The name of the resource group for the key vault"
  type        = string
  default     = "app518-iac-tooling-np-eastus2"
}

variable "owner" {
  description = "Github Provider org owner"
  type        = string
}

variable "secret_name" {
  description = "The name of the secret in the key vault"
  type        = string
  sensitive   = true
}