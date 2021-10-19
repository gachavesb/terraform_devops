terraform {
required_version = ">= 0.11"

backend "azurerm" {
storage_account_name = "__terraformstorageaccount__"
container_name = "terraform"
key = "terraform.tfstate"
access_key ="__storagekey__"
features{}
}
}

 resource "azurerm_resource_group" "dev" {
   name     = "PULTerraform"
   location = "West Europe"
 }
