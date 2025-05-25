#!/bin/bash

# Variáveis - ajuste conforme seu ambiente
RESOURCE_GROUP="DevopsAppatio"
LOCATION="eastus"
VM_NAME="ChallengerVMJava"
IMAGE="Ubuntu2204"
SIZE="Standard_B1s"
ADMIN_USERNAME="azureuser"
ADMIN_PASSWORD="azureuserpass" 
DISK_SKU="Standard_LRS"
NSG_NAME="${VM_NAME}NSG"

# 1. Criar Resource Group (se não existir)
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Criar Network Security Group
az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME --location $LOCATION

# 3. Remover regra padrão default-allow-ssh para evitar conflito
az network nsg rule delete --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name default-allow-ssh

# 4. Criar regra para liberar SSH (porta 22) na NSG
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name AllowSSH \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --description "Allow SSH"

# 5. Criar regra para liberar HTTP (porta 8080)
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow8080 \
  --priority 1010 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 8080 \
  --description "Allow port 8080"

# 6. Criar VM com autenticação por senha, associando a NSG
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --nsg $NSG_NAME \
  --storage-sku $DISK_SKU \
  --public-ip-sku Standard \
  --location $LOCATION \
  --output json

# 7. Mostrar IP público da VM
az vm list-ip-addresses --resource-group $RESOURCE_GROUP --name $VM_NAME --query "[].virtualMachine.network.publicIpAddresses[].ipAddress" -o tsv
