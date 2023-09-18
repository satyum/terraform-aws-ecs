data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["TTN-Infra"]
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "tag:Scope"
    values = ["public"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Scope"
    values = ["private"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
data "aws_subnets" "larger_private" {
  filter {
    name   = "tag:Scope"
    values = ["larger-private"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
# data "aws_instance" "elasticsearch_server" {
#   filter {
#     name   = "tag:Name"
#     values = ["nw-social-elasticsearch"]
#   }
#   filter {
#     name   = "instance-state-name"
#     values = ["running"]
#   } 
# }
#data "aws_resourcegroupstaggingapi_resources" "load_balancer" {
#  depends_on = [
#    module.kong
#  ]
#  resource_type_filters = ["elasticloadbalancing:loadbalancer"]
#
#  tag_filter {
#    key    = "elbv2.k8s.aws/cluster"
#    values = ["${local.workspace.eks_cluster.name}"]
#  }
#
#  tag_filter {
#    key    = "ingress.k8s.aws/stack"
#    values = ["default/konga-ingress-ingress"]
#  }
#}
#data "aws_lb_listener" "kong_http_listener" {
#  depends_on = [
#    module.kong
#  ]
#  load_balancer_arn = data.aws_lb.kong.arn
#  port = 80
#}
# data "aws_lb_listener" "kong_https_listener" {
#   depends_on = [
#     module.kong
#   ]
#   load_balancer_arn = data.aws_lb.kong.arn
#   port = 443
# }
#data "aws_lb_listener" "konga_http_listener" {
#  depends_on = [
#    module.kong
#  ]
#  load_balancer_arn = data.aws_lb.konga.arn
#  port = 80
#}
#data "aws_lb_listener" "konga_https_listener" {
#  depends_on = [
#    module.kong
#  ]
#  load_balancer_arn = data.aws_lb.konga.arn
#  port = 443
#}
# data "aws_resourcegroupstaggingapi_resources" "kong_load_balancer" {
#   depends_on = [
#     module.kong
#   ]
#   resource_type_filters = ["elasticloadbalancing:loadbalancer"]

#   tag_filter {
#     key    = "elbv2.k8s.aws/cluster"
#     values = ["${local.workspace.eks_cluster.name}"]
#   }
#   tag_filter {
#     key    = "ingress.k8s.aws/stack"
#     values = ["kong-ingress"]
#   }
# }
# data "aws_lb" "kong" {
#   depends_on = [
#     module.kong
#   ]
#   arn = data.aws_resourcegroupstaggingapi_resources.kong_load_balancer.resource_tag_mapping_list[0].resource_arn
# }
#data "aws_lb" "konga" {
#  depends_on = [
#    module.kong
#  ]
#  arn = data.aws_resourcegroupstaggingapi_resources.load_balancer.resource_tag_mapping_list[0].resource_arn
#}

# data "aws_resourcegroupstaggingapi_resources" "utility_load_balancer" {
#   depends_on = [
#     module.kong
#   ]
#   resource_type_filters = ["elasticloadbalancing:loadbalancer"]

#   tag_filter {
#     key    = "Environment"
#     values = ["utility"]
#   }
#   tag_filter {
#     key    = "Name"
#     values = ["social-utility-alb"]
#   }
# }
# data "aws_lb" "utility" {
#   depends_on = [
#     module.kong
#   ]
#   arn = data.aws_resourcegroupstaggingapi_resources.utility_load_balancer.resource_tag_mapping_list[0].resource_arn
# }
# data "aws_lb_listener" "utility_https_listener" {
#   depends_on = [
#     module.kong
#   ]
#   load_balancer_arn = data.aws_lb.utility.arn
#   port = 443
# }
