# Terraform EMR Cluster Setup

This repository provides a Terraform configuration to provision an AWS EMR cluster with Hadoop and Spark installed. It also includes instructions for using bootstrap actions to install additional software on the cluster and manage the required infrastructure on AWS.

## 1. Prerequisites

Before starting, you will need to install Terraform and configure your AWS credentials.

### Install Terraform

#### Windows:
1. Download the [Terraform installer](https://www.terraform.io/downloads.html) for Windows.
2. Extract the downloaded zip file.
3. Add the extracted folder to your system's PATH:
   - Go to "Environment Variables" > "System Variables".
   - Select `Path` > Edit > Add the folder path where `terraform.exe` is located.
4. Open a new command prompt and verify the installation:
   ```bash
   terraform -v
   ```

#### Mac:
1. Using Homebrew, you can install Terraform with the following commands:
   ```bash
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```
2. Verify the installation:
   ```bash
   terraform -v
   ```

#### Linux:
1. Download the Terraform binary:
   ```bash
   wget https://releases.hashicorp.com/terraform/<version>/terraform_<version>_linux_amd64.zip
   ```
   Replace `<version>` with the desired version.
2. Unzip and move it to a directory on your PATH:
   ```bash
   unzip terraform_<version>_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```
3. Verify the installation:
   ```bash
   terraform -v
   ```

## 2. AWS S3 Bucket Setup

You need to create the necessary S3 buckets for storing EMR logs and bootstrap scripts.

### Create S3 Buckets:
1. Log into your AWS Management Console.
2. Navigate to S3 and create two buckets:
   - One for storing the EMR logs.
   - One for storing the EMR bootstrap script.

Take note of the bucket names, as you will need them for the `terraform.tfvars` file.

## 3. Configure `terraform.tfvars`

Define your variables in a `terraform.tfvars` file. This file should contain:

```hcl
ec2_key_pair = "<your_ec2_key_pair_name>"
s3_log_uri   = "s3://<your_log_bucket>"
s3_path_uri  = "s3://<your_bootstrap_bucket>/emr_bootstrap.sh"
region       = "<your_aws_region>"
```

### Example:
```hcl
ec2_key_pair = "my-ec2-keypair"
s3_log_uri   = "s3://my-emr-log-bucket"
s3_path_uri  = "s3://my-emr-bootstrap-bucket/emr_bootstrap.sh"
region       = "us-west-2"
```

## 4. Configure `emr_bootstrap.sh`

You need to upload the `emr_bootstrap.sh` file to your S3 bucket. It contains the steps for bootstrapping your EMR cluster, including installing Python, Pyenv, and PySpark.

1. Upload the `emr_bootstrap.sh` file to the S3 bucket where your bootstrap scripts are stored.
2. Make sure the S3 bucket URI matches the `s3_path_uri` variable in your `terraform.tfvars` file.

## 5. Using Terraform

### Initialize Terraform:
In the directory containing your Terraform files, run the following command to initialize Terraform and download the necessary provider plugins:

```bash
terraform init
```

### Plan the Infrastructure:
To see what Terraform will create, use the `terraform plan` command. This will show you the resources that will be provisioned.

```bash
terraform plan
```

### Apply the Terraform Configuration:
To create the infrastructure, use the `terraform apply` command. This will provision the EMR cluster and associated AWS resources, such as the S3 bucket and IAM roles.

```bash
terraform apply
```

You'll be prompted to confirm the creation of resources. Type `yes` to proceed.

### Destroy the Cluster:
When you are done with the EMR cluster, you can destroy all the resources with:

```bash
terraform destroy
```

## 6. EMR Cluster Overview

The EMR cluster will be set up with the following configurations:

- **Cluster Name**: `MyEMRCluster`
- **Applications**: Hadoop, Spark
- **Master Node**: `m5.xlarge`
- **Core Nodes**: `m5.xlarge`, with a count of 2 (modifiable)

The cluster also includes bootstrap actions to set up PySpark and related dependencies, and a step to upload data from S3 to HDFS.

## 7. Additional Information

- Ensure that you have the appropriate IAM roles and policies attached for EMR and EC2 to access S3 and other AWS resources.
- Make sure your `aws configure` is set up with the correct AWS credentials before running Terraform commands.

---

This `README.md` provides detailed instructions to install Terraform, configure S3 buckets, manage variable files, and use Terraform commands to provision the EMR cluster.