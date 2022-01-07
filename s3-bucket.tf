resource "aws_s3_bucket" "bucket" {
  bucket = "devops-ps-project-bucket"
  acl    = "private"

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "bucket"
    project     = "awsdevops-ps"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "devops-ps-project-bucket"
  key    = "appspec.yml"
  source = "${abspath(path.root)}/appspec.yml"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  // etag = filemd5("${abspath(path.root)}/appspec.yml")
  depends_on = [
    aws_s3_bucket.bucket, null_resource.appspec-file
  ]
}