echo "create container for logs"
az storage container create -n $STORAGE_LOGS_CONTAINER --public-access blob

echo "prepare settings"
cat diagnostics/privateSettings.json | envsubst > diagnostics/thisPrivateSettings.json
cat diagnostics/publicSettings.json | envsubst > diagnostics/thisPublicSettings.json

echo "configure IaaSDiagnostics vm extension"
az vm extension set --name IaaSDiagnostics \
                    --publisher "Microsoft.Azure.Diagnostics" \
                    --resource-group $GROUP \
                    --vm-name $VM_NAME \
                    --protected-settings "diagnostics/thisPrivateSettings.json" \
                    --settings "diagnostics/thisPublicSettings.json" \
                    --version "1.11.1.0"

rm -r -f diagnostics/thisPrivateSettings.json
rm -r -f diagnostics/thisPublicSettings.json