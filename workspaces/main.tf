terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "azure-workloads"
    }
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "=3.3.1"
    }
    tfe = {
      version = "~> 0.27.0"
    }
  }
}

provider "tfe" {
  version = "~> 0.27.0"
}

provider "vault" {
  address = var.vault_address
  auth_login {
    path = "auth/approle/login"
    namespace = "admin"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

data "tfe_organization" "org" {
  name = "kusama"
}

data "tfe_workspace" "k8saas_mock" {
  name         = "k8saas-mock"
  organization = "kusama"
}