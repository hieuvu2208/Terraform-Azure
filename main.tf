### Provider ###
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.27.0"
    }
  }

  cloud {
    organization = "FIS-lab"

    workspaces {
      name = "Terraform-Azure-CLI"
    }

    workspaces {
      name = "Terraform-Azure-VCS"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = "4239fae3-1148-4eb5-af9c-a02118baa0eb"
  client_secret   = "Hru8Q~PZswF0cO5AYxFCDcCIn1XOKAjAgXjRzdyn"
  tenant_id       = "2e8da345-7c69-461c-90c8-bc465e13cc0f"
  subscription_id = "f25bb0bd-2231-44c7-a509-ad06441d5f04"
}

### Resource Group ###
resource "azurerm_resource_group" "rg" {
  for_each = local.resource_group
  name     = each.value.name
  location = each.value.location
}

### Virtual Network ###
resource "azurerm_virtual_network" "vnet" {
  for_each            = local.virtual_network
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location
  address_space       = each.value.address_space

  depends_on = [azurerm_resource_group.rg]
}

### Subnet ###
resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg[each.value.name_rg].name
  address_prefixes     = each.value.address_prefixes
  virtual_network_name = azurerm_virtual_network.vnet[each.value.name_vnet].name

  depends_on = [azurerm_virtual_network.vnet]
}

### Availability Set ###
resource "azurerm_availability_set" "avai_set" {
  for_each                    = local.availability_set
  name                        = each.value.name
  resource_group_name         = azurerm_resource_group.rg[each.value.name_rg].name
  location                    = azurerm_resource_group.rg[each.value.name_rg].location
  platform_fault_domain_count = each.value.platform_fault_domain_count

  depends_on = [azurerm_resource_group.rg]
}

### Public IP ###
resource "azurerm_public_ip" "pip" {
  for_each            = local.public_ip
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku

  depends_on = [azurerm_resource_group.rg]
}

### Network Security Group ###
resource "azurerm_network_security_group" "nsg" {
  for_each            = local.network_security_group
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location

  depends_on = [azurerm_resource_group.rg]
}

### Network Security Rule ###
resource "azurerm_network_security_rule" "example" {
  for_each                    = local.network_security_group_rule
  resource_group_name         = azurerm_resource_group.rg[each.value.name_rg].name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.name_nsg].name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix

  depends_on = [azurerm_network_security_group.nsg]
}

### Network Interface ###
resource "azurerm_network_interface" "nic" {
  for_each            = local.network_interface
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location

  ip_configuration {
    name                          = each.value.name_ipconfig
    subnet_id                     = azurerm_subnet.subnet[each.value.name_subnet].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
  }

  depends_on = [azurerm_subnet.subnet, azurerm_public_ip.pip]
}

### Association NIC vs NSG ###
resource "azurerm_network_interface_security_group_association" "associate_nic_nsg" {
  for_each                  = local.associate_nic_nsg
  network_interface_id      = azurerm_network_interface.nic[each.value.name_nic].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.name_nsg].id

  depends_on = [azurerm_network_interface.nic, azurerm_network_security_group.nsg]
}

### Virtual Machine ###
resource "azurerm_windows_virtual_machine" "vm" {
  for_each              = local.virtual_machine
  name                  = each.value.name
  resource_group_name   = azurerm_resource_group.rg[each.value.name_rg].name
  location              = azurerm_resource_group.rg[each.value.name_rg].location
  network_interface_ids = [azurerm_network_interface.nic[each.value.name_nic].id]
  availability_set_id   = azurerm_availability_set.avai_set[each.value.name_avai_set].id
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }

  os_disk {
    name                 = each.value.name_disk
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type
  }

  depends_on = [azurerm_availability_set.avai_set, azurerm_network_interface.nic]
}

### VM Shutdown Schedule ###
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown_schedule" {
  for_each              = local.vm_shutdown_schedule
  virtual_machine_id    = azurerm_windows_virtual_machine.vm[each.value.vm_id].id
  location              = azurerm_resource_group.rg[each.value.name_rg].location
  daily_recurrence_time = each.value.daily_recurrence_time
  timezone              = each.value.timezone

  notification_settings {
    enabled = false
  }

  depends_on = [azurerm_windows_virtual_machine.vm]
}

### Load Balancer ###
resource "azurerm_lb" "lb" {
  for_each            = local.load_balancer
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location
  sku                 = each.value.sku

  frontend_ip_configuration {
    name                 = each.value.name_pip
    public_ip_address_id = azurerm_public_ip.pip[each.value.name_pip].id
  }

  depends_on = [azurerm_public_ip.pip]
}

