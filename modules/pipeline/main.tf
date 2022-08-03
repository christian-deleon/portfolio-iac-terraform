resource "aws_iam_role" "codebuild" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Resource": [
          "*"
        ],
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "${var.website_bucket_arn}",
          "${var.website_bucket_arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        "Resource": [
          "${aws_s3_bucket.codepipeline.arn}",
          "${aws_s3_bucket.codepipeline.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "cloudfront:CreateInvalidation"
        ],
        "Resource": [
          "${var.distribution_arn}"
        ]
      }
    ]
  })
}

data "local_file" "buildspec" {
  filename = "${path.module}/bulidspec.yaml"
}

resource "aws_codebuild_project" "main" {
  name         = "Portfolio-Build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.local_file.buildspec.content
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "DOMAIN_NAME"
      value = var.domain_name
    }

    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = var.distribution_id
    }
  }

  # cache {
  #   type = "LOCAL"
  #   modes = "LOCAL_CUSTOM_CACHE"
  # }
}

resource "aws_codestarconnections_connection" "main" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_iam_role" "codepipeline" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Action": [
          "codestar-connections:UseConnection"
        ],
        "Resource": [
          "${aws_codestarconnections_connection.main.arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        "Resource": [
          "${aws_codebuild_project.main.arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        "Resource": [
          "${aws_s3_bucket.codepipeline.arn}",
          "${aws_s3_bucket.codepipeline.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "codepipeline" {
  bucket        = "codepipeline-bucket-${uuid()}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}

resource "aws_codepipeline" "main" {
  name     = "Portfolio-Pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.main.arn
        FullRepositoryId = "${var.github_user}/${var.github_repository_name}"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = "Portfolio-Build"
      }
    }
  }
}
