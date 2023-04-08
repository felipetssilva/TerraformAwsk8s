provider "azurerm" {
  subscription_id = "0cfe2870-d256-4119-b0a3-16293ac11bdc" #az account show --query id -o tsv
#  client_id       = "<client-id>"
  client_secret   = "stI8Q~md1Y2J01nJKct_sZs1IQVUKlKfpuQGObyV"
  tenant_id       = "84f1e4ea-8554-43e1-8709-f0b8589ea118" #az account show --query tenantId-o tsv
  features {}
  skip_provider_registration = true
}


resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "1-7aed190b-playground-sandbox" 

  subnet {
    name           = "k8s-master-subnet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "k8s-worker-subnet"
    address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_public_ip" "k8s-master-pip" {
  name                = "k8s-master-pip"
  location            = "East US"
  resource_group_name = "1-7aed190b-playground-sandbox"
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "k8s-nsg" {
  name                = "k8s-nsg"
  location            = "East US"
  resource_group_name = "1-7aed190b-playground-sandbox"


  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "k8s-cluster"
  location            = "East US"
  resource_group_name = "1-7aed190b-playground-sandbox" 
  dns_prefix          = "k8s-cluster"
  linux_profile {
    admin_username = "k8sadmin"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0wHf49QyhYSKNhYAkldTbQuf71dz1lDhsPZYzCgxYoTsQs/E9l1yNw16H1DlISFUD/GNRI1nRwgDFB8ifQPcBicbxYZyc9pwH0cLDD6RzesP5RcDTGO8hBYUtavq8d+GQONEds8waeN2pqYXunmq5D59n8b9V9gTDJ3q/7NHhGronFMRakrI4FzwZbZ6fSIquPZJMOgA4dnJVZAwlwmOAN+SQnqEvatK3CstRUb6lUCnkV7S1HeBB1T5Oq7prksgPum+BanxaGPws3eG/TY916WtySUlIKMrTdnyJmAEnYc4jcE7Ls31SYJc4gyry2LEWEAZHW0Knh8HBzBDTd56L"
    }
                }
  identity {
    type = "SystemAssigned"
  }
 

  default_node_pool {
    name       = "defaultpool"
    node_count = 5
    vm_size    = "Standard_DS2_v2"
  }


 
  depends_on = [
    azurerm_network_security_group.k8s-nsg,
  ]

  tags = {
    Environment = "test"
  }
}
