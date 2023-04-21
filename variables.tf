variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to use. All resources will be created in this region."
}

variable "redshift_schema" {
  type  = string
  default = "public"
  description = "The redshift schema to load tables into"
}

variable "manifest_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store manifests of ingests processed in"
}
variable "manifest_prefix" {
  default = "manifests/"
  type        = string
  description = "A file prefix that will be used for manifest logs on success"
}
variable "failed_manifest_prefix" {
  default = "failed/"
  type        = string
  description = "A file prefix that will be used for manifest logs on failure"
}
variable "success_topic_name" {
  default = "ControlshiftLambdaLoaderSuccess"
  type        = string
  description = "An SNS topic name that will be notified about batch processing successes"
}
variable "failure_topic_name" {
  default = "ControlshiftLambdaLoaderFailure"
  type        = string
  description = "An SNS topic name that will be notified about batch processing failures"
}

variable "controlshift_hostname" {
  default = "staging.controlshiftlabs.com"
  type        = string
  description = "The hostname of your ControlShift instance. Likely to be something like action.myorganization.org"
}

variable "receiver_timeout" {
  default = 60
  type        = number
  description = "The timeout for the receiving Lambda, in seconds"
}

variable "redshift_cluster_identifier" {
  type = string
  description = "The target Redshift cluster ID"
}

variable "controlshift_organization_slug" {
  type = string
  description = "The organization's slug in ControlShift platform. Ask support team (support@controlshiftlabs.com) to find this value."
}

variable "glue_scripts_bucket_name" {
  type        = string
  description = "Your S3 bucket name to store Glue scripts in"
}

variable "lambda_loader_subnet_ids" {
  type = list(string)
  description = "List of subnet IDs where AWS Lambda may be run. Add more than one for Multi AZ reliability"
  default = []
}

variable "lambda_loader_security_group_ids" {
  type = list(string)
  description = "List of AWS security groups IDs that should be assigned to the lambda that loads tables into Redshift"
  default = []
}

variable "glue_physical_connection_requirements" {
  type = object({ availability_zone=string, subnet_id=string, security_group_id_list=list(string) })
  description = "A terraform map of the physical_connection_requirements property of the glue redshift connection. See Terraform aws_glue_connection docs."
  default = null
}

variable "email_open_firehose_stream" {
  type        = string
  description = "The name of a Firehose stream that will receive email open events."
  default = ""
}

variable "email_click_firehose_stream" {
  type        = string
  description = "The name of a Firehose stream that will receive email click events."
  default = ""
}

variable "vpc_id" {
  type        = string
}
