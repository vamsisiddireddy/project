variable "AMIS" {
type = string
default = "ami-0e28d1cdcad6daa16"
}

variable "VPC_NAME" {
default = "project-vpc"
}

variable "Type" {
  default = "t2.micro"
}
variable "zone1" {
default = "ap-south-1a"
}

variable "zone2" {
default = "ap-south-1b"
}

variable "vpc_cidr" {
default = "10.0.0.0/16"
}

variable "pubsub1" {
default = "10.0.1.0/24"
}

variable "pubsub2" {
default = "10.0.2.0/24"
}

variable "pvtsub1" {
default = "10.0.3.0/24"
}

variable "pvtsub2" {
default = "10.0.4.0/24"
}

