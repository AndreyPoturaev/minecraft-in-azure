export GROUP=minecraft2
export LOCATION=westeurope

#place your unique storage account name here. 
export STORAGE_ACCOUNT=$MINESERVER_STORAGE_ACCOUNT
export STORAGE_CONTAINER=server

export MVERSION=1.12.2
export DISTR_DIR=mineserver
export DISTR_ZIP=$DISTR_DIR.$MVERSION.zip

export VNET=minenet
export NSG=minensg
#place your unique DNS name here. Result server URL will be $DNS.westeurope.cloudapp.azure.com
export DNS=$MINESERVER_DNS 

export JRE="C:\Program Files\Java\jre1.8.0_141"

export AUTOMATION=mineauto
export VM_NAME=minesrv
export VM_SIZE="Standard_D1_v2"
export VM_IMAGE="MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core-smalldisk:latest"
export VM_ADMIN_LOGIN=minecraftadmin
#place your password here
export VM_ADMIN_PASSWORD=$MINESERVER_PASSWORD

export CONFIG_NAME=MinecraftServer
export CONFIG_FILE=$CONFIG_NAME.ps1
export CONFIG_ZIP=$CONFIG_NAME.ps1.zip
export CONFIG_URL=https://$STORAGE_ACCOUNT.blob.core.windows.net/$STORAGE_CONTAINER/$CONFIG_ZIP
