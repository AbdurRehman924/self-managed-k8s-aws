# Network Load Balancer
resource "aws_lb" "k8s_api" {
  name               = "${var.cluster_name}-api-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.cluster_name}-api-nlb"
  }
}

# Target Group for Kubernetes API (port 6443)
resource "aws_lb_target_group" "k8s_api" {
  name     = "${var.cluster_name}-api-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 6443
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.cluster_name}-api-tg"
  }
}

# Attach control plane instances to target group
resource "aws_lb_target_group_attachment" "k8s_api" {
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.k8s_api.arn
  target_id        = var.target_instance_ids[count.index]
  port             = 6443
}

# Listener for port 6443
resource "aws_lb_listener" "k8s_api" {
  load_balancer_arn = aws_lb.k8s_api.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api.arn
  }
}
