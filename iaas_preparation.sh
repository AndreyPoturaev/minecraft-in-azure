
echo "create network security group and rules"
az network nsg create -n $NSG
az network nsg rule create --nsg-name $NSG -n AllowMinecraft --destination-port-ranges 25556 --protocol Tcp --priority 100
az network nsg rule create --nsg-name $NSG -n AllowRDP --destination-port-ranges 3389 --protocol Tcp --priority 110


echo "create vnet, nic and pip"
NIC_NAME=minesrvnic
PIP_NAME=minepip
SUBNET_NAME=servers
az network vnet create -n $VNET --subnet-name $SUBNET_NAME

az network public-ip create -n $PIP_NAME --dns-name $DNS --allocation-method Static
az network nic create --vnet-name $VNET --subnet $SUBNET_NAME --public-ip-address $PIP_NAME -n $NIC_NAME 

echo "create data disk"
DISK_NAME=minedata
az disk create -n $DISK_NAME --size-gb 10 --sku Standard_LRS
#asd MicrosoftWindowsServer:WindowsServer:2016-Nano-Server:2016.0.20170816 MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core-smalldisk:2016.127.20170822
echo "create server vm"
az vm create -n $SERVER_NAME --size "Standard_D1_v2" --image "MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core-smalldisk:latest" \
                --nics $NIC_NAME \
                --admin-username minecraftadmin --admin-password minecraftbanka1511@N \
                --os-disk-name ${SERVER_NAME}disk --attach-data-disk $DISK_NAME                