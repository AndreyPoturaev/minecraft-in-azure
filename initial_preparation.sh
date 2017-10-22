az configure --defaults location=$LOCATION group=$GROUP

echo "create new group"
az group create -n $GROUP

echo "create storage account"
az storage account create -n $STORAGE_ACCOUNT --sku Standard_LRS
STORAGE_CS=$(az storage account show-connection-string -n $STORAGE_ACCOUNT)
STORAGE_KEY=$(az storage account keys list -n $STORAGE_ACCOUNT --out tsv | grep key1 | cut -f3)
export AZURE_STORAGE_CONNECTION_STRING="$STORAGE_CS"
export AZURE_STORAGE_ACCESS_KEY=$STORAGE_KEY
export AZURE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT

echo "create storage container"
az storage container create -n $STORAGE_CONTAINER --public-access blob