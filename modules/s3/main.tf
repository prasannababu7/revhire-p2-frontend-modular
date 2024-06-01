#Creating a s3 bucket
resource "aws_s3_bucket" "myfrontendbucket" {
  bucket = var.frontend-bucket-name
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.myfrontendbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Giving public access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.myfrontendbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#Disabling acl controls
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.myfrontendbucket.id
  acl    = "private"
}

# Bucket policy to allow public read access to objects
resource "aws_s3_bucket_policy" "mybucket_policy" {
  bucket = aws_s3_bucket.myfrontendbucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
				"s3:GetObject",
				"s3:PutObject"
			]
        Resource  = "${aws_s3_bucket.myfrontendbucket.arn}/*"
      }
    ]
  })
}

#Enabling static web hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.myfrontendbucket.id
  index_document {
    suffix = "index.html"
  }
}
