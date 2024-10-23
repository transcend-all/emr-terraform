#!/bin/bash
set -x
set -e

export S3_SPARK_JOB="s3://path/to/your/spark/job"
export S3_SAMPLE_DATA="s3://path/to/your/sample/data"

# Update and install prerequisites
sudo yum update -y
sudo yum install -y git gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
source ~/.bashrc


pyenv install 3.8.0
pyenv global 3.8.0

# Install PySpark using pip
pip install --upgrade pip
pip install pyspark

# Set environment variables
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" | sudo tee /etc/profile.d/hadoop_conf.sh
echo "export YARN_CONF_DIR=/etc/hadoop/conf" | sudo tee /etc/profile.d/yarn_conf.sh
source /etc/profile.d/hadoop_conf.sh
source /etc/profile.d/yarn_conf.sh

# Download test Spark job and data from S3
# Replace with your actual S3 bucket and paths
aws s3 cp $S3_SPARK_JOB /home/hadoop/
aws s3 cp $S3_SAMPLE_DATA /home/hadoop/

echo "Bootstrap actions completed successfully."
