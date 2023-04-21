data "aws_secretsmanager_secret" "redshift_admin" {
  arn = "arn:aws:secretsmanager:us-west-1:756917843633:secret:redshift-admin-FX6ihQ"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.redshift_admin.id
}