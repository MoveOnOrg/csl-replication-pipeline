module "terraform-aws-controlshift-redshift-sync" {
  source = "git@github.com:MoveOnOrg/terraform-aws-controlshift-redshift-sync.git"
  redshift_username = var.redshift_username
  redshift_password = var.redshift_password
  receiver_bucket_name = var.receiver_bucket_name
  manifest_bucket_name = var.manifest_bucket_name
  manifest_prefix = var.manifest_prefix
  failed_manifest_prefix = var.failed_manifest_prefix
  success_topic_name = var.success_topic_name
  failure_topic_name = var.failure_topic_name
  aws_region = var.aws_region
  redshift_database_name = var.redshift_database_name
  redshift_dns_name = var.redshift_dns_name
  redshift_port = var.redshift_port
  redshift_schema = var.redshift_schema
  controlshift_hostname = var.controlshift_hostname
  receiver_timeout = var.receiver_timeout
}
