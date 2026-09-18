# ---------------------------------------------------------------------------
# Account-wide monthly cost budget
# ---------------------------------------------------------------------------
# Uses AWS Budgets' built-in email notifications directly -- no SNS topic
# or CloudWatch billing alarm needed. Tracks total account spend, not just
# this lab's resources, since an unattended EKS cluster (see ../eks) is the
# realistic risk this is guarding against.
resource "aws_budgets_budget" "monthly" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.notifications
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold_percent
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.type
      subscriber_email_addresses = var.alert_emails
    }
  }
}
