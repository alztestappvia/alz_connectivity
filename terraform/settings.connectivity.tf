locals {
  configure_connectivity_resources = local.connectivity_templates[var.networking_model]

  connectivity_templates = {
    virtualwan = {
      settings = {
        hub_networks = []
        vwan_hub_networks = [
          {
            enabled = true
            config = {
              address_prefix = var.primary_location_cidr
              location       = var.primary_location
              sku            = ""
              routes         = []
              routing_intent = {
                enabled = true
                config = {
                  routing_policies = [
                    {
                      # Causes a default (0.0.0.0/0) route to be advertised to all spokes, Gateways and Network Virtual Appliances (deployed in the hub or spoke), 
                      # to route traffic via Azure Firewall deployed in the Virtual WAN Hub.
                      name         = "InternetTrafficPolicy"
                      destinations = ["Internet"]
                      # Next Hop is set as Virtual Hub FW automatically
                    },
                    {
                      # Causes all branch-to-branch, branch-to-virtual network, virtual network-to-branch and inter-hub traffic to be sent via Azure Firewall deployed 
                      # in the Virtual WAN Hub.
                      name         = "PrivateTrafficPolicy"
                      destinations = ["PrivateTraffic"]
                      # Next Hop is set as Virtual Hub FW automatically
                    }
                  ]
                }
              }
              expressroute_gateway = {
                enabled = var.environment == "prod" ? true : false
                config = {
                  scale_unit = 1
                }
              }
              vpn_gateway = {
                enabled = false
                config = {
                  bgp_settings       = []
                  routing_preference = ""
                  scale_unit         = 1
                }
              }
              azure_firewall = {
                enabled = true
                config = {
                  firewall_policy_id            = ""
                  enable_dns_proxy              = true
                  dns_servers                   = ["172.28.2.4", "172.28.130.4"]
                  sku_tier                      = "Standard"
                  base_policy_id                = data.terraform_remote_state.firewall_config.outputs.base_policy_id
                  private_ip_ranges             = []
                  threat_intelligence_mode      = "Alert"
                  threat_intelligence_allowlist = []
                  availability_zones = {
                    zone_1 = true
                    zone_2 = true
                    zone_3 = true
                  }
                }
              }
              spoke_virtual_network_resource_ids        = []
              secure_spoke_virtual_network_resource_ids = []
              enable_virtual_hub_connections            = false # This will be done via the LZ vending module
            }
          },
          {
            enabled = false
            config = {
              address_prefix = var.secondary_location_cidr
              location       = var.secondary_location
              sku            = ""
              routes         = []
              expressroute_gateway = {
                enabled = var.environment == "prod" ? true : false
                config = {
                  scale_unit = 1
                }
              }
              vpn_gateway = {
                enabled = false
                config = {
                  bgp_settings       = []
                  routing_preference = ""
                  scale_unit         = 1
                }
              }
              azure_firewall = {
                enabled = true
                config = {
                  firewall_policy_id            = data.terraform_remote_state.firewall_config.outputs.base_policy_id
                  enable_dns_proxy              = true
                  dns_servers                   = ["172.28.2.4", "172.28.130.4"]
                  sku_tier                      = "Standard"
                  base_policy_id                = ""
                  private_ip_ranges             = []
                  threat_intelligence_mode      = "Alert"
                  threat_intelligence_allowlist = []
                  availability_zones = {
                    zone_1 = true
                    zone_2 = true
                    zone_3 = true
                  }
                }
              }
              spoke_virtual_network_resource_ids        = []
              secure_spoke_virtual_network_resource_ids = []
              enable_virtual_hub_connections            = false # This will be done via the LZ vending module
            }
          },
        ]
        ddos_protection_plan = {
          enabled = false
        }
        dns = {
          enabled = true
          config = {
            location = null
            enable_private_link_by_service = {
              azure_api_management                 = true
              azure_app_configuration_stores       = true
              azure_arc                            = true
              azure_automation_dscandhybridworker  = true
              azure_automation_webhook             = true
              azure_backup                         = true
              azure_batch_account                  = true
              azure_bot_service_bot                = true
              azure_bot_service_token              = true
              azure_cache_for_redis                = true
              azure_cache_for_redis_enterprise     = true
              azure_container_registry             = true
              azure_cosmos_db_cassandra            = true
              azure_cosmos_db_gremlin              = true
              azure_cosmos_db_mongodb              = true
              azure_cosmos_db_sql                  = true
              azure_cosmos_db_table                = true
              azure_data_explorer                  = true
              azure_data_factory                   = true
              azure_data_factory_portal            = true
              azure_data_health_data_services      = true
              azure_data_lake_file_system_gen2     = true
              azure_database_for_mariadb_server    = true
              azure_database_for_mysql_server      = true
              azure_database_for_postgresql_server = true
              azure_digital_twins                  = true
              azure_event_grid_domain              = true
              azure_event_grid_topic               = true
              azure_event_hubs_namespace           = true
              azure_file_sync                      = true
              azure_hdinsights                     = true
              azure_iot_dps                        = true
              azure_iot_hub                        = true
              azure_key_vault                      = true
              azure_key_vault_managed_hsm          = true
              azure_kubernetes_service_management  = true
              azure_machine_learning_workspace     = true
              azure_managed_disks                  = true
              azure_media_services                 = true
              azure_migrate                        = true
              azure_monitor                        = true
              azure_purview_account                = true
              azure_purview_studio                 = true
              azure_relay_namespace                = true
              azure_search_service                 = true
              azure_service_bus_namespace          = true
              azure_site_recovery                  = true
              azure_sql_database_sqlserver         = true
              azure_synapse_analytics_dev          = true
              azure_synapse_analytics_sql          = true
              azure_synapse_studio                 = true
              azure_web_apps_sites                 = true
              azure_web_apps_static_sites          = true
              cognitive_services_account           = true
              microsoft_power_bi                   = true
              signalr                              = true
              signalr_webpubsub                    = true
              storage_account_blob                 = true
              storage_account_file                 = true
              storage_account_queue                = true
              storage_account_table                = true
              storage_account_web                  = true
            }
            private_link_locations = [
              var.primary_location,
              var.secondary_location
            ]
            public_dns_zones                                       = []
            private_dns_zones                                      = []
            enable_private_dns_zone_virtual_network_link_on_hubs   = true
            enable_private_dns_zone_virtual_network_link_on_spokes = true
            virtual_network_resource_ids_to_link                   = []
          }
        }
      }
      location = var.primary_location
      tags     = var.connectivity_resources_tags
      advanced = {
        custom_settings_by_resource_type = {
          azurerm_firewall_policy = {
            virtual_wan = {
              ukwest = {
                insights = {
                  default = {
                    enabled = true
                    # if deploying law per region this will need to be updated and changed to log_analytics_workspace block below (see module implementation for details)
                    default_log_analytics_workspace_id = data.terraform_remote_state.management.outputs.log_analytics_workspace_ids[0]
                    retention_in_days                  = 30
                  }
                }
              }
              uksouth = {
                insights = {
                  default = {
                    enabled = true
                    # if deploying law per region this will need to be updated and changed to log_analytics_workspace block below (see module implementation for details)
                    default_log_analytics_workspace_id = data.terraform_remote_state.management.outputs.log_analytics_workspace_ids[0]
                    retention_in_days                  = 30
                  }
                }
              }
            }
          }
        }
      }
    }

    basic = {
      settings = {
        hub_networks = [
          {
            enabled = true
            config = {
              address_space                = [var.primary_location_cidr]
              location                     = var.primary_location
              link_to_ddos_protection_plan = false
              dns_servers                  = []
              bgp_community                = ""
              subnets = [
                {
                  name             = "Management"
                  address_prefixes = ["172.28.0.0/24", ]
                }
              ]
              virtual_network_gateway = {
                enabled = false
              }
              azure_firewall = {
                enabled = false
                config = {
                  address_prefix                = "172.28.1.0/24"
                  firewall_policy_id            = ""
                  enable_dns_proxy              = false
                  dns_servers                   = []
                  sku_tier                      = "Basic"
                  base_policy_id                = data.terraform_remote_state.firewall_config.outputs.base_policy_id
                  private_ip_ranges             = []
                  threat_intelligence_mode      = "Alert"
                  threat_intelligence_allowlist = []
                  availability_zones = {
                    zone_1 = true
                    zone_2 = true
                    zone_3 = true
                  }
                }
              }
              spoke_virtual_network_resource_ids      = []
              enable_outbound_virtual_network_peering = true
              enable_hub_network_mesh_peering         = false
            }
          }
        ]
        vwan_hub_networks = []
        ddos_protection_plan = {
          enabled = false
        }
        dns = {
          enabled = true
          config = {
            location = null
            enable_private_link_by_service = {
              azure_api_management                 = true
              azure_app_configuration_stores       = true
              azure_arc                            = true
              azure_automation_dscandhybridworker  = true
              azure_automation_webhook             = true
              azure_backup                         = true
              azure_batch_account                  = true
              azure_bot_service_bot                = true
              azure_bot_service_token              = true
              azure_cache_for_redis                = true
              azure_cache_for_redis_enterprise     = true
              azure_container_registry             = true
              azure_cosmos_db_cassandra            = true
              azure_cosmos_db_gremlin              = true
              azure_cosmos_db_mongodb              = true
              azure_cosmos_db_sql                  = true
              azure_cosmos_db_table                = true
              azure_data_explorer                  = true
              azure_data_factory                   = true
              azure_data_factory_portal            = true
              azure_data_health_data_services      = true
              azure_data_lake_file_system_gen2     = true
              azure_database_for_mariadb_server    = true
              azure_database_for_mysql_server      = true
              azure_database_for_postgresql_server = true
              azure_digital_twins                  = true
              azure_event_grid_domain              = true
              azure_event_grid_topic               = true
              azure_event_hubs_namespace           = true
              azure_file_sync                      = true
              azure_hdinsights                     = true
              azure_iot_dps                        = true
              azure_iot_hub                        = true
              azure_key_vault                      = true
              azure_key_vault_managed_hsm          = true
              azure_kubernetes_service_management  = true
              azure_machine_learning_workspace     = true
              azure_managed_disks                  = true
              azure_media_services                 = true
              azure_migrate                        = true
              azure_monitor                        = true
              azure_purview_account                = true
              azure_purview_studio                 = true
              azure_relay_namespace                = true
              azure_search_service                 = true
              azure_service_bus_namespace          = true
              azure_site_recovery                  = true
              azure_sql_database_sqlserver         = true
              azure_synapse_analytics_dev          = true
              azure_synapse_analytics_sql          = true
              azure_synapse_studio                 = true
              azure_web_apps_sites                 = true
              azure_web_apps_static_sites          = true
              cognitive_services_account           = true
              microsoft_power_bi                   = true
              signalr                              = true
              signalr_webpubsub                    = true
              storage_account_blob                 = true
              storage_account_file                 = true
              storage_account_queue                = true
              storage_account_table                = true
              storage_account_web                  = true
            }
            private_link_locations = [
              var.primary_location,
              var.secondary_location
            ]
            public_dns_zones                                       = []
            private_dns_zones                                      = []
            enable_private_dns_zone_virtual_network_link_on_hubs   = true
            enable_private_dns_zone_virtual_network_link_on_spokes = true
            virtual_network_resource_ids_to_link                   = []
          }
        }
      }
      location = var.primary_location
      tags     = var.connectivity_resources_tags
      advanced = {}
    }
  }
}
