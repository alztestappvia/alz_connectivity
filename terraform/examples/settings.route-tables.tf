locals {
  route_tables = {
    "Example_Route_Table_1" = {       # The name of the Virtual Hub Route Table - Cannot contain spaces
      location = var.primary_location # Used to associate with the Virtual Hub in the same location
      labels = [
        "ExampleHubRouteTable" # Optional list of labels
      ]
      routes = {
        "Main" = {                                                          # The name of the Route
          destinations      = ["10.0.0.0/8"]                                # A list of destinations
          destinations_type = "CIDR"                                        # The destination type (also supports 'ResourceId' and 'Service')
          next_hop          = local.vwan_firewall_ids[var.primary_location] # The ResourceId of the next hop
        }
      }
    }
  }
}