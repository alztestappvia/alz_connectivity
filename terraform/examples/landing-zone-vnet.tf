virtual_networks = {
  main = {
    address_space = {
      dev = ["10.30.7.0/28"]
      pre = ["10.30.7.16/28"]
      prd = ["10.30.7.32/28"]
    }
    vwan_associated_routetable_resource_id = {
      dev = data.terraform_remote_state.core.outputs.custom_route_tables["Example_Route_Table_1"]
      pre = data.terraform_remote_state.core.outputs.custom_route_tables["Example_Route_Table_1"]
      prd = data.terraform_remote_state.core.outputs.custom_route_tables["Example_Route_Table_1"]
    }
  }
}