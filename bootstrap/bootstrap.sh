#!/bin/bash
# additional environment variables available: $AZURE_SUBSCRIPTION_ID, $AZURE_AADTENANT_ID and $AZURE_KEYVAULT

echo Location: $AZURE_LOCATION
echo Resource Group: $AZURE_RESOURCE_GROUP

# cribbed from http://fahdshariff.blogspot.com/2014/02/retrying-commands-in-shell-scripts.html
# Retries a command on failure. 
# $1 - the max number of attempts
# $2... - the command to run

retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1
    until $cmd
    do
        if ((attempt_num==max_attempts))
        then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $((attempt_num++))
        fi
    done
}

retry 5 az login --identity

az configure --defaults location=$AZURE_LOCATION
az configure --defaults group=$AZURE_RESOURCE_GROUP

cd /$BOOTSTRAP_REPO

### Custom Code goes here 

#this function escapes the passed-in path to work with sed
function sedPath {  
    local path=$((echo $1|sed -r 's/([\$\.\*\/\[\\^])/\\\1/g'|sed 's/[]]/\[]]/g')>&1) 
    echo "$path"
    }
echo Shared State Storage: $AZURE_STORAGE_ACCOUNT
echo Nginx Configured Domain: $PUBLIC_DOMAIN
echo Nginx Configured Port: $PUBLIC_PORT
echo Nginx Mode: $NGINX_MODE

echo Setting up Nginx storage accounts...
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-config --permissions dlrw
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-html --permissions dlrw
az storage share policy create -n $AZURE_STORAGE_ACCOUNT -s nginx-certs --permissions dlrw

#clean up env vars for sed
PUBLIC_DOMAIN=$(sedPath $PUBLIC_DOMAIN)
PUBLIC_PORT=$(sedPath $PUBLIC_PORT)
PRIVATE_ADDRESS=$(sedPath $PRIVATE_ADDRESS)

# pass env variables through to config scripts
echo Updating config files...
sed -i 's/{PUBLIC_DOMAIN}/'$PUBLIC_DOMAIN'/g' /$BOOTSTRAP_REPO/conf/*.*
sed -i 's/{PUBLIC_PORT}/'$PUBLIC_PORT'/g' /$BOOTSTRAP_REPO/conf/*.*
sed -i 's/{PRIVATE_ADDRESS}/'$PRIVATE_ADDRESS'/g' /$BOOTSTRAP_REPO/conf/*.*

if [[ az storage file exists --share-name nginx-config --path $NGINX_MODE.conf ]]; then
echo $NGINX_MODE file exists
fi 
az storage file upload --source /$BOOTSTRAP_REPO/conf/$NGINX_MODE.conf --share-name nginx-config --no-progress
az storage file upload --source /$BOOTSTRAP_REPO/html/index.html --share-name nginx-html --no-progress


#"set" | az container exec --exec-command /bin/sh -n $AZURE_RESOURCE_GROUP -g $AZURE_RESOURCE_GROUP 

## uncomment the below statement to troubleshoot your startup script interactively in ACI (on the Connect tab)
#tail -f /dev/null