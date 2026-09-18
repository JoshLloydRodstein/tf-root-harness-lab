# Budgets & billing alert — Harness FDE take-home lab

Account-wide monthly cost budget with email alerts, standing in for Phase 0's "billing alert set" prerequisite before any billable phase (the EKS cluster in `../eks` is the main unattended-cost risk this guards against).

## What this creates

- One `aws_budgets_budget` (COST, MONTHLY) tracking **total account spend**, not just this lab's resources.
- Email notifications via AWS Budgets' built-in subscriber emails — no SNS topic or CloudWatch billing alarm needed.
- Default thresholds: 80% of the limit on **actual** spend, 100% on **forecasted** spend for the month (see `variables.tf` / `terraform.tfvars.example` to change).

## Prerequisites

- Terraform >= 1.5.7 (`terraform -version`)
- AWS CLI configured with credentials for the account this budget should track (`aws sts get-caller-identity`)
- IAM permissions to manage AWS Budgets (`budgets:*` — same sandbox-account reasoning as `../eks`'s README applies)

## Usage

```bash
# 1. Set your real limit and email(s) -- there are no defaults for these two
#    on purpose, so you can't apply this without deciding both.
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: monthly_limit_usd and alert_emails

# 2. Init, plan, apply
terraform init
terraform plan
terraform apply
```

AWS Budgets emails a confirmation-style notification the first time a threshold is configured for a new address; after that, alerts arrive automatically whenever spend crosses a threshold. Budget evaluation runs roughly daily, not in real time — this catches a cluster left running overnight, not a single expensive API call.

## Cost & teardown

AWS Budgets itself is free for a small number of budgets per account (check current AWS Budgets pricing if you end up creating many). There's no meaningful teardown cost concern here, but `terraform destroy` removes the budget/alerts if you no longer want them.

## Notes

- This tracks **total account cost**, deliberately not scoped to EKS-tagged resources only — the goal is "don't get surprised by the bill," not "attribute cost to this one lab."
- `monthly_limit_usd` and `alert_emails` have no defaults; `terraform plan`/`apply` will fail with a clear prompt until you set them in `terraform.tfvars`.
