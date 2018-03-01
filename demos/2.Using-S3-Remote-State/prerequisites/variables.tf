################################
##   ENVIRONMENTS VARIABLES   ##
################################
variable "shared_credentials" {}
variable "your_profile" {}

variable "platform_region" {
  default             = "eu-west-2"
}

variable "aws_networking_bucket" {
    default = "ddt-networking-sandbox-ps"
}
variable "aws_application_bucket" {
    default = "ddt-application-sandbox-ps"
}
variable "aws_dynamodb_table" {
    default = "ddt-tfstatelock"
}

variable "user_home_path" {}
