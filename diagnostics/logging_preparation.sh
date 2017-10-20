echo "create container for logs"
#az storage container create -n $STORAGE_LOGS_CONTAINER --public-access blob

echo "configure IaaSDiagnostics vm extension"
az vm extension set --name IaaSDiagnostics \
                    --publisher "Microsoft.Azure.Diagnostics" \
                    --resource-group $GROUP \
                    --vm-name $VM_NAME \
                    --protected-settings "diagnostics/privateSettings.json" \
                    --settings "diagnostics/publicSettings.json" \
                    --version "1.11.1.0"