# Login to Azure Tenant
Az login --use-device-code

# VM and RG delete (not forced) 
az vm delete --resource-group pbom-lmc2-csn-rg --name pbom-lmc2-csn --force-deletion none