variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "harness-fde-lab"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version (must be a currently-supported EKS version)"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across (EKS requires >= 2)"
  type        = number
  default     = 2
}

variable "node_instance_types" {
  description = "EC2 instance type(s) for the managed node group. t3.medium is the cost-conscious default with enough headroom for the Harness Delegate + a couple of workload pods."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}
