###IAM PROFILE FOR APP LAYER 
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.environment}-app-instance-profile"
  role = aws_iam_role.app_role.name
}

###IAM POLICY FOR APP LAYER FOR S3 BUCKET ACCESS
resource "aws_iam_policy" "app_policy" {
  name        = "${var.environment}-app-policy-s3"
  description = "IAM policy for ${var.environment} for s3 bucket access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:List*",
          "s3:Get*",
          "s3:Put*"
        ],
        Resource = [
           "${var.log_bucket_arn}",
	   "${var.log_bucket_arn}/*"
]
      },
    ]
  })
}

# IAM ROLE FOR APP
resource "aws_iam_role" "app_role" {
  name = "${var.environment}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "app_policy_attachment_s3" {
  policy_arn = aws_iam_policy.app_policy.arn
  role       = aws_iam_role.app_role.name
}

###IAM POLICY FOR APP LAYER FOR SECRET MANAGER ACCESS
resource "aws_iam_policy" "app_policy_secret_manager" {
  name        = "${var.environment}-app-secret-manager"
  description = "IAM policy for ${var.environment} for secret manager access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretmanager:GetSecretValue",
          "secretmanager:GetResourcePolicy",
          "secretmanager:DescribeSecret",
          "secretmanager:GetRamdomPassword",
          "secretmanager:ListSecrets",
          "secretmanager:ListSecretVersionIds"
        ],
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "app_policy_attachment_secret_manager" {
  policy_arn = aws_iam_policy.app_policy_secret_manager.arn
  role       = aws_iam_role.app_role.name
}

