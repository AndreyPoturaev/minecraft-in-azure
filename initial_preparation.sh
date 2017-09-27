az configure --defaults location=$LOCATION group=$GROUP

echo "create new group"
az group create -n $GROUP

echo "create storage account"
az storage account create -n $STORAGE_ACCOUNT --sku Standard_LRS
STORAGE_CS=$(az storage account show-connection-string -n $STORAGE_ACCOUNT)
export AZURE_STORAGE_CONNECTION_STRING="$STORAGE_CS"

echo "create storage container"
az storage container create -n $STORAGE_CONTAINER --public-access blob


