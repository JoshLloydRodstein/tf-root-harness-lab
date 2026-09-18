output "budget_name" {
  description = "Name of the created AWS Budgets cost budget"
  value       = aws_budgets_budget.monthly.name
}

output "budget_arn" {
  description = "ARN of the created AWS Budgets cost budget"
  value       = aws_budgets_budget.monthly.arn
}

output "monthly_limit_usd" {
  description = "Monthly spend limit this budget tracks against"
  value       = var.monthly_limit_usd
}
