echo "prepare dsc extension settings"
cat MinecraftServerDSCSettings.json | envsubst > ThisMinecraftServerDSCSettings.json

echo "configure vm"
az vm extension set \
   --name DSC \
   --publisher Microsoft.Powershell \
   --version 2.7 \
   --vm-name $SERVER_NAME \
   --resource-group $GROUP \
   --settings ThisMinecraftServerDSCSettings.json
rm -f ThisMinecraftServerDSCSettings.json