resource "aws_redshift_cluster" "default" {
  cluster_identifier = "redshift-cluster"
  database_name      = "agra_replica"
  master_username    = var.redshift_username
  master_password    = var.redshift_password
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  iam_roles = [aws_iam_role.redshift_role.arn]
  vpc_security_group_ids = [aws_security_group.allow_access_to_redshift_from_vpn.id]
  skip_final_snapshot = true
}

resource "aws_security_group" "allow_access_to_redshift_from_vpn" {
  name        = "Allow Prod VPN access to Redshift"
  description = "Allow inbound access from ControlShift VPN"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 5439
    to_port     = 5439
    protocol    = "TCP"
    cidr_blocks = ["52.2.141.10/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}