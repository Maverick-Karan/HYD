output "account_id" {
  value = aws_organizations_account.new_account.id
}

output "role_arn" {
  value = aws_iam_role.jenkins_role.arn
}