### Load Balancer Pool ###
resource "azurerm_lb_backend_address_pool" "lb_pool" {
  for_each        = local.load_balancer_pool
  name            = each.value.name
  loadbalancer_id = azurerm_lb.lb[each.value.name_lb].id

  depends_on = [azurerm_lb.lb]
}

### Load Balancer Associate ###
resource "azurerm_lb_backend_address_pool_address" "lb_associate" {
  for_each                = local.load_balancer_associate
  name                    = each.value.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool[each.value.name_pool].id
  virtual_network_id      = azurerm_virtual_network.vnet[each.value.name_vnet].id
  ip_address              = azurerm_windows_virtual_machine.vm[each.value.name_vm].private_ip_address
  depends_on              = [azurerm_lb_backend_address_pool.lb_pool, azurerm_virtual_network.vnet, azurerm_windows_virtual_machine.vm]
}

### Load Balancer Probe ###
resource "azurerm_lb_probe" "lb_probe" {
  for_each        = local.load_balancer_probe
  name            = each.value.name
  loadbalancer_id = azurerm_lb.lb[each.value.name_lb].id
  port            = each.value.port

  depends_on = [azurerm_lb.lb]
}

### Load Balancer Rule ###
resource "azurerm_lb_rule" "lb_rule" {
  for_each                       = local.load_balancer_rule
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.name_pip
  loadbalancer_id                = azurerm_lb.lb[each.value.name_lb].id
  probe_id                       = azurerm_lb_probe.lb_probe[each.value.name_probe].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_pool[each.value.name_pool].id]

  depends_on = [azurerm_lb.lb, azurerm_lb_probe.lb_probe, azurerm_lb_backend_address_pool.lb_pool]
}

### Firewall ###
resource "azurerm_firewall" "fw" {
  for_each            = local.firewall
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location
  sku_name            = each.value.sku_name
  sku_tier            = each.value.sku_tier

  ip_configuration {
    name                 = each.value.name_ipconfig
    subnet_id            = azurerm_subnet.subnet[each.value.name_subnet].id
    public_ip_address_id = azurerm_public_ip.pip[each.value.name_pip].id
  }

  depends_on = [azurerm_subnet.subnet, azurerm_public_ip.pip]
}

### Firewall Network Rule ###
resource "azurerm_firewall_network_rule_collection" "fw_network_rule" {
  for_each            = local.firewall_network_rule
  name                = each.value.name
  azure_firewall_name = azurerm_firewall.fw[each.value.name_fw].name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  priority            = each.value.priority
  action              = each.value.action

  rule {
    name                  = each.value.name_rule
    source_addresses      = [each.value.source_addresses]
    destination_ports     = [each.value.destination_ports]
    destination_addresses = [each.value.destination_addresses]
    protocols             = [each.value.protocols]
  }

  depends_on = [azurerm_firewall.fw, azurerm_virtual_network.vnet]
}

### Firewall Application Rule ###
resource "azurerm_firewall_application_rule_collection" "fw_application_rule" {
  for_each            = local.firewall_application_rule
  name                = each.value.name
  azure_firewall_name = azurerm_firewall.fw[each.value.name_fw].name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  priority            = each.value.priority
  action              = each.value.action

  rule {
    name             = each.value.name_rule
    source_addresses = [each.value.source_addresses]
    target_fqdns     = [each.value.target_fqdns]

    protocol {
      port = each.value.port
      type = each.value.type
    }
  }
}

### Peering ###
resource "azurerm_virtual_network_peering" "peering" {
  for_each                  = local.peering
  name                      = each.value.name
  resource_group_name       = azurerm_resource_group.rg[each.value.name_rg].name
  virtual_network_name      = azurerm_virtual_network.vnet[each.value.name_vnet].name
  remote_virtual_network_id = azurerm_virtual_network.vnet[each.value.name_vnet_id].id
  allow_forwarded_traffic   = each.value.allow_forwarded_traffic

  depends_on = [azurerm_virtual_network.vnet]
}

### Route Table ###
resource "azurerm_route_table" "rt" {
  for_each            = local.route_table
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg[each.value.name_rg].name
  location            = azurerm_resource_group.rg[each.value.name_rg].location

  depends_on = [azurerm_firewall.fw]
}

