resource "tfe_workspace" "CLUSTER_ID" {
  name                = "CLUSTER_ID"
  organization        = data.tfe_organization.org.name
  auto_apply          = true
  queue_all_runs      = false
  speculative_enabled = false
  working_directory   = "clusters/CLUSTER_ID"
  vcs_repo {
    identifier         = "jacopen/k8saas-mock"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
  execution_mode    = "remote"
  terraform_version = "1.1.6"
}

## Setup secrets to workspace
data "vault_generic_secret" "CLUSTER_ID_secrets" {
  path = "kv/k8saas/CLUSTER_ID"
}
resource "tfe_variable" "CLUSTER_ID_subscription_id" {
  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.vault_generic_secret.CLUSTER_ID_secrets.data["subscription_id"]
  workspace_id = tfe_workspace.CLUSTER_ID.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "CLUSTER_ID_client_id" {
  key          = "ARM_CLIENT_ID"
  value        = data.vault_generic_secret.CLUSTER_ID_secrets.data["client_id"]
  workspace_id = tfe_workspace.CLUSTER_ID.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "CLUSTER_ID_client_secret" {
  key          = "ARM_CLIENT_SECRET"
  value        = data.vault_generic_secret.CLUSTER_ID_secrets.data["client_secret"]
  workspace_id = tfe_workspace.CLUSTER_ID.id
  sensitive    = true
  category     = "env"
}
resource "tfe_variable" "CLUSTER_ID_tenant_id" {
  key          = "ARM_TENANT_ID"
  value        = data.vault_generic_secret.CLUSTER_ID_secrets.data["tenant_id"]
  workspace_id = tfe_workspace.CLUSTER_ID.id
  sensitive    = true
  category     = "env"
}
