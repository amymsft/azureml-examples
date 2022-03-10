### Part of automated testing: only required when this script is called via vm run-command invoke inorder to gather the parameters ###
set -e
for args in "$@"
do
    keyname=$(echo $args | cut -d ':' -f 1)
    result=$(echo $args | cut -d ':' -f 2)
    export $keyname=$result
done

# <setup_docker_az_cli> 
# setup docker
sudo apt-get update -y && sudo apt install docker.io -y && sudo snap install docker && docker --version
# setup az cli and ml extension
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && az extension add --upgrade -n ml -y
# </setup_docker_az_cli> 

# login using az cli. 
### NOTE to user: use `az login` - and do NOT use the below command (it requires setting up of user assigned identity). ###
az login --identity -u /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$IDENTITY_NAME

# <configure_defaults> 
# configure cli defaults
az account set --subscription $SUBSCRIPTION
az configure --defaults group=$RESOURCE_GROUP workspace=$WORKSPACE location=$LOCATION
# </configure_defaults> 

# <clone_sample> 
# Clone the samples repo. This is needed to build the image and create the managed online deployment.
mkdir -p /home/samples; git clone -b $GIT_BRANCH --depth 1 https://github.com/Azure/azureml-examples.git /home/samples/azureml-examples -q
# </clone_sample> 