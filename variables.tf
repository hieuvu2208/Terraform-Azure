locals {
  resource_group = {
    dev  = { name = "dev_rg" , location = "SouthEastAsia" }
    #######################################################
    hub  = { name = "hub_rg" , location = "SouthEastAsia" }
    #######################################################
    prod = { name = "prod_rg", location = "SouthEastAsia" }
  }
  virtual_network = {
    dev  = { name = "dev_vnet" , name_rg = "dev" , address_space = ["10.10.0.0/16"] }
    #################################################################################
    hub  = { name = "hub_vnet" , name_rg = "hub" , address_space = ["10.20.0.0/16"] }
    #################################################################################
    prod = { name = "prod_vnet", name_rg = "prod", address_space = ["10.30.0.0/16"] }
  }
  subnet = {
    dev    = { name = "dev_subnet"         , name_rg = "dev" , address_prefixes = ["10.10.0.0/24"], name_vnet = "dev"  }
    ####################################################################################################################
    hub_fw = { name = "AzureFirewallSubnet", name_rg = "hub" , address_prefixes = ["10.20.0.0/24"], name_vnet = "hub"  }
    hub_gw = { name = "GatewaySubnet"      , name_rg = "hub" , address_prefixes = ["10.20.1.0/24"], name_vnet = "hub"  }
    ####################################################################################################################
    prod   = { name = "prod_subnet"        , name_rg = "prod", address_prefixes = ["10.30.0.0/24"], name_vnet = "prod" }
  }
  availability_set = {
    dev  = { name = "dev_avai_set" , name_rg = "dev" , platform_fault_domain_count = 2 }
    ####################################################################################
    prod = { name = "prod_avai_set", name_rg = "prod", platform_fault_domain_count = 2 }
  }
  public_ip = {
    dev_lb  = { name = "dev_lb_pip" , name_rg = "dev" , allocation_method = "Static", sku = "Standard" }
    ####################################################################################################
    hub_fw  = { name = "hub_fw_pip" , name_rg = "hub" , allocation_method = "Static", sku = "Standard" }
    hub_gw  = { name = "hub_gw_pip" , name_rg = "hub" , allocation_method = "Static", sku = "Standard" }
    ####################################################################################################
    prod_lb = { name = "prod_lb_pip", name_rg = "prod", allocation_method = "Static", sku = "Standard" }
  }
  network_security_group = {
    dev_vm1  = { name = "dev_vm1_nsg" , name_rg = "dev"  }
    dev_vm2  = { name = "dev_vm2_nsg" , name_rg = "dev"  }
    ######################################################
    prod_vm1 = { name = "prod_vm1_nsg", name_rg = "prod" }
    prod_vm2 = { name = "prod_vm2_nsg", name_rg = "prod" }
  }
  network_security_group_rule = {
    dev_vm1  = { name_rg = "dev" , name_nsg = "dev_vm1" , name = "All", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*"}
    dev_vm2  = { name_rg = "dev" , name_nsg = "dev_vm2" , name = "All", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*"}
    ####################################################################################################################################################################################################################################################################
    prod_vm1 = { name_rg = "prod", name_nsg = "prod_vm1", name = "All", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*"}
    prod_vm2 = { name_rg = "prod", name_nsg = "prod_vm2", name = "All", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "*", source_address_prefix = "*", destination_address_prefix = "*"}
  }
  network_interface = {

    
    dev_vm1  = { name = "dev_vm1_nic" , name_rg = "dev" , name_ipconfig = "dev_vm1_ipconfig" , name_subnet = "dev" , private_ip_address_allocation = "Dynamic" }
    dev_vm2  = { name = "dev_vm2_nic" , name_rg = "dev" , name_ipconfig = "dev_vm2_ipconfig" , name_subnet = "dev" , private_ip_address_allocation = "Dynamic" }
    ############################################################################################################################################################
    prod_vm1 = { name = "prod_vm1_nic", name_rg = "prod", name_ipconfig = "prod_vm1_ipconfig", name_subnet = "prod", private_ip_address_allocation = "Dynamic" }
    prod_vm2 = { name = "prod_vm2_nic", name_rg = "prod", name_ipconfig = "prod_vm2_ipconfig", name_subnet = "prod", private_ip_address_allocation = "Dynamic" }
  }
  associate_nic_nsg = {
    dev_vm1  = { name_nic = "dev_vm1" , name_nsg = "dev_vm1"  }
    dev_vm2  = { name_nic = "dev_vm2" , name_nsg = "dev_vm2"  }
    ###########################################################
    prod_vm1 = { name_nic = "prod_vm1", name_nsg = "prod_vm1" }
    prod_vm2 = { name_nic = "prod_vm2", name_nsg = "prod_vm2" }
  }
  virtual_machine = {
    dev_vm1  = { name = "dev-vm1" , name_rg = "dev" , name_nic = "dev_vm1" , name_avai_set = "dev" , size = "Standard_D2s_v3", admin_username = "dev-vm1" , admin_password = "Vuduchieu2208", publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2016-datacenter-gensecond", version = "latest", name_disk = "dev_vm1_disk" , caching = "ReadWrite", storage_account_type = "StandardSSD_LRS" }
    dev_vm2  = { name = "dev-vm2" , name_rg = "dev" , name_nic = "dev_vm2" , name_avai_set = "dev" , size = "Standard_D2s_v3", admin_username = "dev-vm2" , admin_password = "Vuduchieu2208", publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2016-datacenter-gensecond", version = "latest", name_disk = "dev_vm2_disk" , caching = "ReadWrite", storage_account_type = "StandardSSD_LRS" }
    ##############################################################################################################################################################################################################################################################################################################################################################################################################
    prod_vm1 = { name = "prod-vm1", name_rg = "prod", name_nic = "prod_vm1", name_avai_set = "prod", size = "Standard_D2s_v3", admin_username = "prod-vm1", admin_password = "Vuduchieu2208", publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2016-datacenter-gensecond", version = "latest", name_disk = "prod_vm1_disk", caching = "ReadWrite", storage_account_type = "StandardSSD_LRS" }
    prod_vm2 = { name = "prod-vm2", name_rg = "prod", name_nic = "prod_vm2", name_avai_set = "prod", size = "Standard_D2s_v3", admin_username = "prod-vm2", admin_password = "Vuduchieu2208", publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2016-datacenter-gensecond", version = "latest", name_disk = "prod_vm2_disk", caching = "ReadWrite", storage_account_type = "StandardSSD_LRS" }
  }
  vm_shutdown_schedule = {
    dev_vm1  = { vm_id = "dev_vm1" , name_rg = "dev" , daily_recurrence_time = "1900", timezone = "SE Asia Standard Time" }
    dev_vm2  = { vm_id = "dev_vm2" , name_rg = "dev" , daily_recurrence_time = "1900", timezone = "SE Asia Standard Time" }
    #######################################################################################################################
    prod_vm1 = { vm_id = "prod_vm1", name_rg = "prod", daily_recurrence_time = "1900", timezone = "SE Asia Standard Time" }
    prod_vm2 = { vm_id = "prod_vm2", name_rg = "prod", daily_recurrence_time = "1900", timezone = "SE Asia Standard Time" }
  }
  load_balancer = {
    dev  = { name = "dev_lb" , name_rg = "dev" , sku = "Standard", name_pip = "dev_lb"  }
    #####################################################################################
    prod = { name = "prod_lb", name_rg = "prod", sku = "Standard", name_pip = "prod_lb" }
  }
  load_balancer_pool = {
    dev  = { name = "dev_lb_pool" , name_lb = "dev"  }
    ##################################################
    prod = { name = "prod_lb_pool", name_lb = "prod" }
  }
  load_balancer_associate = {
    dev_vm1  = { name = "dev_vm1_lb_associate" , name_pool = "dev" , name_vnet = "dev" , name_vm = "dev_vm1"  }
    dev_vm2  = { name = "dev_vm2_lb_associate" , name_pool = "dev" , name_vnet = "dev" , name_vm = "dev_vm2"  }
    ###########################################################################################################
    prod_vm1 = { name = "prod_vm1_lb_associate", name_pool = "prod", name_vnet = "prod", name_vm = "prod_vm1" }
    prod_vm2 = { name = "prod_vm2_lb_associate", name_pool = "prod", name_vnet = "prod", name_vm = "prod_vm2" }
  }
  load_balancer_probe = {
    dev  = { name = "dev_lb_probe" , name_lb = "dev" , port = 80 }
    ##############################################################
    prod = { name = "prod_lb_probe", name_lb = "prod", port = 80 }
  }
  load_balancer_rule = {
    dev  = { name = "dev_lb_rule" , protocol = "Tcp", frontend_port = 80, backend_port = 80, name_pip = "dev_lb" , name_lb = "dev" , name_probe = "dev" , name_pool = "dev"  }
    ##########################################################################################################################################################################
    prod = { name = "prod_lb_rule", protocol = "Tcp", frontend_port = 80, backend_port = 80, name_pip = "prod_lb", name_lb = "prod", name_probe = "prod", name_pool = "prod" }
  }
  firewall = {
    hub = { name = "hub_firewall", name_rg = "hub", sku_name = "AZFW_VNet", sku_tier = "Standard", name_ipconfig = "fw_ipconfig", name_subnet = "hub_fw", name_pip = "hub_fw" }
  }
  firewall_network_rule = {
    hub = { name = "hub_firewall_network_rule", name_rg = "hub", name_fw = "hub", priority = 200, action = "Allow", name_rule = "network_rule", source_addresses = "20.20.20.2", destination_ports = "*", destination_addresses = "*", protocols = "Any" }
  }
  firewall_application_rule = {
    hub = { name = "hub_firewall_application_rule", name_rg = "hub", name_fw = "hub", priority = 300, action = "Allow", name_rule = "application_rule", source_addresses = "*", target_fqdns = "*", port = "443", type = "Https" }
  }
  peering = {
    dev_to_hub  = { name = "dev_to_hub" , name_rg = "dev" , name_vnet = "dev" , name_vnet_id = "hub" , allow_forwarded_traffic = true }
    ###################################################################################################################################
    hub_to_dev  = { name = "hub_to_dev" , name_rg = "hub" , name_vnet = "hub" , name_vnet_id = "dev" , allow_forwarded_traffic = true }
    hub_to_prod = { name = "hub_to_prod", name_rg = "hub" , name_vnet = "hub" , name_vnet_id = "prod", allow_forwarded_traffic = true }
    ###################################################################################################################################
    prod_to_hub = { name = "prod_to_hub", name_rg = "prod", name_vnet = "prod", name_vnet_id = "hub" , allow_forwarded_traffic = true }
  }
  route_table = {
    dev  = { name = "dev" , name_rg = "dev"  }
    ##########################################
    hub  = { name = "hub" , name_rg = "hub"  }
    ##########################################
    prod = { name = "prod", name_rg = "prod" }
  }
  associate_route_rt = {
    dev_to_hub  = {name = "dev_to_hub" , name_rg = "dev" , name_rt = "dev" , address_prefix = "0.0.0.0/0"   , next_hop_type = "VirtualAppliance", name_fw = "hub" }
    ###############################################################################################################################################################
    hub_to_dev  = {name = "hub_to_dev" , name_rg = "hub" , name_rt = "hub" , address_prefix = "10.10.0.0/24", next_hop_type = "VirtualAppliance", name_fw = "hub" }
    hub_to_prod = {name = "hub_to_prod", name_rg = "hub" , name_rt = "hub" , address_prefix = "10.30.0.0/24", next_hop_type = "VirtualAppliance", name_fw = "hub" }
    ###############################################################################################################################################################
    prod_to_hub = {name = "prod_to_hub", name_rg = "prod", name_rt = "prod", address_prefix = "0.0.0.0/0"   , next_hop_type = "VirtualAppliance", name_fw = "hub" }
  }
  associate_subnet_rt = {
    dev  = { name_subnet = "dev"   , name_rt = "dev"  }
    ###################################################
    hub  = { name_subnet = "hub_gw", name_rt = "hub"  }
    ###################################################
    prod = { name_subnet = "prod"  , name_rt = "prod" }
  }
  virtual_network_gateway = {
    hub = { name = "hub_gateway", name_rg = "hub", type = "Vpn", vpn_type = "RouteBased", sku = "VpnGw1", private_ip_address_enabled = "true", name_ipconfig = "gw_ipconfig", name_pip = "hub_gw", private_ip_address_allocation = "Dynamic", name_subnet = "hub_gw", address_space = ["20.20.20.0/24"], vpn_auth_types = ["Certificate"], address_prefixes = ["10.10.0.0/24","10.30.0.0/24"], name_cert = "PC_cert" }
  }
}