### Associate Route With Route Table ###
resource "azurerm_route" "example" {
  for_each               = local.associate_route_rt
  name                   = each.value.name
  resource_group_name    = azurerm_resource_group.rg[each.value.name_rg].name
  route_table_name       = azurerm_route_table.rt[each.value.name_rt].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = azurerm_firewall.fw[each.value.name_fw].ip_configuration.0.private_ip_address

  depends_on = [azurerm_route_table.rt]
}

### Associate Subnet With Route Table ###
resource "azurerm_subnet_route_table_association" "associate_subnet_rt" {
  for_each       = local.associate_subnet_rt
  subnet_id      = azurerm_subnet.subnet[each.value.name_subnet].id
  route_table_id = azurerm_route_table.rt[each.value.name_rt].id

  depends_on = [azurerm_subnet.subnet, azurerm_route_table.rt, azurerm_virtual_network_gateway.gw]
}

### Gateway ###
resource "azurerm_virtual_network_gateway" "gw" {
  for_each                   = local.virtual_network_gateway
  name                       = each.value.name
  location                   = azurerm_resource_group.rg[each.value.name_rg].location
  resource_group_name        = azurerm_resource_group.rg[each.value.name_rg].name
  type                       = each.value.type
  vpn_type                   = each.value.vpn_type
  sku                        = each.value.sku
  private_ip_address_enabled = each.value.private_ip_address_enabled

  ip_configuration {
    name                          = each.value.name_ipconfig
    public_ip_address_id          = azurerm_public_ip.pip[each.value.name_pip].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    subnet_id                     = azurerm_subnet.subnet[each.value.name_subnet].id
  }

  vpn_client_configuration {
    address_space  = each.value.address_space
    vpn_auth_types = each.value.vpn_auth_types

    root_certificate {
      name             = each.value.name_cert
      public_cert_data = <<EOF
        MIIC6zCCAdOgAwIBAgIQFvMY+lDCYKlHs5AkxE5BJDANBgkqhkiG9w0BAQsFADAY
        MRYwFAYDVQQDDA1TTFAyU1Jvb3RDZXJ0MB4XDTIyMTEyMTEwMTYyMloXDTIzMTEy
        MTEwMzYyMlowGDEWMBQGA1UEAwwNU0xQMlNSb290Q2VydDCCASIwDQYJKoZIhvcN
        AQEBBQADggEPADCCAQoCggEBAK2YbjzSaxWiPTYIa9mlmY5o4Tgld3yWtYtJW2WD
        k1i7Ta4wuSH3hqRtSAGKgPUoxFyYCMGSVSJFIS6BIu3oaG82vqNEmG+MonjzMSu7
        cBFLyHmt7/enAU91cfzJu7OiJ7yw4gjNmQkS+QM9PMLOf88axZQ7TgsSa0lO6JS1
        AaoLQm3v29yFQrv88xsG66MEEMlEcYziRiDH/oWkNWTI1g63gZ79c3ue37bCRsVj
        JHkwVRNj1ey68b2dyu6x8vqmP6NlNJ+pr4dVy2VE4aQ2/0I9G/C5zubRzvwXRqed
        uI6cD4Oijr5OTq8WltJqrSpRjYlgtAxRZeYTGlcZQZ0uGtECAwEAAaMxMC8wDgYD
        VR0PAQH/BAQDAgIEMB0GA1UdDgQWBBT/QlrQSDQ6J2CT6vVJjaQmYnw4xDANBgkq
        hkiG9w0BAQsFAAOCAQEAghGNEi4bw6vUE8JRlD1rN0Xf5G+pt2O6kShVbnyg66vX
        5bhPiUviyFXY3cmCg7DvZs1HkzV+3QySQrRgAvOGp1QFQq/ubR8My502SMScx0gP
        dXlCp8+rvCGiqYZhDHQLWAa0hhU4bAtSsOKEZzg0gcHsqK5eCgw8J1YQpC15zJsg
        xouSzbh7OBpAuRiCNAlkHIN0OFjeMLOUBT0li0hjg1xaqfRWr6ZYhFjC2UANr6x5
        ZxSJwcLCs14Y32xDq7MV+Hw4qntkm+70geI2LL3l6+Nrxdxo7GoyO9zfpDB4rgMv
        YqlYns5U2kxlF3l1pXAhCxjzaKh/OfOS8i9v5p2ZWw==
      EOF
    }
  }

  custom_route {
    address_prefixes = each.value.address_prefixes
  }

  depends_on = [azurerm_public_ip.pip, azurerm_subnet.subnet]
}
