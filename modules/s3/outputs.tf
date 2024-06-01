output "static_web_hosting_url" {
  value = aws_s3_bucket.myfrontendbucket.website_endpoint
}