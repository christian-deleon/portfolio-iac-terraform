output "s3_arn" {
  value = aws_s3_bucket.main.arn
}

output "s3_domain_name" {
  value = aws_s3_bucket.main.bucket_domain_name
}

output "s3_website_endpoint" {
  value = aws_s3_bucket.main.website_endpoint
}
