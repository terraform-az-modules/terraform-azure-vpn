<!-- BEGIN_TF_DOCS -->

# Terraform VPN Example

This readme demonstrates the structure and requirements for a Terraform configuration deploying VPN, VNet, Subnet, Resource Group, and Log Analytics resources in Azure.

---

## ✅ Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0  |

---

## 🔌 Providers

No providers are explicitly defined in this example.

---

## 📦 Modules

| Name             | Source                                    | Version |
|------------------|-------------------------------------------|---------|
| log-analytics    | clouddrove/log-analytics/azure            | 2.0.0   |
| resource_group   | terraform-az-modules/resource-group/azure | 1.0.0   |
| subnet           | terraform-az-modules/subnet/azure         | 1.0.0   |
| vnet             | terraform-az-modules/vnet/azure           | 1.0.0   |
| vpn              | ../../                                    | n/a     |

---

## 🏗️ Resources

No additional resources are directly created in this example.

---

## 🔧 Inputs

No input variables are defined in this example.

---

## 📤 Outputs

| Name                                 | Description                                   |
|---------------------------------------|-----------------------------------------------|
| local_network_gw_connection_id        | The ID of the Virtual Network Gateway Connection. |
| local_network_gw_id                   | The ID of the Local Network Gateway.          |
| vpn_gw_id                             | The ID of the Virtual Network Gateway.        |

<!-- END_TF_DOCS -->
