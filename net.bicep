param zoneName string = 'henrikbecker.net'
param location string = resourceGroup().location

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
}
 
resource wwwCname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'www'
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: 'handiman.github.io.'
    }
  }
}

resource sendGridEm 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 'em931'
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: 'u23254236.wl237.sendgrid.net.'
    }
  }
}

resource sendGridS1 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 's1._domainkey'
  properties: {
    TTL: 3600 
    CNAMERecord: {
      cname: 's1.domainkey.u23254236.wl237.sendgrid.net.'
    }
  }
}

resource sendGridS2 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: 's2._domainkey'
  properties: {
    TTL: 3600 
    CNAMERecord: {
      cname: 's2.domainkey.u23254236.wl237.sendgrid.net.'
    }
  }
}

resource txtRecords 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  parent: dnsZone
  name: '@'
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
