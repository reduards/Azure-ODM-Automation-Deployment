# Function app and storage account names must be unique.

# Variable block
randomIdentifier=$RANDOM$RANDOM
subscriptionName="reduards_sub"
location="westeurope"
resourceGroup="msdocs-azure-functions-rg-$randomIdentifier"
tag="functions-cli-mount-files-storage-linux"
export AZURE_STORAGE_ACCOUNT="msdocsstorage$randomIdentifier"
functionApp="msdocs-serverless-function-$randomIdentifier"
skuStorage="Standard_LRS"
functionsVersion="4"
pythonVersion="3.9" #Allowed values: 3.7, 3.8, and 3.9
share="msdocs-fileshare-$randomIdentifier"
directory="msdocs-directory-$randomIdentifier"
shareId="msdocs-share-$randomIdentifier"
mountPath="/mounted-$randomIdentifier"
keyvault="keyvault-$randomIdentifier"
vnet="drone-vnet"
subnet="drone-subnet"

az login

#Deplpoyment subscription
az account set --subscription $subscriptionName

# Create a resource group
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tags $tag

# Create an Azure storage account in the resource group.
echo "Creating $AZURE_STORAGE_ACCOUNT"
az storage account create --name $AZURE_STORAGE_ACCOUNT --location "$location" --resource-group $resourceGroup --sku $skuStorage

# Set the storage account key as an environment variable. 
export AZURE_STORAGE_KEY=$(az storage account keys list -g $resourceGroup -n $AZURE_STORAGE_ACCOUNT --query '[0].value' -o tsv)

# Create a serverless function app in the resource group. and set managaged identity
echo "Creating $functionApp"
az functionapp create --name $functionApp --storage-account $AZURE_STORAGE_ACCOUNT --consumption-plan-location "$location" --resource-group $resourceGroup --os-type Linux --runtime python --runtime-version $pythonVersion --functions-version $functionsVersion --assign-identity

# Work with Storage account using the set env variables.
# Create a share in Azure Files.
echo "Creating $share"
az storage share create --name $share 

# Create a directory in the share.
echo "Creating $directory in $share"
az storage directory create --share-name $share --name $directory

#upload images to share
az storage file upload-batch --destination https://$AZURE_STORAGE_ACCOUNT.file.core.windows.net/$share --destination-path $directory --source images/ --account-key $AZURE_STORAGE_KEY

# Create webapp config storage account
echo "Creating $AZURE_STORAGE_ACCOUNT"
az webapp config storage-account add \
--resource-group $resourceGroup \
--name $functionApp \
--custom-id $shareId \
--storage-type AzureFiles \
--share-name $share \
--account-name $AZURE_STORAGE_ACCOUNT \
--mount-path $mountPath \
--access-key $AZURE_STORAGE_KEY

# Create Key Vault
az keyvault create --name $keyvault --resource-group $resourceGroup --location $location --enable-rbac-authorization true

#Create random password for VM
az keyvault secret set --vault-name $keyvault --name "localadminpassword" --value "hVFkk965BuUv"

#create logic app
#az logicapp create -g $resourceGroup -p MyPlan -n email-notification -s $AZURE_STORAGE_ACCOUNT

#Create logic app workflow
az logic workflow create --resource-group $resourceGroup --location $location --name "email-notification" --definition "logicappconent.json"

#Create VNET where Virtual Machine will be deployed

az network vnet create -g $resourceGroup -n $vnet --subnet-name $subnet

#Create RBAC roles for azure function managed identity, create vm and read secrets
spID=$(az resource list -n $functionApp --resource-group $resourceGroup --query [*].identity.principalId --out tsv)

az role assignment create --assignee $spID --role 'Contributor' --scope /subscriptions/300b6cba-3620-4f76-b22b-d234300d0106/resourceGroups/$resourceGroup

az role assignment create --assignee $spID --role 'Key Vault Secrets Officer' --scope /subscriptions/300b6cba-3620-4f76-b22b-d234300d0106/resourceGroups/$resourceGroup