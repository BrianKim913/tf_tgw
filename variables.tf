variable "eks_vpc_name" {
  description = "Name tag of the EKS VPC"
  type        = string
  default     = "eks-vpc"
}

variable "vpn_vpc_name" {
  description = "Name tag of the VPN VPC"
  type        = string
  default     = "vpn-vpc"
}

variable "eks_vpc_cidr" {
  description = "CIDR block of the EKS VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpn_vpc_cidr" {
  description = "CIDR block of the VPN VPC"
  type        = string
  default     = "10.0.0.0/16"
}