provider "azurerm" {
  features {}
}

locals {
  name        = "app-vpnd"
  environment = "test"
  location    = "canadacentral"

}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.0"
  name        = local.name
  environment = local.environment
  label_order = ["name", "environment", "location"]
  location    = local.location
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
## Virtual Network in which vpn subnet(Gateway Subnet) will be created.
##-----------------------------------------------------------------------------
module "vnet" {
  source                   = "terraform-az-modules/vnet/azure"
  version                  = "1.0.0"
  name                     = local.name
  resource_position_prefix = false
  environment              = local.environment
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  address_spaces           = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet module call.
## Name specific subnet for vpn will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azure"
  version              = "1.0.0"
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  #subnet
  subnets = [{
    name            = "GatewaySubnet"
    subnet_prefixes = ["10.0.1.0/24"]
    route_table     = "rt-test"
  }]
  # route_table
  enable_route_table = false
  route_tables = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

##-----------------------------------------------------------------------------
## Log Analytics module call.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "2.0.0"
  name                             = local.name
  environment                      = local.environment
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  retention_in_days                = 90
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  log_analytics_workspace_id       = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## VPN module call.
## Following module will deploy point to site vpn in azure infratsructure.
##-----------------------------------------------------------------------------
module "vpn" {
  depends_on               = [module.vnet]
  source                   = "../../"
  name                     = local.name
  resource_position_prefix = false
  environment              = local.environment
  vpn_ad                   = true
  resource_group_name      = module.resource_group.resource_group_name
  subnet_id                = module.subnet.subnet_ids["GatewaySubnet"]
  vpn_client_configuration = {
    address_space        = "172.16.200.0/24"
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = "https://login.microsoftonline.com/bcffb719XXXXXXXXXXXX7ebfb2f7bdd"
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = "https://sts.windows.net/bcffb719XXXXXXXXXXXX7ebfb2f7bdd/"
  }
  #### enable diagnostic setting
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
