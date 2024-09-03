# Login to your Azure account
Connect-AzAccount -UseDeviceAuthentication
# Variables
$resourceGroupName = "YourRSGName"
$vmName = "YourVMName"

# Get the VM object
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Stop the VM if it's running
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force -NoWait

# Remove the VM
Remove-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Remove the associated resources (NIC, Disks, etc.)
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName | Where-Object { $_.VirtualMachine.Id -eq $vm.Id }
if ($nic) {
    Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $resourceGroupName -Force
}

$osDisk = Get-AzDisk -ResourceGroupName $resourceGroupName | Where-Object { $_.ManagedBy -eq $vm.Id }
if ($osDisk) {
    Remove-AzDisk -ResourceGroupName $resourceGroupName -DiskName $osDisk.Name -Force
}

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName
if ($storageAccount) {
    foreach ($account in $storageAccount) {
        Remove-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $account.StorageAccountName -Force
    }
}

# Remove the Public IP address associated with the VM
$publicIp = Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName | Where-Object { $_.IpConfiguration.Id -eq $nic.IpConfigurations[0].Id }
if ($publicIp) {
    Remove-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIp.Name -Force
}

# Remove the Network Security Group (NSG)
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName | Where-Object { $_.NetworkInterfaces.Id -eq $nic.Id }
if ($nsg) {
    Remove-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name $nsg.Name -Force
}

# Remove the Virtual Network (VNet)
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName | Where-Object { $_.Subnets.Id -contains $nic.IpConfigurations[0].Subnet.Id }
if ($vnet) {
    Remove-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnet.Name -Force
}

# Finally, remove the resource group itself and all its contents
Remove-AzResourceGroup -Name $resourceGroupName -Force -Verbose

Write-Host "The VM, associated resources, and the resource group have been removed successfully."
