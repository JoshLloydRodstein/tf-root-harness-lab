data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Carve the /16 into small /24s for public + private subnets, one pair per AZ.
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 100)]
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
# terraform-aws-modules/vpc/aws v6.x
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  # Single NAT gateway (not one per AZ) keeps this a cost-conscious lab setup.
  # For production you'd want one_nat_gateway_per_az = true instead.
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags required so the EKS/ELB controllers can auto-discover these subnets.
  public_subnet_tags = {
    "kubernetes.io/role/elb"                     = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"            = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

# ---------------------------------------------------------------------------
# EKS cluster
# ---------------------------------------------------------------------------
# terraform-aws-modules/eks/aws v21.x
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
# NOTE: v21 renamed several variables vs. older tutorials you may find online
# (cluster_name -> name, cluster_version -> kubernetes_version, and the
# aws-auth ConfigMap submodule was removed in favor of EKS access entries).
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Nodes get outbound internet via the NAT gateway; the API endpoint is
  # reachable both publicly (so you can kubectl from your laptop) and from
  # inside the VPC. Fine for a lab; you'd lock this down for production.
  endpoint_public_access  = true
  endpoint_private_access = true

  # Automatically grants the IAM principal running `terraform apply`
  # cluster-admin via an EKS access entry -- this is what saves you from
  # getting locked out of kubectl after the cluster comes up.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # The Harness Delegate + your CI/CD workload pods need a bit of
      # headroom; gp3 is cheaper than the old gp2 default.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 30
            volume_type = "gp3"
          }
        }
      }
    }
  }

  # A couple of the core addons pinned to "most recent compatible" so you
  # don't have to think about addon versions for this lab.
  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }
}
