param zoneName string

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
      cname: '${zoneName}.'
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

resource apexA 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: dnsZone
  name: '@'
  properties: {
    TTL : 3600
    ARecords: [
        { ipv4Address: '185.199.108.153' }
        { ipv4Address: '185.199.109.153' }
        { ipv4Address: '185.199.110.153' }
        { ipv4Address: '185.199.111.153' }
    ]
  }
}    

resource apexAAAA 'Microsoft.Network/dnsZones/AAAA@2018-05-01' = {
  parent: dnsZone
  name: '@'
  properties: {
    TTL : 3600
    AAAARecords: [
        { ipv6Address: '2606:50c0:8000::153' }
        { ipv6Address: '2606:50c0:8001::153' }
        { ipv6Address: '2606:50c0:8002::153' }
        { ipv6Address: '2606:50c0:8003::153' }
    ]
  }
}
