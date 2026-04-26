output "github_actions_role_arn" {
  description = "ARN du rôle que GitHub Actions va assumer"
  value       = aws_iam_role.github_actions.arn
}