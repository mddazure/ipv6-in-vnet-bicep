# Dual stack IPv4/IPv6 VNET topology 

This lab provides a simple environment to experiment with IPv6 in VNETs. It is written in Bicep :muscle:.

**Lab content**

- Dual stack IP4/IPv6 hub VNET.
- Dual stack IP4/IPv6 spoke VNETs peered to the hub.
- Pair of VMs in the hub, each running a web server.
- Public IPv4 and IPv6 prefixes.
- Internet-facing STANDARD Load Balancer with IPv4 and IPv6 Public IP addresses, in front of the hub VMs.
- A single VM in each of the Spokes, each with an IPv4 and an IPv6 PIP.

![image](images/ipv6-in-vnet-bicep.png)

**Deployment**
- Log in to Azure Cloud Shell at https://shell.azure.com/ and select Bash.
- Ensure Azure CLI and extensions are up to date:
  
  `az upgrade --yes`
  
- If necessary select your target subscription:
  
  `az account set --subscription <Name or ID of subscription>`
  
- Clone the  GitHub repository:
  
  `git clone https://github.com/mddazure/ipv6-in-vnet-bicep`
  
- Change directory:
  
  `cd ./ipv6-in-vnet-bicep`

- Create resource group:

  `az group create --name ipv6 --location westeurope`

- Deploy the bicep template:

  `az deployment group create --name ipv6depl --resource-group ipv6 --template-file ipv6networkdeploy.bicep`


