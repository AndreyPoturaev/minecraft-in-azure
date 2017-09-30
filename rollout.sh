#set variables
. env.sh
#prepare server distrib
. prepare_distr.sh
#create group, storage account, etc
. initial_preparation.sh
#upload server distrib
echo "upload server distrib"
az storage blob upload -f $DISTR_ZIP -c $STORAGE_CONTAINER -n $DISTR_ZIP
rm -f $DISTR_ZIP
#infrastructure rollout
. iaas_preparation.sh
#prepare config
. prepare_config.sh
#upload server config
echo "upload server config"
az storage blob upload -f $CONFIG_ZIP -c $STORAGE_CONTAINER -n $CONFIG_ZIP
rm -f $CONFIG_ZIP
#server configuration
. server_configuration.sh