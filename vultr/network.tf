resource "vultr_vpc" "hnd3" {
  region         = "nrt"
  v4_subnet      = "192.168.33.0"
  v4_subnet_mask = 24
  description    = "HND3"
}
