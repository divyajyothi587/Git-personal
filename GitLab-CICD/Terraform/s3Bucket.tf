resource "aws_s3_bucket" "frontend_bucket_name" {
    bucket = var.frontend_bucket_name
    acl = "public-read"
    policy = templatefile("template/publicBucketPolicy.json.tmpl", {
        bucket_name = "${var.frontend_bucket_name}"
    })
    tags = {
        Name = var.frontend_bucket_name
        Environment = "Dev"
        Application = "Frontend"
    }
    versioning {
        enabled = false
    }
    website {
        index_document = "index.html"
    }
}

resource "aws_s3_bucket_public_access_block" "frontend_s3_block" {
    bucket = aws_s3_bucket.frontend_bucket_name.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}


