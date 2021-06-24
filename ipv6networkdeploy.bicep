param location string = 'westeurope'
param Spoke1v4AddressRange string = '10.1.0.0/16'
param Spoke1v6AddressRange string = 'ac1:cab:deca::/48'
param Spoke1subnet1v4AddressRange string = '10.1.0.0/24'
param Spoke1subnet1v6AddressRange string = 'ac1:cab:deca:deed::/64'
param Spoke2v4AddressRange string = '10.2.0.0/16'
param Spoke2v6AddressRange string = 'ac2:cab:deca::/48'
param Spoke2subnet1v4AddressRange string = '10.2.0.0/24'
param Spoke2subnet1v6AddressRange string = 'ac2:cab:deca:deed::/64'
param Hubv4AddressRange string = '10.0.0.0/16'
param Hubv6AddressRange string = 'ac0:cab:deca::/48'
param Hubsubnet1v4AddressRange string = '10.0.0.0/24'
param Hubsubnet1v6AddressRange string = 'ac0:cab:deca:deed::/64'
param HubsubnetBastionRange string = '10.0.255.0/24'
param adminUsername string = 'AzureAdmin'
@secure()
param adminPassword string = 'ipV6demo-2021'

//public IP prefixes
resource prefixIpV4 'Microsoft.Network/publicIPPrefixes@2020-11-01' = {
  name: 'prefixIpV4'
  location: location
  sku:{
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: 28
    publicIPAddressVersion: 'IPv4'
  }
}
resource prefixIpV6 'Microsoft.Network/publicIPPrefixes@2020-11-01' = {
  name: 'prefixIpV6'
  location: location
  sku:{
    name:'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: 125
    publicIPAddressVersion: 'IPv6'
    
  }
}

// public IPs from prefixes
resource lbPubIpV4 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'lbPubIpV4'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv4'
    publicIPPrefix: {
      id: prefixIpV4.id
    }
  }
}
resource lbPubIpV6 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'lbPubIpV6'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv6'
    publicIPPrefix: {
      id: prefixIpV6.id
    }
  }
}
resource pubIpV41 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'instancePubIpV4-1'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv4'
    publicIPPrefix: {
      id: prefixIpV4.id
    }
  }
}
resource pubIpV42 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'instancePubIpV4-2'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv4'
    publicIPPrefix: {
      id: prefixIpV4.id
    }
  }
}

resource pubIpV61 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'instancePubIpv6-1'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv6'
    publicIPPrefix: {
      id: prefixIpV6.id
    }
  }
}
resource pubIpV62 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'instancePubIpv6-2'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv6'
    publicIPPrefix: {
      id: prefixIpV6.id
    }
  }
}

resource bastionPubIpV4 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'bastionPubIpV4'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static' 
    publicIPAddressVersion: 'IPv4'
    publicIPPrefix: {
      id: prefixIpV4.id
    }
  }

}

