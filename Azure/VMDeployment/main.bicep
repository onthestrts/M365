// Deployment Parameter
param location string

// Virtual Machine Parameter
@allowed([
  'Standard_B2as_v2'
  'Standard_B2s_v2'
])
param virtualMachineSize string
param virtualMachineName string
param diskName string

// Network Interface Parameter
@description('The name of the network interface.')
param networkInterfaceName string
param networkSecurityGroupName string
param networkSecurityGroupRules array

param adminUsername string
@secure()
param adminPassword string

// Network Parameter
@description('The name of the subnet to which the network interface belongs.')
param subnetName string
@description('The ID of the virtual network to which the subnet belongs.')
param virtualNetworkId string

// Tag Parameter
@description('The mail address of the creator of the resource.')
param tagCreator string
param tagCreationDate string

// Variables
var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = virtualNetworkId
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  tags: {
    Creator: tagCreator
    CreationDate: tagCreationDate
    Description: 'LogicMonitor Collector'
    Environment: 'Production'
  }
  dependsOn: [
    networkSecurityGroup
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
  tags: {
    Creator: tagCreator
    CreationDate: tagCreationDate
    Description: 'LogicMonitor Collector'
    Environment: 'Production'
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        name: diskName
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-core'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: true
          patchMode: 'AutomaticByPlatform'
          automaticByPlatformSettings: {
            rebootSetting: 'IfRequired'
          }
        }
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  tags: {
    Creator: tagCreator
    CreationDate: tagCreationDate
    Description: 'LogicMonitor Sandbox Collector'
    Environment: 'Sandbox'
  }
}

output adminUsername string = adminUsername
