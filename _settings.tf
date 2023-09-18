provider "aws" {
  region  = "us-east-1"
#    assume_role {
#        role_arn = "arn:aws:iam::${local.workspace["aws"]["account_id"]}:role/${local.workspace["aws"]["role"]}"
#     }
}

terraform {
  backend "s3" {
    bucket         = "ecs-terraform-tothenew-bucket"   
    key            = "ecs-terraform"
    region         = "us-east-1"
    encrypt        = true
    
  }
}



terraform {
  required_version = ">= 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">=4.23.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.10.0"
    # }
    # mysql = {
    #   source = "petoju/mysql"
    #   version = "3.0.27"
    # }
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = ">= 1.7.0"
    # }
    # rabbitmq = {
    #   source = "cyrilgdn/rabbitmq"
    #   version = "1.7.0"
    # }
    # postgresql = {
    #   source  = "cyrilgdn/postgresql"
    #   version = "1.15.0"
    # }
  }
}

locals {
  env       = yamldecode(file("${path.module}/config.yaml"))
  common    = local.env["common"]
  env_space = yamldecode(file("${path.module}/config-${terraform.workspace}.yaml"))
  workspace = local.env_space["workspaces"][terraform.workspace]

  project_name_prefix = "${local.workspace.environment_name}-${local.workspace.project_name}"

  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}
