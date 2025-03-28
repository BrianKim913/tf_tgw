provider "aws" {
  region = "ap-northeast-2" 
}

# Look up EKS VPC by name tag
data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.eks_vpc_name]
  }
}

# Look up VPN VPC by name tag
data "aws_vpc" "vpn_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpn_vpc_name]
  }
}

# Look up EKS private subnets
data "aws_subnets" "eks_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["private-subnet-*"]
  }
}

# Look up VPN private subnets
data "aws_subnets" "vpn_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpn_vpc.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["vpn-private-subnet-*"]
  }
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway connecting VPN and EKS VPCs"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name = "eks-vpn-transit-gateway"
  }
}

# Attach EKS VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "eks_attachment" {
  subnet_ids         = data.aws_subnets.eks_private_subnets.ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.aws_vpc.eks_vpc.id
  
  tags = {
    Name = "eks-tgw-attachment"
  }
}

# Attach VPN VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "vpn_attachment" {
  subnet_ids         = data.aws_subnets.vpn_private_subnets.ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.aws_vpc.vpn_vpc.id
  
  tags = {
    Name = "vpn-tgw-attachment"
  }
}

# Get EKS VPC route tables
data "aws_route_tables" "eks_route_tables" {
  vpc_id = data.aws_vpc.eks_vpc.id
}

# Get VPN VPC route tables
data "aws_route_tables" "vpn_route_tables" {
  vpc_id = data.aws_vpc.vpn_vpc.id
}

# Add routes in EKS VPC to VPN VPC
resource "aws_route" "eks_to_vpn" {
  count                  = length(data.aws_route_tables.eks_route_tables.ids)
  route_table_id         = data.aws_route_tables.eks_route_tables.ids[count.index]
  destination_cidr_block = var.vpn_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Add routes in VPN VPC to EKS VPC
resource "aws_route" "vpn_to_eks" {
  count                  = length(data.aws_route_tables.vpn_route_tables.ids)
  route_table_id         = data.aws_route_tables.vpn_route_tables.ids[count.index]
  destination_cidr_block = var.eks_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}