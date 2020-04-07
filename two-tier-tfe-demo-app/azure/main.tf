provider "azurerm" {
  environment = "public"
  version = "=1.44.0"
}

resource "azurerm_resource_group" "two-tier-tfe-demo-app" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}

resource "azurerm_virtual_network" "two-tier-tfe-demo-app" {
  name                = "${var.azure_resource_group_name}-vnet"
  location            = var.azure_location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
}

resource "azurerm_public_ip" "two-tier-tfe-demo-app" {
  name                = "${var.azure_resource_group_name}-ip"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.azure_resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.azure_resource_group_name}-subnet"
  virtual_network_name = azurerm_virtual_network.two-tier-tfe-demo-app.name
  resource_group_name  = azurerm_resource_group.two-tier-tfe-demo-app.name
  address_prefix       = "10.0.10.0/24"
}

resource "azurerm_lb" "two-tier-tfe-demo-app" {
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
  name                = "${var.azure_resource_group_name}-lb"
  location            = var.azure_location

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.two-tier-tfe-demo-app.id
  }
}

resource "azurerm_lb_backend_address_pool" "two-tier-tfe-demo-app" {
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
  loadbalancer_id     = azurerm_lb.two-tier-tfe-demo-app.id
  name                = "BackendPool1"
}


resource "azurerm_lb_rule" "two-tier-tfe-demo-app" {
  resource_group_name            = azurerm_resource_group.two-tier-tfe-demo-app.name
  loadbalancer_id                = azurerm_lb.two-tier-tfe-demo-app.id
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.two-tier-tfe-demo-app.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
  loadbalancer_id     = azurerm_lb.two-tier-tfe-demo-app.id
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.azure_resource_group_name}-nic-${count.index}"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.two-tier-tfe-demo-app.name
  count               = 2

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = azurerm_subnet.subnet.id
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.two-tier-tfe-demo-app.id]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.azure_resource_group_name}-vm-${count.index}"
  location              = var.azure_location
  resource_group_name   = azurerm_resource_group.two-tier-tfe-demo-app.name
  vm_size               = var.azure_vm_size
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                 = var.num_instances

  storage_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }

  storage_os_disk {
    name          = "osdisk${count.index}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = var.azure_resource_group_name
    admin_username = var.azure_vm_admin_username
    admin_password = var.azure_vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.azure_vm_tags
}
