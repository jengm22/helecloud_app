variable "profile" {
  default = "ci-prod"
}

variable "region" {
  default = "eu-west-1"
}

variable "vpc" {
  default = "sand"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}
