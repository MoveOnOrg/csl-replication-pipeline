resource "aws_redshift_subnet_group" "all_subnets" {
  name       = "all-subnets"
  subnet_ids = data.aws_subnet_ids.default.ids
}

resource "aws_redshift_cluster" "default" {
  cluster_identifier = "redshift-cluster"
  database_name      = "agra_replica"
  master_username    = var.redshift_username
  master_password    = var.redshift_password
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  iam_roles = [aws_iam_role.redshift_role.arn]
  cluster_subnet_group_name = aws_redshift_subnet_group.all_subnets.name
  vpc_security_group_ids = [aws_security_group.allow_access_from_everywhere.id]
  skip_final_snapshot = true
  publicly_accessible = true
}

resource "aws_iam_role" "redshift_role" {
  name = "RedshiftRole"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
}

data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "redshift_loads_s3" {
  name = "AllowsRedshiftS3Access"
  role = aws_iam_role.redshift_role.id
  policy = data.aws_iam_policy_document.redshift_load_policy.json
}

data "aws_iam_policy_document" "redshift_load_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:Get*", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::controlshift-redshift-load-manifests/*",
      "arn:aws:s3:::agra-data-exports-${var.controlshift_environment}/*",
      "arn:aws:s3:::agra-data-exports-${var.controlshift_environment}"
    ]
  }
}

// You'll probably want to customize this if you're running Redshift in production
resource "aws_security_group" "allow_access_from_everywhere" {
  name        = "Allow anything, anywhere to access Redshift"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // equivalent to all
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" // equivalent to all
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
