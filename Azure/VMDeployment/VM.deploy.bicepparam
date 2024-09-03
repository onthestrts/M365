// deployment RG: az group create --name 'padx-lmc1-csn-rg' --location 'switzerlandnorth' --tags Creator="mbraendle@baggenstos.ch" CreationDate="14.09.2023" Description="LogicMonitor Collector" Environment="Production"
// deployment: az deployment group create --name 'padx-lmc1-csn' --resource-group padx-lmc1-csn-rg --template-file .\main.bicep --parameters ./lmc.deploy.bicepparam
// Change Subscription: az account set --subscription "SubID"

using 'main.bicep'

// Deployment Parameter
param location = 'switzerlandnorth'

// Virtual Machine Parameter
param virtualMachineName = 'VM-Name-csn'
param virtualMachineSize = 'Standard_B2as_v2'
param diskName = 'VM-Name-csn-odsk'
param adminUsername = 'localadmin'
param adminPassword = 'PW'

// Network Interface Parameter
param networkInterfaceName = 'VM-Name-nic1'
param networkSecurityGroupName = 'VM-Name-csn-nsg'
param networkSecurityGroupRules = [
  {
    name: 'default-allow-rdp'
    properties: {
      priority: 1000
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]

// Network parameter
param subnetName = 'InfraSubnet'
param virtualNetworkId = 'VNETID'

// Tag parameter
param tagCreator = 'FKA'
param tagCreationDate = 'DD.MM.YYYY'

