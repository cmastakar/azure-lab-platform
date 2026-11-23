// Values passed in from main.bicep
param labName string
param location string
param tags object
param allowedSshSource string   // your IP, e.g. 203.0.113.10/32

// NSG = firewall rules. Allow SSH only from your IP.
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-lab-${labName}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-From-Owner'
        properties: {
          priority: 100            // lower number = checked first
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: allowedSshSource
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-lab-${labName}'
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ '10.50.0.0/16' ] }
    subnets: [
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: '10.50.1.0/24'
          networkSecurityGroup: { id: nsg.id }   // attach the NSG to the subnet
        }
      }
    ]
  }
}

// main.bicep will need the subnet ID later for the VM
output subnetId string = vnet.properties.subnets[0].id
