#provider
provider "azurerm" {
    features {}
    
    subscription_id= "39b8878b-a80d-411a-8dfa-e1fa084ab2a2"
    client_id= "11ebb867-914c-4d21-8ee1-d4797d240e6e"
    client_secret= "Azx8Q~kZw.LM.MNYa3ZvW~fWlLo.RP1RAzPvpduS"
    tenant_id= "976ace6a-6df4-47c0-9e7f-64dde4491107"
    
}

#resourcegroup
resource "azurerm_resource_group" "example" {
  name     = "git-jen_rg"
  location = "East US"
}

output "first_subnet_address_prefix" {
  value = tolist(azurerm_virtual_network.example.subnet)[0].id
}

#public IP address
resource "azurerm_public_ip" "example" {
  name                = "mypublicip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method  = "Dynamic"
  
}

#nic
resource "azurerm_network_interface" "example" {
  name                = "mynic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "mynic-1"
    subnet_id                     = tolist(azurerm_virtual_network.example.subnet)[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }

}


#virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                  = "vm1"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_DS2_v2"
  admin_username        = "azureuser"
  admin_password        = "Password@123"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.example.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  
  custom_data = base64encode(<<CUSTOM_DATA
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
CUSTOM_DATA
)

}

#virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }
}

  output "public_ip" {
  value = azurerm_public_ip.example.ip_address
}

# Checking for jenkins trigger