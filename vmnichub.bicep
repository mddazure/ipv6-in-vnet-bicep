param vmName string
param adminUser string
@secure()
param adminPw string
param location string
param subnetId string
param lbBePoolIdv4 string
param lbBePoolIdv6 string
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = '2019-Datacenter'
var customImage = true
var imageId = '/subscriptions/0245be41-c89b-4b46-a3cc-a705c90cd1e8/resourceGroups/image-gallery-rg/providers/Microsoft.Compute/galleries/mddimagegallery/images/windows2019-networktools/versions/2.0.0'

resource nicNoPubIP 'Microsoft.Network/networkInterfaces@2020-08-01' =  {
  name: '${vmName}-nic'
  location: location
  properties:{
    ipConfigurations: [
      {
        name: 'ipv4config0'
        properties:{
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: subnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: lbBePoolIdv4
            }
          ]      
        }
      }
      {
        name: 'ipv6config1'
        properties:{
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv6'
          subnet: {
            id: subnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: lbBePoolIdv6
            }
          ]      
        }
      }
    ]
  }
}
resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile:{
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile:  {
      imageReference: {
        //id: imageId
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'      
        }
      }
      osProfile:{
        computerName: vmName
        adminUsername: adminUser
        adminPassword: adminPw
      }
      networkProfile: {
        networkInterfaces: [
        {
          id: nicNoPubIP.id
        }
      ]
    }
  }
}
resource ext 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'ext'
  parent: vm
  location: location
  properties:{
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    protectedSettings:{}
    settings: {
        commandToExecute: 'powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server; powershell -ExecutionPolicy Unrestricted Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value $($env:computername)'
    }
  }  
}


