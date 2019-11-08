terraform {
  required_version = "0.12.13"
  backend "s3" {
    bucket = "digital-signature-terraform-infra"
    key    = "development"
    region = "us-east-1"
  }
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

variable environment {

}


provider "aws" {
  version = "~> 2.7"
  max_retries = 20
  profile = "default"
}
data "template_file" "website-hosting-policy" {
  template = "${file("${path.module}/policies/website-policy.tpl")}"

  vars = {
    bucket = "avanzarit.s3-explorer-website"
  }
}

data "template_file" "user-access-policy" {
  template = "${file("${path.module}/policies/user-access-policy.tpl")}"

  vars = {
    bucket = "emami-paper.unsigned-doc-bucket"
  }
}

resource "aws_s3_bucket" "unsigned-doc-bucket" {
  bucket = "emami-paper.unsigned-doc-bucket"
  acl    = "private"
}

resource "aws_s3_bucket" "website-bucket" {
  bucket = "avanzarit.s3-explorer-website"
  acl    = "public-read"
  policy = data.template_file.website-hosting-policy.rendered

   website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index-html" {
  bucket = aws_s3_bucket.website-bucket.bucket
  key    = "index.html"
  source = "../index.html"
  etag = "${filemd5("../index.html")}"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "explorer-js" {
  bucket = aws_s3_bucket.website-bucket.bucket
  key    = "explorer.js"
  source = "../explorer.js"
  etag = "${filemd5("../explorer.js")}"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "explorer-css" {
  bucket = aws_s3_bucket.website-bucket.bucket
  key    = "explorer.css"
  source = "../explorer.css"
  etag = "${filemd5("../explorer.css")}"
  content_type = "text/html"
}


resource "aws_iam_user" "example" {
  name          = "example"
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "example" {
  user    = "${aws_iam_user.example.name}"
  pgp_key = "keybase:avanzarit"
}

output "password" {
  value = "${aws_iam_user_login_profile.example.password}"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = data.template_file.user-access-policy.rendered
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = "${aws_iam_user.example.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}