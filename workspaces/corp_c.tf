resource "tfe_workspace" "corp_c" {
  name                = "corp_c"
  organization        = data.tfe_organization.org.name
  auto_apply          = true
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "clusters/corp_c"
  vcs_repo {
    identifier         = "jacopen/k8saas-mock"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
  execution_mode = "remote"
  terraform_version = "1.1.6"
}

## Setup secrets to workspace
data "vault_generic_secret" "corp_c_secrets" {
  path = "kv/k8saas/corp_c"
}
resource "tfe_variable" "corp_c_subscription_id" {
  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.vault_generic_secret.corp_c_secrets.data["subscription_id"]
  workspace_id = tfe_workspace.corp_c.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "corp_c_client_id" {
  key          = "ARM_CLIENT_ID"
  value        = data.vault_generic_secret.corp_c_secrets.data["client_id"]
  workspace_id = tfe_workspace.corp_c.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "corp_c_client_secret" {
  key          = "ARM_CLIENT_SECRET"
  value        = data.vault_generic_secret.corp_c_secrets.data["client_secret"]
  workspace_id = tfe_workspace.corp_c.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "corp_c_tenant_id" {
  key          = "ARM_TENANT_ID"
  value        = data.vault_generic_secret.corp_c_secrets.data["tenant_id"]
  workspace_id = tfe_workspace.corp_c.id
  sensitive    = true
  category     = "env"
}
