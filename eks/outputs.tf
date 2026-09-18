output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS control plane API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "region" {
  description = "AWS region the cluster was deployed into"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Run this to point your local kubectl at the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "estimated_monthly_cost_note" {
  description = "Rough cost reminder"
  value       = "~$73/mo for the EKS control plane alone (flat $0.10/hr) + EC2/EBS/NAT gateway costs for the node group. Run `terraform destroy` when you're not actively using the cluster."
}
