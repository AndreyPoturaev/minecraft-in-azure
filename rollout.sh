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
