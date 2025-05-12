resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'demo-app-plan'
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'demo-web-app'
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
