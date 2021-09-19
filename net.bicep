param zoneName string = 'henrikbecker.net'
var location = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${zoneName}.ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: zoneName
  location: 'global'
  dependsOn: [
    publicIp
  ]
}

resource aRecords 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: '${zoneName}/@'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600
    targetResource: {
      id: publicIp.id
    }
  }
}
 
resource wwwCname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${zoneName}/www'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: 'handiman.github.io.'
    }
  }
}

resource sendGridEm 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${zoneName}/em931'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: 'u23254236.wl237.sendgrid.net.'
    }
  }
}

resource sendGridS1 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${zoneName}/s1._domainkey'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600 
    CNAMERecord: {
      cname: 's1.domainkey.u23254236.wl237.sendgrid.net.'
    }
  }
}

resource sendGridS2 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${zoneName}/s2._domainkey'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600 
    CNAMERecord: {
      cname: 's2.domainkey.u23254236.wl237.sendgrid.net.'
    }
  }
}

resource txtRecords 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: '${zoneName}/@'
  dependsOn: [
    dnsZone
  ]
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          'google-site-verification=O0mm2i3lLjHQBC1L6jhBXg6MaS1Mi-KSOcfkSzGiYv8'
        ]
      }
    ]
  }
}
