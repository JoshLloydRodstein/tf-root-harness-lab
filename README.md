# EKS cluster — Harness FDE take-home lab

Minimal, cost-conscious EKS cluster for Phase 1 of the Harness lab (K8s cluster setup), sized so the Harness Delegate and a small CI/CD workload can run comfortably without over-provisioning.

## What this creates

- A VPC (`terraform-aws-modules/vpc/aws` v6.x) with public + private subnets across 2 AZs, one NAT gateway (not one per AZ, to save cost).
- An EKS cluster (`terraform-aws-modules/eks/aws` v21.x), Kubernetes 1.34, with one managed node group: 2x `t3.medium` (gp3 30GB disks), min 1 / max 3 for basic autoscaling headroom.
- Core addons: coredns, kube-proxy, vpc-cni, eks-pod-identity-agent.
- Cluster access: `enable_cluster_creator_admin_permissions = true` grants whoever runs `terraform apply` cluster-admin automatically via an EKS access entry, so there's no separate aws-auth ConfigMap step.

## Prerequisites

- Terraform >= 1.5.7 (`terraform -version`)
- AWS CLI configured with credentials for your **new** AWS account (`aws configure`, or `aws sso login` if you set up SSO) — confirm with `aws sts get-caller-identity`
- `kubectl` installed
- IAM permissions: for a personal sandbox account, your user/role having `AdministratorAccess` is the path of least resistance for a one-off lab. If this were a real customer environment you'd scope this down considerably — worth mentioning if it comes up in the interview debrief.

## Usage

```bash
# 1. Review/adjust variables (region, instance size, etc.)
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars if you want to change anything from the defaults

# 2. Init, plan, apply
terraform init
terraform plan
terraform apply

# 3. Point kubectl at the new cluster (Terraform prints this exact command
#    as the `configure_kubectl` output too)
aws eks update-kubeconfig --region us-east-1 --name harness-fde-lab

# 4. Sanity check
kubectl get nodes
```

`terraform apply` typically takes 10-15 minutes — EKS control plane provisioning is slow. Grab a coffee.

## Cost & teardown

The EKS control plane is a flat **~$0.10/hr (~$73/mo)** regardless of load — it's not covered by AWS Free Tier. Add EC2 (2x t3.medium ≈ $0.0832/hr combined), one NAT gateway (~$0.045/hr + data), and EBS volumes on top. Given the billing trouble on the prior AWS account, **don't leave this running unattended**:

```bash
terraform destroy
```

Run this at the end of each work session and `terraform apply` again next time you pick the lab back up — recreating the cluster costs you ~10-15 minutes, not dollars.

## Known gotchas (things that bite people on this module version)

- If you've followed older Harness/EKS tutorials online, they likely reference `terraform-aws-modules/eks/aws` v19 or v20. This config uses **v21**, which renamed `cluster_name` → `name` and `cluster_version` → `kubernetes_version`, and removed the old `aws-auth` ConfigMap submodule in favor of EKS access entries (handled here via `enable_cluster_creator_admin_permissions`). If you copy snippets from an older blog post, expect variable-name mismatches.
- `terraform apply` needs outbound internet from wherever you run it (to reach the AWS API and the Terraform Registry to download modules/providers).
- If `kubectl get nodes` hangs or errors with an auth issue right after apply, double check `aws sts get-caller-identity` is returning the **same** identity that ran `terraform apply` — access entries are tied to that specific IAM principal.
