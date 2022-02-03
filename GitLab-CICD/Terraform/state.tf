terraform {
    backend "s3" {
        bucket         = "akhilz-terraform-state"
        key            = "state/terraform.tfstate"
        region         = "ap-south-1"
        encrypt        = true
        dynamodb_table = "akhilz-terraform-locks"
        shared_credentials_file = "~/.aws/credentials"
        profile = "akhilz-aws"
    }
}
# resource "aws_s3_bucket" "terraform_state" {
#     bucket = "akhilz-terraform-state"
#     acl    = "private"
#     # Enable versioning so we can see the full revision history of our
#     # state files
#     versioning {
#         enabled = true
#     }
#     # Enable server-side encryption by default
#     server_side_encryption_configuration {
#         rule {
#             apply_server_side_encryption_by_default {
#                 sse_algorithm = "AES256"
#             }
#         }
#     }
# }

# resource "aws_s3_bucket_public_access_block" "terraform_state_s3_block" {
#     bucket = aws_s3_bucket.terraform_state.id
#     block_public_acls       = true
#     block_public_policy     = true
#     ignore_public_acls      = true
#     restrict_public_buckets = true
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#     name         = "akhilz-terraform-locks"
#     billing_mode = "PAY_PER_REQUEST"
#     hash_key     = "LockID"
#     attribute {
#         name = "LockID"
#         type = "S"
#     }
# }