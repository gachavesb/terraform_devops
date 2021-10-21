# Create general purpose V2 storage account

az group create --name $(terraformstoragerg) --location eastus --output json

az storage account create --name $(terraformstorageaccount) --resource-group $(terraformstoragerg) --location eastus --sku Standard_RAGRS --kind StorageV2

accountKey=$(az storage account keys list --account-name $(terraformstorageaccount) --resource-group $(terraformstoragerg) --query "[?keyName == 'key1'].value" -o tsv)

az storage container create -n tfstate --account-name $(terraformstorageaccount) --account-key $accountKey

terraform init -backend-config="storage_account_name=$(terraformstorageaccount)" -backend-config="container_name=tfstate" -backend-config="access_key=$accountKey" -backend-config="key=dev.tfstate"
