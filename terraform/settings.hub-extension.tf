locals {
  hub_extensions = {
    (var.primary_location) : {
      address_space  = ["172.28.2.0/27", "172.28.2.64/26"]
      deploy_bastion = true
    }
    (var.secondary_location) : {
      address_space = ["172.28.130.0/27"]
    }
  }
}
