# provider "aws" {
#   region = local.region
# }

data "aws_availability_zones" "available" {}


################################################################################
# Cluster
################################################################################

# module "ecs" {
#   source = "../../"

#   cluster_name = local.name

#   # Capacity provider
#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#         base   = 20
#       }
#     }
#     FARGATE_SPOT = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#   }

#   services = {
#     ecsdemo-frontend = {
#       cpu    = 1024
#       memory = 4096

#       # Container definition(s)
#       container_definitions = {

#         fluent-bit = {
#           cpu       = 512
#           memory    = 1024
#           essential = true
#           image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
#           firelens_configuration = {
#             type = "fluentbit"
#           }
#           memory_reservation = 50
#         }

#         (local.container_name) = {
#           cpu       = 512
#           memory    = 1024
#           essential = true
#           image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
#           port_mappings = [
#             {
#               name          = local.container_name
#               containerPort = local.container_port
#               hostPort      = local.container_port
#               protocol      = "tcp"
#             }
#           ]

#           # Example image used requires access to write to root filesystem
#           readonly_root_filesystem = false

#           dependencies = [{
#             containerName = "fluent-bit"
#             condition     = "START"
#           }]

#           enable_cloudwatch_logging = false
#           log_configuration = {
#             logDriver = "awsfirelens"
#             options = {
#               Name                    = "firehose"
#               region                  = local.region
#               delivery_stream         = "my-stream"
#               log-driver-buffer-limit = "2097152"
#             }
#           }
#           memory_reservation = 100
#         }
#       }

#       service_connect_configuration = {
#         namespace = aws_service_discovery_http_namespace.this.arn
#         service = {
#           client_alias = {
#             port     = local.container_port
#             dns_name = local.container_name
#           }
#           port_name      = local.container_name
#           discovery_name = local.container_name
#         }
#       }

#       load_balancer = {
#         service = {
#           target_group_arn = element(module.alb.target_group_arns, 0)
#           container_name   = local.container_name
#           container_port   = local.container_port
#         }
#       }

#       subnet_ids = module.vpc.private_subnets
#       security_group_rules = {
#         alb_ingress_3000 = {
#           type                     = "ingress"
#           from_port                = local.container_port
#           to_port                  = local.container_port
#           protocol                 = "tcp"
#           description              = "Service port"
#           source_security_group_id = module.alb_sg.security_group_id
#         }
#         egress_all = {
#           type        = "egress"
#           from_port   = 0
#           to_port     = 0
#           protocol    = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#         }
#       }
#     }
#   }

#   tags = local.tags
# }

module "ecs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs"

  cluster_name = local.workspace.ecs_cluster.name

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      container_definitions = {
        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        "${local.workspace.ecs_cluster.container_name}" = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          port_mappings = [
            {
              name          = local.workspace.ecs_cluster.container_name
              containerPort = local.workspace.ecs_cluster.container_port
              hostPort      = local.workspace.ecs_cluster.container_port
              protocol      = "tcp"
            }
          ]

          readonly_root_filesystem = false

          dependencies = [{
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = local.workspace.ecs_cluster.region
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      # ... (rest of your ECS configuration)
    }
  }

  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}



# module "ecs_disabled" {
#   source = "../../"

#   create = false
# }

# module "ecs_cluster_disabled" {
#   source = "../../modules/cluster"

#   create = false
# }

# module "service_disabled" {
#   source = "../../modules/service"

#   create = false
# }

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "fluentbit" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.workspace.project_name
  description = "CloudMap namespace for ${local.workspace.project_name}"
  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.workspace.project_name}-service"
  description = "Service security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  # egress_cidr_blocks = values(data.aws_subnets.public).*.cidr_block
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = local.workspace.project_name

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.selected.id
  subnets         = data.aws_subnets.public.ids
  security_groups = [module.alb_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = "${local.workspace.project_name}-${local.workspace.ecs_cluster.container_name}"
      backend_protocol = "HTTP"
      backend_port     = local.workspace.ecs_cluster.container_port
      target_type      = "ip"
    }
  ]

  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}