targetScope = 'subscription'   // this file creates resource groups

@minLength(3)
@maxLength(12)
param labName string
param owner string
param allowedSshSource string
param location string = 'japaneast'

@minValue(1)
@maxValue(7)
param lifetimeDays int = 3

param deploymentTime string = utcNow()   // utcNow() is only allowed as a param default

// e.g. deployed 2026-11-23 with 3 days -> '2026-11-26'
var expiresOn = dateTimeAdd(deploymentTime, 'P${lifetimeDays}D', 'yyyy-MM-dd')

// These tags are what the policy and auto-delete steps will rely on later
var tags = {
  labPlatform: 'true'
  owner: owner
  expiresOn: expiresOn
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-lab-${labName}'
  location: location
  tags: tags
}

module network 'modules/network.bicep' = {
  scope: rg                // deploy the module INTO the new resource group
  name: 'lab-network'
  params: {
    labName: labName
    location: location
    tags: tags
    allowedSshSource: allowedSshSource
  }
}

output resourceGroupName string = rg.name
output expiresOn string = expiresOn
