module "terraform-aws-controlshift-redshift-sync" {
  source = "controlshift/controlshift-redshift-sync/aws"
  redshift_username = var.redshift_username
  redshift_password = var.redshift_password
  receiver_bucket_name = var.receiver_bucket_name
  manifest_bucket_name = var.manifest_bucket_name
  manifest_prefix = var.manifest_prefix
  failed_manifest_prefix = var.failed_manifest_prefix
  aws_region = var.aws_region
  redshift_database_name = aws_redshift_cluster.default.database_name
  redshift_dns_name = aws_redshift_cluster.default.dns_name
  redshift_port = aws_redshift_cluster.default.port
  controlshift_environment = var.controlshift_environment
}
