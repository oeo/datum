#!/bin/bash

S3_BUCKET="datum-env-files"
S3_REGION="us-east-1"

# Check if AWS credentials are set
if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "AWS credentials not configured properly."
  exit 1
fi

# Check if the S3 bucket exists, and create if not
check_create_bucket() {
  if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket does not exist. Creating bucket: $S3_BUCKET in region $S3_REGION"
    if ! aws s3 mb "s3://$S3_BUCKET" --region $S3_REGION; then
      echo "Failed to create bucket. Please check permissions and region settings."
      exit 1
    else
      # Set bucket policy to allow put operations
      aws s3api put-bucket-policy --bucket "$S3_BUCKET" --policy '{
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AllowPutOperations",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::'"$S3_BUCKET"'/*"
          }
        ]
      }'
      echo "Bucket policy set to allow put operations."
    fi
  else
    echo "Bucket $S3_BUCKET found."
  fi
}

# Function to upload files
push_env() {
  check_create_bucket
  for file in .env*; do
    if [ -f "$file" ]; then
      # Create a unique name for S3 to avoid collisions or define your naming convention
      s3_path="$(date +%Y-%m-%d_%H-%M-%S)_$file"
      aws s3 cp "$file" "s3://$S3_BUCKET/$s3_path"
      echo "Uploaded $file to s3://$S3_BUCKET/$s3_path"
    fi
  done
}

# Function to download files and clean up after
pull_env() {
  check_create_bucket
  # Define the local directory to save downloaded files
  local_dir="./"  # Set to current directory to replace files directly

  # Temporary file to hold the list of latest files
  temp_file="$(mktemp)"

  # List all files, filter for .env files, and determine the latest for each group
  aws s3 ls "s3://$S3_BUCKET/" --recursive | grep '.env' | sort -rk1 | while read -r line; do
    key=$(echo $line | awk '{print $4}')
    base_name=$(echo $key | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}_//')  # Strip the timestamp
    if ! grep -q "$base_name" "$temp_file"; then
      echo "$key" >> "$temp_file"  # Add the latest file for each base name
    fi
  done

  # Download the latest files identified
  while read file; do
    local_file_name="${file##*/}"  # Extract just the filename without timestamp
    base_name=$(echo $local_file_name | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}_//')  # Strip the timestamp
    aws s3 cp "s3://$S3_BUCKET/$file" "$local_dir$base_name"
    echo "Downloaded $file to $local_dir$base_name"
  done < "$temp_file"

  # Cleanup
  rm "$temp_file"
  echo "All files have been downloaded and original files replaced."
  # No need to clean the directory further if we're replacing in place
}

# Check command line arguments
case "$1" in
  push)
    push_env
    ;;
  pull)
    pull_env
    ;;
  *)
    echo "Usage: $0 [push|pull]"
    exit 1
    ;;
esac

