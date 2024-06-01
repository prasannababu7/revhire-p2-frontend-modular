# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-revhire-frontend-modular"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CodeBuild role
resource "aws_iam_role_policy" "codebuild_role_policy" {
  name   = "codebuild-role-policy"
  role   = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sts:GetServiceBearerToken"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "codecommit:GitPull"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# CodeBuild project
resource "aws_codebuild_project" "codecommit_project" {
  name          = "codecommit-build-project"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30  # 30 minutes build timeout

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/${var.frontend-repo-name}"
    git_clone_depth = 1

    buildspec = <<EOF
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - echo Installing the Angular CLI...
      - npm install -g @angular/cli
  pre_build:
    commands:
      - echo Installing dependencies...
      - npm install
  build:
    commands:
      - echo Building the Angular application...
      - ng build --configuration production
  post_build:
    commands:
      - echo Build completed successfully.
      - echo Copying files to S3...
      - aws s3 cp dist/revhire/ s3://${var.frontend-bucket-name}/ --recursive

artifacts:
  files:
    - '**/*'
  base-directory: dist
  discard-paths: no
EOF
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true  # Needed for Docker commands
    image_pull_credentials_type = "CODEBUILD"
  }

  cache {
    type = "NO_CACHE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/codecommit-build-project"
      stream_name = "build-log"
    }
  }
}