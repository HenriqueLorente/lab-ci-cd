# Descobre o VPC a partir da primeira subnet informada
data "aws_subnet" "first" {
  id = var.subnets_id[0]
}

# Crie um Network Load Balancer
resource "aws_lb" "this" {
  name = format("%s-nlb", var.cluster_name)

  subnets            = var.subnets_id
  # NLB não usa Security Group
  # security_groups    = [aws_security_group.allow_inbound.id]
  load_balancer_type = "network"

  tags = {
    Name = format("%s-nlb", var.cluster_name)
  }
}

# Crie um listener para o NLB
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Crie um target group
resource "aws_lb_target_group" "this" {
  name        = format("%s-tg", var.cluster_name)
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_subnet.first.vpc_id  # <-- derivado das subnets

  # (opcional, mas recomendado)
  # health_check {
  #   protocol = "TCP"
  #   port     = "traffic-port"
  # }

  tags = {
    Name = format("%s-tg", var.cluster_name)
  }
}
