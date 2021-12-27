locals {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "Role"
    project     = "awsdevops-ps"
  }
}
resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "code-deploy-servicerole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "codedeploy.amazonaws.com",
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "CodeDeployServiceRole-attach" {
  role = aws_iam_role.CodeDeployServiceRole.name
  // policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
  policy_arn = local.policy_arn

}