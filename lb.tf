resource "aws_lb" "lb" {
  name               = "esgi-alb-01"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [for k, v in local.subnets : aws_subnet.all[k].id if v.public]

  tags = {
    Name = "esgi-alb-01"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "esgi-tg-01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
  }

  tags = {
    Name = "esgi-tg-01"
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}