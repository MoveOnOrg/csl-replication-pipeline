## Bulk Data API Redshift Pipeline Example

An example of using our [Terraform](https://www.terraform.io/) module for implementing a data ETL pipeline from [ControlShift](https://www.controlshiftlabs.com) to [Amazon Redshift](https://aws.amazon.com/redshift/).

The output of this plan is a replica of all of the tables that underlie your ControlShift instance in a new Redshift instance which allows for querying via SQL or other analysis.

If you are already using Terraform or Redshift it is probably best to either fork this example or [use the module we provide directly in your own plan](https://registry.terraform.io/modules/controlshift/controlshift-redshift-sync/aws/).

### Overview

The Terraform plan sets up resources in your AWS environment to process webhooks generated by the [ControlShift Bulk Data API.](https://developers.controlshiftlabs.com/#bulk-data) 

The integration is based on the [aws-lambda-redshift-loader](https://github.com/awslabs/aws-lambda-redshift-loader) provided by AWS but replaces the manual setup steps from their README with a Terraform plan. In addition the Terraform plan includes resourced that are specific to accepting ControlShift Bulk Data API webhooks.

The resources created include:

- DynamoDB tables that store configuration information and logs each table load processed.
- Lambda functions that process incoming webhooks, store CSV files onto S3 and load those files into tables in Redshift.
- S3 buckets for storing incoming S3 CSVs and manifests of load activity.
- A Web API Gateway to connect AWS Lambdas to the web.
- IAM permissions to make everything work securely.


### Prerequisites

- Familiarity with Amazon Web Services, Redshift, and Terraform
- Use of [aws-vault](https://github.com/99designs/aws-vault) or a similar tool for using AWS secrets securely. 
- The `terraform` command line tool. [Download](https://www.terraform.io/downloads.html) 

### Setup Tables in Redshift

For the ingest process to work correctly, tables that match the output of the ControlShift Bulk Data API must be setup in Redshift first. We've provided a create_tables.rb script that will use the [ControlShift Bulk Data Schema API](https://developers.controlshiftlabs.com/#bulk-data-schema) to generate `CREATE TABLE` DDL statements that you'll need to run to populate the tables for ingest.

First generate the DDL statements, and then apply them manually in your Redshift environment.
```
./create_tables.rb > tables.sql
```

### Terraform Variables

Terraform input variables are defined in variables.tf. You'll want to create your own `terraform.tfvars` file with the correct values for your specific environment.

Name | Description
------------ | -------------
aws_region | The AWS Region to use. Should match the location of your Redshift instance
redshift_username | Redshift Username to use for database loads
redshift_password | Redshift Password to use for database loads
receiver_bucket_name | Your S3 bucket name ingest CSVs will be stored in. Terraform will create this bucket for you. Must be globally unique.
manifest_bucket_name | Your S3 bucket name to store manifests of ingests processed in. Terraform will create this bucket for you. Must be globally unique.
manifest_prefix | A file prefix that will be used for manifest logs on success
failed_manifest_prefix | A file prefix that will be used for manifest logs on failure
success_topic_name | An SNS topic name that will be notified about batch processing successes
failure_topic_name | An SNS topic name that will be notified about batch processing failures
redshift_database_name | The name of the Redshift database to use
redshift_dns_name | The hostname of the Redshift instance
redshift_port | The port on which to connect to Redshift
redshift_schema | The name of the Redshift schema to use
controlshift_hostname | The hostname of your ControlShift instance. Likely to be something like action.myorganization.org
receiver_timeout | The timeout for the receiving Lambda, in hundredths of a second


### Terraform State S3 Backend

Terraform stores the current state and configuration of your infrastructure in a `terraform.tfstate` file. By default, this is stored on the local filesystem. However, teams may wish to use remote storage to facilitate collaboration. To use S3 as the remote state backend, the bucket must be created manually (ideally with versioning and encryption enabled, and public access disabled) and the bucket, key, and region values entered into `terraform.tf`.

For more information, see Terraform's documentation on [State](https://www.terraform.io/docs/state/index.html) and the [S3 backend](https://www.terraform.io/docs/backends/types/s3.html).


### Run Terraform

You'll need:

- AWS Credentials with rather broad permissions in your environment.
- AWS restricts certain IAM operations this terraform plan uses to credentials that have been authenticated with MFA.

As a result using `aws-vault` or a similar tool to assume a role with the correct permissions, protected by MFA is probably necessary.

Check out a copy of this repository locally, and then in the project directory:

```bash
# download the terraform dependencies and initialize the directory
aws-vault exec bulk-data -- terraform init
# use aws-vault to generate temporary AWS session credentials using the bulk-data profile and then use them to apply the plan
aws-vault exec bulk-data -- terraform apply
```

#### Issues
Make sure you create the S3 bucket to *store* the Terraform config, but do not manually create the other buckets.
Terraform will try to make IAM roles named `ReceiverLambdaRole` and `APIGatewayRole` - which already exist if you're trying to set up two syncs.
It will also try to create an already existing KMS alias `LambaRedshiftLoaderKey`.

`success_topic_name` and `failure_topic_name` need to be distinct per region as well.  Set them to appropriate values.

The `AllowsLoaderExecution` policy for `LoaderLambdaRole` needs to be name_prefix not name.

You can import the existing resources:
```terraform import module.terraform-aws-controlshift-redshift-sync.aws_iam_role.receiver_lambda_role 'ReceiverLambdaRole'
terraform import module.terraform-aws-controlshift-redshift-sync.aws_iam_role.api_gateway_role 'APIGatewayRole'
terraform import module.terraform-aws-controlshift-redshift-sync.aws_kms_alias.lambda_alias 'alias/LambaRedshiftLoaderKey'
```
If Terraform claims to be already managing the resource, remove the old resource from the config first, then try again:
`terraform state rm module.terraform-aws-controlshift-redshift-sync.aws_iam_role.receiver_lambda_role`

The output of the terraform plan is a Webhook URL. You'll need to configure this in your instance of the ControlShift platform via Settings > Integrations > Webhooks.

Once the webhook is configured it should populate the tables within your Redshift instance nightly. Alternatively, you can use the "Test Ingest" feature to trigger a full-table refresh on demand from the ControlShift web UI.

In order to use AWS Glue, you'll need to set `redshift_security_group_id` to the id of a security group set to allow all inbound TCP connections.  Assuming your system is sane, you won't have one of those already, so create one and set the variable.  You'll also need to create a [VPC Gateway endpoint](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html) for S3; Terraform won't make one for you.

### Logs and Debugging

The pipeline logs its activity several places that are useful for debugging. 

- In CloudWatch Logs of Lambda and S3 activity. 
- In DynamoDB tables for each manifest.
- In Redshift, in the Loads tab of your datawarehouse instance. 
- In each manifest load whose results stored in S3. 
- Notifications are sent to the configured SNS topics for each batch processing success or failure. Add a subscription in the SNS console in AWS for the topic you want to receive notifications for (e.g., by email). The [aws-lambda-redshift-loader](https://github.com/awslabs/aws-lambda-redshift-loader) repository contains a Lambda function that can be used to automatically reprocess failed batches by subscribing the Lambda to the failure SNS topic.
