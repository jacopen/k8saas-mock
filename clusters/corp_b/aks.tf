terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "corp_b"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "azuread" {
}


data "terraform_remote_state" "base" {
  backend = "remote"

  config = {
    organization = "kusama"

    workspaces = {
      name = "azure-base"
    }
  }
}

data "azurerm_resource_group" "main" {
  name = data.terraform_remote_state.base.outputs.resource_group_name
}



module "aks" {
  source                           = "Azure/aks/azurerm"
  resource_group_name              = data.azurerm_resource_group.main.name
  kubernetes_version               = "1.23.3"
  orchestrator_version             = "1.23.3"
  prefix                           = replace("k8saas_corp_b", "_", "-")
  cluster_name                     = "corp_b"
  network_plugin                   = "kubenet"
  vnet_subnet_id                   = data.terraform_remote_state.base.outputs.vnet_subnet_id
  os_disk_size_gb                  = 50
  sku_tier                         = "Free"
  enable_role_based_access_control = true
  rbac_aad_managed                 = true
  rbac_aad_admin_group_object_ids  = ["7e471924-f039-45f7-bc94-70e9eadb0014"]
  private_cluster_enabled          = true
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = false
  enable_host_encryption           = false
  identity_type                    = "UserAssigned"
  user_assigned_identity_id        = data.terraform_remote_state.base.outputs.k8saas_user_assigned_identity_id
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = 1
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "corp_b"
  }

  agents_tags = {
    "Agent" : "corp_b_agent"
  }

  enable_ingress_application_gateway      = false
  ingress_application_gateway_name        = "aks-agw"
  ingress_application_gateway_subnet_cidr = "10.52.1.0/24"

  network_policy                 = "calico"
  net_profile_pod_cidr           = "10.0.251.0/24"
  net_profile_dns_service_ip     = "10.0.250.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.250.0/24"
}