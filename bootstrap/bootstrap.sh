#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT

echo Connecting to Azure Storage: $AZURE_STORAGE_ACCOUNT
echo Resource Group: $AZURE_RESOURCE_GROUP

#this function escapes the passed-in path to work with sed
function sedPath {  
    local path=$((echo $1|sed -r 's/([\$\.\*\/\[\\^])/\\\1/g'|sed 's/[]]/\[]]/g')>&1) 
    echo "$path"
    }
echo Shared State Storage: $AZURE_STORAGE_ACCOUNT
echo Nginx Configured Domain: $PUBLIC_DOMAIN
echo Nginx Configured Port: $PUBLIC_PORT
echo Nginx Mode: $NGINX_MODE

#set default storage account permissions
echo Setting up Nginx storage accounts...
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-config --permissions dlrw
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-html --permissions dlrw
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-certs --permissions dlrw

#clean up env vars for sed
PUBLIC_DOMAIN=$(sedPath $PUBLIC_DOMAIN)
PUBLIC_PORT=$(sedPath $PUBLIC_PORT)
PRIVATE_ADDRESS=$(sedPath $PRIVATE_ADDRESS)

echo Cloning config files...
git clone -n https://github.com/$THIS_REPO /

# pass env variables through to config scripts
echo Updating config files...
sed -i 's/{PUBLIC_DOMAIN}/'$PUBLIC_DOMAIN'/g' /$THIS_REPO/conf/*.*
sed -i 's/{PUBLIC_PORT}/'$PUBLIC_PORT'/g' /$THIS_REPO/conf/*.*
sed -i 's/{PRIVATE_ADDRESS}/'$PRIVATE_ADDRESS'/g' /$THIS_REPO/conf/*.*

echo Uploading config files...
cp /$BOOTSTRAP_REPO/conf/$NGINX_MODE.conf default.conf
nginxconfig=$(az storage file exists --share-name nginx-config --path default.conf --query exists)
indexhtml=$(az storage file exists --share-name nginx-html --path index.html --query exists)

if [ ! $nginxconfig ]; then
az storage file upload --source default.conf --share-name nginx-config --no-progress
else 
echo "  ** default.conf file exists, will not update. ** "
fi 

if [ ! $indexhtml ]; then
az storage file upload --source /$BOOTSTRAP_REPO/html/index.html --share-name nginx-html --no-progress
else 
echo "  ** index.html file exists, will not update. ** "
fi 

echo "### Configuration complete! ###"

#"set" | az container exec --exec-command /bin/sh -n $AZURE_RESOURCE_GROUP -g $AZURE_RESOURCE_GROUP 

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
#tail -f /dev/null