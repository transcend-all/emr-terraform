provider "aws" {
  region = var.region
}

resource "aws_emr_cluster" "my_emr_cluster" {
  name          = "MyEMRCluster"  # Cluster name
  release_label = "emr-6.10.0"     # EMR version, required
  service_role  = aws_iam_role.emr_service_role.arn  # Reference the correct role
  applications  = ["Hadoop", "Spark"]  # Add or modify applications as needed


  ec2_attributes {
    key_name                          = var.ec2_key_pair  # Ensure this is defined in your variables
    instance_profile                  = aws_iam_instance_profile.emr_ec2_profile.arn  # Required
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
  }

  log_uri = var.s3_log_uri  # Ensure your S3 bucket URI is valid
  visible_to_all_users = true

  bootstrap_action {
    path = var.s3_path_uri
    name = "Bootstrap Python and PySpark"
  }

      # Define a step to upload files to HDFS
  step {
    name = "Setup HDFS Directories and Upload Data"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = [
        "bash", "-c", 
        "hdfs dfs -mkdir -p /user/hadoop/test_data && hdfs dfs -put /home/hadoop/aws_ratings_dataset.csv /user/hadoop/test_data/"
        ]
      }
    }

  step_concurrency_level = 1


  # Define master instance group
  master_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 1  # At least one master node
  }

  # Define core instance group (optional)
  core_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 2  # Specify at least 1 core node
  }
}


resource "aws_security_group" "emr_master" {
  name_prefix = "emr-master"
  description = "Security group for EMR master nodes"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "emr_slave" {
  name_prefix = "emr-slave"
  description = "Security group for EMR slave nodes"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "emr_service_role" {
  name = "EMR_DefaultRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service_role_policy" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "emr_ec2_role" {
  name = "EMR_EC2_DefaultRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "emr_s3_access_policy" {
  name        = "EMR_S3_Access_Policy"
  description = "Allow EMR to access Bootstrap scripts and data in S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::terraform-data-12sdfg",
          "arn:aws:s3:::terraform-data-12sdfg/*",
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "emr_ec2_profile" {
  name = "EMR_EC2_InstanceProfile"
  role = aws_iam_role.emr_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "emr_ec2_role_policy" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}
