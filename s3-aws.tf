provider "aws" {
  region  = "sa-east-1"
  access_key = "sua chave"
  secret_key = "sua chave secreta"
}

resource "aws_s3_bucket" "bucket-luis" {
  bucket = "meu-bucket-1993"

  tags = {
    Name        = "Meu Bucket"
    Environment = "DevOps"
  }
}

# ACL para o bucket ser privado ou publico
resource "aws_s3_bucket_acl" "exemplo" {
  bucket = aws_s3_bucket.bucket-luis.id
  acl    = "private"
}