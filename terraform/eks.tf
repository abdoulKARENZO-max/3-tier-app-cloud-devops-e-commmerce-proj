resource "aws_security_group" "node_group_remote_access" {
  name   = "allow HTTP"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_node_security_group                 = false
  node_security_group_id                      = aws_security_group.node_group_remote_access.id
  create_cluster_primary_security_group_tags  = false # Floci doesn't populate cluster_security_group_id

  enable_irsa = false # Floci doesn't populate identity.oidc.issuer

  cluster_security_group_additional_rules = {
    access_for_bastion_jenkins_hosts = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all HTTPS traffic from jenkins and Bastion host"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
    }
  }

  # cluster_addons removed — DescribeAddonVersions not implemented on Floci

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types                        = ["t2.micro", "t3.micro"]
    attach_cluster_primary_security_group = false
  }

  eks_managed_node_groups = {
    tws-demo-ng = {
      min_size                   = 1
      max_size                   = 3
      desired_size               = 1
      instance_types             = ["t2.micro", "t3.micro"]
      capacity_type              = "SPOT"
      disk_size                  = 35
      use_custom_launch_template = false
      remote_access = {
        ec2_ssh_key               = resource.aws_key_pair.deployer.key_name
        source_security_group_ids = [aws_security_group.node_group_remote_access.id]
      }
      tags = {
        Name        = "tws-demo-ng"
        Environment = "dev"
        ExtraTag    = "e-commerce-app"
      }
    }
  }

  tags = local.tags
}

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}
