provider "azurerm" {
  features {}
}

locals {
  name        = "app"
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
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.0"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
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

  subnets = [{
    name            = "GatewaySubnet"
    subnet_prefixes = ["10.0.1.0/24"]
    route_table     = "rt-test"
  }]

  enable_route_table = true
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
## Following module will deploy site to site vpn with ssl certificate in azure infratsructure.
##-----------------------------------------------------------------------------
module "vpn" {
  depends_on                  = [module.vnet]
  source                      = "../../"
  name                        = local.name
  environment                 = local.environment
  sts_vpn                     = true
  resource_group_name         = module.resource_group.resource_group_name
  subnet_id                   = module.subnet.subnet_ids["GatewaySubnet"]
  gateway_type                = "Vpn"
  public_ip_sku               = "Standard"
  public_ip_allocation_method = "Static"
  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
  local_networks = [
    {
      local_gw_name         = "app-test-onpremise"
      local_gateway_address = "20.232.135.45"
      local_address_space   = ["30.1.0.0/16"]
      shared_key            = "xpCGkHTBQmDvZK9HnLr7DAvH"
    },
  ]
  local_networks_ipsec_policy = {
    dh_group         = "ECP384"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "ECP384"
    sa_datasize      = null
    sa_lifetime      = 3600
  }
}
