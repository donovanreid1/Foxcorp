#Required for Terraform
provider "azurerm" {
  version = "=2.12.0"
  features {}
}

#Deploy resource group to west us
resource "azurerm_resource_group" "foxcorp" {
  name     = "rg1"
  location = "West US"
}

#Deploys virtual network inside resource group devtest with address space /16
resource "azurerm_virtual_network" "foxcorp" {
  name                = "VirtualNetwork1"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.foxcorp.location
  resource_group_name = azurerm_resource_group.foxcorp.name
}

#deploys subnet inside vnet with /24 address space
resource "azurerm_subnet" "foxcorp" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.foxcorp.name
  virtual_network_name = azurerm_virtual_network.foxcorp.name
  address_prefixes     = ["192.168.1.0/24"]
  }

#creates network interface for linux vm
resource "azurerm_network_interface" "foxcorp" {
  name                = "linuxinterface"
  location            = azurerm_resource_group.foxcorp.location
  resource_group_name = azurerm_resource_group.foxcorp.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.foxcorp.id
    private_ip_address_allocation = "Dynamic"
  }
}

#deploys linux vm with Ubuntu image
resource "azurerm_virtual_machine" "production" {
  name                  = "linuxvm"
  location              = azurerm_resource_group.foxcorp.location
  resource_group_name   = azurerm_resource_group.foxcorp.name
  network_interface_ids = [azurerm_network_interface.foxcorp.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "donovan"
    admin_password = "Password123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

#deploys storage account with Geo Redundant replication
resource "azurerm_storage_account" "foxcorp" {
  name                     = "istsolutionstesting"
  resource_group_name      = azurerm_resource_group.foxcorp.name
  location                 = azurerm_resource_group.foxcorp.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "foxcorp" {
}

#creates a role assignment with write acess to storage accounts
resource "azurerm_role_definition" "foxcorp" {
  name               = "linuxvmrole"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Storage/storageAccounts/write"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

#scopes role assignment to linuxvm
resource "azurerm_role_assignment" "foxcorp" {
  scope              = "/subscriptions/917e32fe-361a-4bb7-aada-92f002a05a39/resourceGroups/devtest/providers/Microsoft.compute/virtualmachines/linuxvm"
  role_definition_id = azurerm_role_definition.foxcorp.id
  principal_id       = data.azurerm_client_config.foxcorp.client_id
}
