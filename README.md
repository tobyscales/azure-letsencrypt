# azure-letsencrypt
Create a new Azure Container Instance that runs nginx + letsencrypt, and automatically renews the certificate.

# Azure-LetsEncrypt

Using the excellent docker image from [ilhicas](https://github.com/Ilhicas/nginx-letsencrypt) and my handy [arm-bootstrapper](https://github.com/tescales/azure-bootstrapper-arm), this template creates an nginx [Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/) in Azure that automatically retrieves and applies a certificate from LetsEncrypt for the given domain, then opens the specified port for inbound traffic (443 by default).

All configuration is done through the ARM template; however if you need to update your configuration in the future you can simply browse to the storage account this creates and update your default.conf, then restart your Azure Container Instance.

You can also see this technique used effectively in my [one-click deployment of the Firefox Sync Service](https://github.com/tescales/ffoxsync).

---
services: azure-container-instances,azure-files,nginx,letsencrypt
platforms: azure
author: tescales
---
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftescales%2Fazure-letsencrypt%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

