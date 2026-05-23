output "region" {
  description = "The AWS region where resources are created"
  value       = local.region
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}


output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}


output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.testinstance.public_ip
}

output "eks_node_group_public_ips" {
  description = "Public IPs of the EKS node group instances"
  value       = data.aws_instances.eks_nodes.public_ips
}
# 1. Output for the EKS Nodes Data Source
# (Data sources usually return a list of IDs rather than a single ID)
output "eks_node_ids" {
  description = "The list of Instance IDs for the EKS nodes"
  value       = data.aws_instances.eks_nodes.ids
}

# 3. Output for the Bastion Host Instance ID
output "bastion_host_instance_id" {
  description = "The AWS Instance ID for the Bastion Host"
  value       = aws_instance.bastion_host.id
}

# 4. Output for the Test Instance ID
output "test_instance_id" {
  description = "The AWS Instance ID for the Test Instance"
  value       = aws_instance.testinstance.id
}
