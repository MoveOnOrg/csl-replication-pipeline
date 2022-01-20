data "aws_subnet" "subnet_in_redshift_zone" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }

  filter {
    name = "availability-zone"
    values = [ aws_redshift_cluster.default.availability_zone ]
  }
}

module "terraform-aws-controlshift-redshift-sync" {
  source = "git@github.com:MoveOnOrg/terraform-aws-controlshift-redshift-sync.git"
  redshift_username = var.redshift_username
  redshift_password = var.redshift_password
  version = ">= 0.6"


  aws_region = var.aws_region
  controlshift_environment = var.controlshift_environment
  controlshift_hostname = var.controlshift_hostname
  controlshift_organization_slug = var.controlshift_organization_slug
  failed_manifest_prefix = var.failed_manifest_prefix
  failure_topic_name = var.failure_topic_name
  failure_topic_name_for_run_glue_job_lambda = var.failure_topic_name_for_run_glue_job_lambda
  glue_scripts_bucket_name = var.glue_scripts_bucket_name
  glue_physical_connection_requirements = {
    availability_zone = aws_redshift_cluster.default.availability_zone,
    subnet_id = data.aws_subnet.subnet_in_redshift_zone.id,
    security_group_id_list = aws_redshift_cluster.default.vpc_security_group_ids
  }
  manifest_bucket_name = var.manifest_bucket_name
  glue_scripts_bucket_name = var.glue_scripts_bucket_name
  redshift_cluster_identifier = var.redshift_cluster_identifier
  controlshift_organization_slug = var.controlshift_organization_slug
  manifest_prefix = var.manifest_prefix
  lambda_loader_subnet_ids = var.lambda_loader_subnet_ids
  lambda_loader_security_group_ids = var.lambda_loader_security_group_ids
  email_open_firehose_stream = var.email_open_firehose_stream
  email_click_firehose_stream = var.email_click_firehose_stream
  receiver_timeout = var.receiver_timeout
  redshift_cluster_identifier = aws_redshift_cluster.default.id
  redshift_database_name = aws_redshift_cluster.default.database_name
  redshift_password = var.redshift_password
  redshift_schema = var.redshift_schema
  redshift_username = var.redshift_username
  success_topic_name = var.success_topic_name
  success_topic_name_for_run_glue_job_lambda = var.success_topic_name_for_run_glue_job_lambda
  vpc_id = data.aws_vpc.default.id
}
