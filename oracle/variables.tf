variable "user_ocid" {
  type = string
}

variable "api_rsa_key" {
  type = object({
    private_key_path = string
    fingerprint      = string
  })
}