// Load Balancer
resource hubLB 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: 'hub-LB'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties:{
    backendAddressPools: [
      {
        name: 'bepoolv4'
      }
      {
        name: 'bepoolv6'
      }
    ]
    frontendIPConfigurations:[
      {
        name: 'ipv4-frontend'
        properties: {
          publicIPAddress: {
            id: lbPubIpV4.id
          } 
        }
      }
      {
          name: 'ipv6-frontend'
          properties: {
            publicIPAddress: {
              id: lbPubIpV6.id   
            }       
        }
      }
    ]
    probes:[
      {
        name: 'probe80'
        properties:{
          port: 80
          protocol: 'Tcp'
        }
      }
    ]
    loadBalancingRules:[
      {
        name: 'rulev4'
        properties:{
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations','hub-LB','ipv4-frontend')
           }
           backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv4')
           }
           frontendPort: 80
           backendPort: 80
           protocol: 'Tcp'
           probe: {
             id: resourceId('Microsoft.Network/loadBalancers/probes','hub-LB','probe80')
        }
      }
    }
        {
          name: 'rulev6'
          properties:{
            frontendIPConfiguration: {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations','hub-LB','ipv6-frontend')
             }
             backendAddressPool: {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv6')
             }
             frontendPort: 80
             backendPort: 80
             protocol: 'Tcp'
          }
      }
    ]   
    }
}
// VNETs
resource dsSpoke1 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'dsSpoke1'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        Spoke1v4AddressRange
        Spoke1v6AddressRange
      ]
    }
    subnets:[
      {
      name: 'subnet1'
      properties:{
        addressPrefixes:[
          Spoke1subnet1v4AddressRange
          Spoke1subnet1v6AddressRange
        ]
        networkSecurityGroup: {
          id: nsg.id
        }
      }
    }     
    ]
  }
}
resource dsSpoke2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'dsSpoke2'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        Spoke2v4AddressRange
        Spoke2v6AddressRange
      ]
    }
    subnets:[
      {
      name: 'subnet1'
      properties:{
        addressPrefixes:[
          Spoke2subnet1v4AddressRange
          Spoke2subnet1v6AddressRange
        ]
        networkSecurityGroup: {
          id: nsg.id
        }
      }
    }     
    ]
  }
}
resource dsHub 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'dsHub'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        Hubv4AddressRange
        Hubv6AddressRange
      ]
    }
    subnets:[
      {
      name: 'subnet1'
      properties:{
        addressPrefixes:[
          Hubsubnet1v4AddressRange
          Hubsubnet1v6AddressRange
        ]
        networkSecurityGroup: {
          id: nsg.id
        }
      }
    }
       {
      name: 'AzureBastionSubnet'
      properties:{
        addressPrefix: HubsubnetBastionRange
      }  
    }     
    ]
  }
}
//NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'nsg'
  location: location
  properties:{
    securityRules: [
      {
        name: 'allow80in'
        properties:{
          priority: 150
          direction: 'Inbound'
          protocol: 'Tcp'
          access: 'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
          }
      }
    ]
  }
}
//PEERINGS
resource spoke1hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: 'spoke1-hub'
  parent: dsSpoke1
  properties:{
    remoteVirtualNetwork:{
      id:dsHub.id
    }
  }
}
resource hubspoke1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: 'hub-spoke1'
  parent: dsHub
  properties:{
    remoteVirtualNetwork:{
      id:dsSpoke1.id
    }
  }
}
resource spoke2hub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: 'spoke2-hub'
  parent: dsSpoke2
  properties:{
    remoteVirtualNetwork:{
      id:dsHub.id
    }
  }
}
resource hubspoke2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
  name: 'hub-spoke2'
  parent: dsHub
  properties:{
    remoteVirtualNetwork:{
      id:dsSpoke2.id
    }
  }
}
//VMs
module BeVM1mod 'vmnichub.bicep' = {
  name: 'BeVM1-modname'
  params: {
    vmName: 'BeVM1'
    adminUser: adminUsername
    adminPw: adminPassword
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets','dsHub','subnet1')
    lbBePoolIdv4: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv4')
    lbBePoolIdv6: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv6')
  } 
}
module BeVM2mod 'vmnichub.bicep' = {
  name: 'BeVM2-modname'
  params: {
    vmName: 'BeVM2'
    adminUser: adminUsername
    adminPw: adminPassword
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets','dsHub','subnet1')
    lbBePoolIdv4: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv4')
    lbBePoolIdv6: resourceId('Microsoft.Network/loadBalancers/backendAddressPools','hub-LB','bepoolv6')
  } 
}

module spoke1VM 'vmnicspokes.bicep' = {
  name: 'spoke1VM'
  params: {
    vmName: 'spoke1VM'
    adminUser: adminUsername
    adminPw: adminPassword
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets','dsSpoke1','subnet1')
    pubIpv4Id: pubIpV41.id
    pubIpv6Id: pubIpV61.id 
  } 
}
module spoke2VM 'vmnicspokes.bicep' = {
  name: 'spoke2VM'
  params: {
    vmName: 'spoke2VM'
    adminUser: adminUsername
    adminPw: adminPassword
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets','dsSpoke2','subnet1')
    pubIpv4Id: pubIpV42.id
    pubIpv6Id: pubIpV62.id 
  } 
}

//Bastion
resource hubBastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: 'hubBastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets','dsHub','AzureBastionSubnet')
          } 
          publicIPAddress: {
            id: bastionPubIpV4.id
          }
        }
      }
    ]
  }
}

//Output
output lbPubIpV4 string = lbPubIpV4.properties.ipAddress
output lbPubIpV6 string = lbPubIpV6.properties.ipAddress
output pubIpV61 string = pubIpV61.properties.ipAddress
output pubIpV62 string = pubIpV62.properties.ipAddress
output pubIpV41 string = pubIpV41.properties.ipAddress
output pubIpV42 string = pubIpV42.properties.ipAddress
output bastionPubIpV4 string = bastionPubIpV4.properties.ipAddress


