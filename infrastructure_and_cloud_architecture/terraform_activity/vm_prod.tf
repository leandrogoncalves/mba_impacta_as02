/**
* Definição da placa de rede virtual da VM
**/
resource "azurerm_network_interface" "nicProd" {
    name                      = "nicProd"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.rgProd.name

    ip_configuration {
        name                          = "nicConfigProd"
        subnet_id                     = azurerm_subnet.subnetProd.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicIpProd.id
    }
}

/**
* Definição da associanao entre aplaca de rede virtual e a regra de Firewall
**/
resource "azurerm_network_interface_security_group_association" "nicNsgProd" {
    network_interface_id      = azurerm_network_interface.nicProd.id
    network_security_group_id = azurerm_network_security_group.nsgProd.id
}

/**
* Definição do storage da VM
**/
resource "azurerm_storage_account" "storage1prod" {
    name                        = "storage1prod"
    resource_group_name         = azurerm_resource_group.rgProd.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

data "azurerm_public_ip" "ipDataDb" {
  name                = azurerm_public_ip.publicIpProd.name
  resource_group_name = azurerm_resource_group.rgProd.name
}

/**
* Definição da criptografia da chave ssh
**/
# resource "tls_private_key" "ssh_key_prod" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }

/**
* Definição chave ssh
**/
# output "tls_private_key" { 
#   value = tls_private_key.ssh_key_prod.private_key_pem 
# }

/**
* Definição VM
**/
resource "azurerm_linux_virtual_machine" "vmProd" {
    name                  = "vmProd"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.rgProd.name
    network_interface_ids = [azurerm_network_interface.nicProd.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "diskProd"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "vmProd"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    # admin_ssh_key {
    #     username       = "adm_user_prod"
    #     public_key     = tls_private_key.ssh_key_prod.public_key_openssh
    # }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage1prod.primary_blob_endpoint
    }

    depends_on = [ azurerm_resource_group.rgProd ]
}

/**
* Definição de saida do IP publico no terminal
**/

output "public_ip_address" {
  value = azurerm_public_ip.publicIpProd.ip_address
   description = "IP publico"
}

/**
* Definição Tempo de espera para subir a VM
**/
resource "time_sleep" "wait_30_seconds_db" {
  depends_on = [azurerm_linux_virtual_machine.vmProd]
  create_duration = "30s"
}

/**
* Upload dos arquivos de configuração do mysql
**/
resource "null_resource" "uploadSetup" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ipDataDb.ip_address
        }
        source = "setup"
        destination = "/home/adm_user_prod"
    }

    depends_on = [ time_sleep.wait_30_seconds_db ]
}

/**
* Instalação do Mysql
**/
resource "null_resource" "setupCmd" {
    triggers = {
        order = null_resource.uploadSetup.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ipDataDb.ip_address
        }
        inline = [
            "sudo chmod +x /home/adm_user_prod/setup/mysql/install.sh",
            "/home/adm_user_prod/setup/mysql/install.sh"
        ]
    }
}