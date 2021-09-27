#IAM User
resource "aws_iam_user" "bilbo" {
  name = "cg-bilbo-${var.cgid}"
  tags = {
    Name     = "cg-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_access_key" "bilbo" {
  user = aws_iam_user.bilbo.name
}

resource "aws_iam_user_policy" "standard_user" {
  name = "${aws_iam_user.bilbo.name}-standard-user-assumer"
  user = aws_iam_user.bilbo.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::940877411605:role/cg-lambda-invoker*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
              "iam:Get*",
              "iam:List*",
              "iam:SimulateCustomPolicy",
              "iam:SimulatePrincipalPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "cg-lambda-invoker" {
  name = "cg-lambda-invoker-${var.cgid}"
  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "lambda:ListFunctionEventInvokeConfigs",
            "lambda:InvokeFunction",
            "lambda:ListTags",
            "lambda:GetFunction",
            "lambda:GetPolicy"
            ]
          Effect   = "Allow"
          Resource = "${aws_lambda_function.policy_applier_lambda.arn}"
        },
        {
          Action   = [
            "lambda:ListFunctions",
            "iam:Get*",
            "iam:List*",
            "iam:SimulateCustomPolicy",
            "iam:SimulatePrincipalPolicy"
            ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "AWS": [
            "${aws_iam_user.bilbo.arn}"
          ]
        }
      },
    ]
  })
  tags = {
    Name     = "cg-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}


