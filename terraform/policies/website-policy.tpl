{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ExplorerGetMinimal",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:Get*",
      "Resource": [
        "arn:aws:s3:::${bucket}/index.html",
        "arn:aws:s3:::${bucket}/explorer.css",
        "arn:aws:s3:::${bucket}/explorer.js"
      ]
    }
  ]
}