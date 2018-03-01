##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "subnet_count" {
  default = 2
}

################################
##   ENVIRONMENTS VARIABLES   ##
################################
variable "shared_credentials" {}
variable "your_profile" {}

variable "platform_region" {
  default             = "eu-west-2"
}
