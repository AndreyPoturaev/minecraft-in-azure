echo "prepare server configuration"
#powershell "Save-Module -Path configuration -Name xPSDesiredStateConfiguration -RequiredVersion 7.0.0.0 -Force"
#powershell "Save-Module -Path configuration -Name xNetworking -RequiredVersion 5.1.0.0 -Force"
#powershell "Save-Module -Path configuration -Name xStorage -RequiredVersion 3.2.0.0 -Force"
curl -s -L -o configuration/xPSDesiredStateConfiguration.zip "https://www.powershellgallery.com/api/v2/package/xPSDesiredStateConfiguration/7.0.0.0"
curl -s -L -o configuration/xNetworking.zip "https://www.powershellgallery.com/api/v2/package/xNetworking/5.1.0.0"
curl -s -L -o configuration/xStorage.zip "https://www.powershellgallery.com/api/v2/package/xStorage/3.2.0.0"
cd configuration

unzip -q xPSDesiredStateConfiguration.zip -d xPSDesiredStateConfiguration
rm -r xPSDesiredStateConfiguration.zip
unzip -q xNetworking.zip -d xNetworking
rm -r xNetworking.zip
unzip -q xStorage.zip -d xStorage
rm -r xStorage.zip

zip -r -q ../$CONFIG_ZIP . *
rm -r -f xPSDesiredStateConfiguration
rm -r -f xNetworking
rm -r -f xStorage
cd ../