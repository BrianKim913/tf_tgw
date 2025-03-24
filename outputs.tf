output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "eks_vpc_id" {
  description = "ID of the EKS VPC"
  value       = data.aws_vpc.eks_vpc.id
}

output "vpn_vpc_id" {
  description = "ID of the VPN VPC"
  value       = data.aws_vpc.vpn_vpc.id
}

output "eks_private_subnet_ids" {
  description = "IDs of the EKS private subnets"
  value       = data.aws_subnets.eks_private_subnets.ids
}

output "vpn_private_subnet_ids" {
  description = "IDs of the VPN private subnets"
  value       = data.aws_subnets.vpn_private_subnets.ids
}