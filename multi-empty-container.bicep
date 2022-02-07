targetScope = 'resourceGroup'

var container1name = 'msagwcc1'
var container1image = 'techfellow/ipcheck:ubuntu'
var container2name = 'msagwcc2'
var container2image = 'techfellow/ipcheck:ubuntu'

resource ACI_volume 'Microsoft.ContainerInstance/containerGroups@2020-11-01' = {
  name: 'volume-demo'
  location: resourceGroup().location
  properties: {
    // imageRegistryCredentials: [
    //   {
    //     server: 'liinacr.azurecr.io'
    //     username: 'liinacr'
    //     password: 'nl=b32u0Nex=2fNNnJxtVvUcOjwGa+la'
    //   }
    // ]
    containers: [
      {
        name: container1name
        properties: {
          image: container1image
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          ports: [
            {
              port: 80
            }
          ]
          // volumeMounts: [
          //   {
          //     name: 'emptydir1'
          //     mountPath: '/usr/share/nginx/html/hostname/'
          //   }
          // ]
        }
      }
      {
        name: container2name
        properties: {
          image: container2image
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          ports: [
            {
              port: 81
            }
          ]
          // volumeMounts: [
          //   {
          //     name: 'emptydir1'
          //     mountPath: '/usr/share/nginx/html/hostname/'
          //   }
          // ]
          // environmentVariables: [
          //   {
          //     name: 'VERSION'
          //     value: 'v2'
          //   }
          // ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
    volumes: [
      // {
      //   name: 'emptydir1'
      //   emptyDir: {}
      // }
    ]
  }
}
