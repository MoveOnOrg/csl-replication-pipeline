module "terraform-aws-controlshift-redshift-sync" {
  source = "git@github.com:MoveOnOrg/terraform-aws-controlshift-redshift-sync.git"
  redshift_username = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  redshift_password = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]
  manifest_bucket_name = var.manifest_bucket_name
  glue_scripts_bucket_name = var.glue_scripts_bucket_name
  redshift_cluster_identifier = var.redshift_cluster_identifier
  controlshift_organization_slug = var.controlshift_organization_slug
  manifest_prefix = var.manifest_prefix
  failed_manifest_prefix = var.failed_manifest_prefix
  success_topic_name = var.success_topic_name
  failure_topic_name = var.failure_topic_name
  aws_region = var.aws_region
  redshift_database_name = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["dbName"]
  redshift_schema = var.redshift_schema
  controlshift_hostname = var.controlshift_hostname
  receiver_timeout = var.receiver_timeout
  lambda_loader_subnet_ids = var.lambda_loader_subnet_ids
  lambda_loader_security_group_ids = var.lambda_loader_security_group_ids
  glue_physical_connection_requirements = var.glue_physical_connection_requirements
  email_open_firehose_stream = var.email_open_firehose_stream
  email_click_firehose_stream = var.email_click_firehose_stream
  vpc_id=var.vpc_id
}
