<!-- BEGIN_TF_DOCS -->

# Terraform Azure VPN Example

This example demonstrates a Terraform configuration for deploying Azure VPN, VNet, Subnet, Resource Group, and Log Analytics resources.

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

| Name        | Description                              |
|-------------|------------------------------------------|
| vpn_gw_id   | The ID of the Virtual Network Gateway.   |

<!-- END_TF_DOCS -->
