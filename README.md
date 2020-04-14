# azure-letsencrypt
Create a new Azure Container Instance that runs nginx + letsencrypt, and automatically renews the certificate.

# Overview

Using the excellent docker image from [ilhicas](https://github.com/Ilhicas/nginx-letsencrypt) and my handy [arm-bootstrapper](https://github.com/tescales/azure-bootstrapper-arm), this template creates an nginx [Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/) in Azure that automatically retrieves and applies a certificate from LetsEncrypt for the given domain, then opens the specified port for inbound traffic (443 by default).

All configuration is done through the ARM template; however if you need to update your configuration in the future you can simply browse to the storage account this creates and update your default.conf, then restart your Azure Container Instance.

You can also see this technique used effectively in my [one-click deployment of the Firefox Sync Service](https://github.com/tescales/ffoxsync).


| Parameter Name    | What it does   | Default |
| --- | --- | --- |
| gitHubUser/gitHubRepo    | indicates where the bootstrap.sh and config files will be taken from |  defaults to this repo |
| subscriptionId/aadTenantId | used for provisioning appropriate access to the deployment container | defaults to current |
| roleName   | used to assign access to the deployment container  | defaults to Owner (for this Resource Group only) |
| newVaultName | creates a new KV and stores deployment secrets there | defaults to none |
| configurationStorageAccount | name for new Azure Files storage account | defaults to Resource Group Name + "stor" |
| configurationStorageShareName | name for Azure Files container where config data lives | defaults to "nginx" |
| publicDomainName | public DNS record for your server | required |
| publicPort | publicly-exposed port for your server | defaults to 443 |
| privateAddress | private IP or nameserver to route requests to | use http(s):// and optionally specify :port |
| ssl-email | email address to use for LetsEncrypt registration | defaults to certbot@eff.org |
| ssl-env | LetsEncrypt environment to use for registration | defaults to blank; set this to "staging" for testing |


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftescales%2Fazure-letsencrypt%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>

----
services: `azure-container-instances,azure-files,nginx,letsencrypt`
----


