terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
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
  resource_group_name              = data.azurerm_resource_group.main
  kubernetes_version               = "1.19.3"
  orchestrator_version             = "1.19.3"
  prefix                           = "k8saas"
  cluster_name                     = "corp_a"
  network_plugin                   = "azure"
  vnet_subnet_id                   = data.terraform_remote_state.base.outputs.vnet_subnet_id
  os_disk_size_gb                  = 50
  sku_tier                         = "Free"
  enable_role_based_access_control = true
  rbac_aad_managed                 = false
  private_cluster_enabled          = true
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = false
  enable_host_encryption           = true
  agents_min_count                 = 1
  agents_max_count                 = 2
  agents_count                     = 1
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "corp_a"
  }

  agents_tags = {
    "Agent" : "corp_a_agent"
  }

  enable_ingress_application_gateway = false
  ingress_application_gateway_name = "aks-agw"
  ingress_application_gateway_subnet_cidr = "10.52.1.0/24"

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"
}