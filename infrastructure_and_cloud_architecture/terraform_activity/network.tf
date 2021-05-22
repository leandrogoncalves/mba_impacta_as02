/**
* Definição da rede virtual
**/
resource "azurerm_virtual_network" "vnetProd" {
    name                = "vnetProd"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rgProd.name
}

/**
* Definição da sub rede
**/
resource "azurerm_subnet" "subnetProd" {
    name                 = "subnetProd"
    resource_group_name  = azurerm_resource_group.rgProd.name
    virtual_network_name = azurerm_virtual_network.vnetProd.name
    address_prefixes     = ["10.0.1.0/24"]
}

/**
* Definição do ip publico
**/
resource "azurerm_public_ip" "publicIpProd" {
    name                  = "publicIpProd"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.rgProd.name
    allocation_method     = "Static"
}

/**
* Definição das regras de firewall 
**/
resource "azurerm_network_security_group" "nsgProd" {
    name                = "nsgProd"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rgProd.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

     security_rule {
        name                       = "mysql"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}