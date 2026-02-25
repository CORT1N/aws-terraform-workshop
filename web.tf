resource "aws_key_pair" "all" {
  for_each = var.ssh_keys
  key_name   = "${var.infra_name}-${each.key}"
  public_key = each.value
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.main.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.all["lucas"].key_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.infra_name}-bastion"
  }
}

resource "aws_network_interface_attachment" "bastion" {
  instance_id          = aws_instance.bastion.id
  network_interface_id = aws_network_interface.bastion_internal.id
  device_index         = 1
}

resource "aws_launch_template" "main" {
  image_id      = data.aws_ami.main.id
  instance_type = "t3.micro"
  key_name               = aws_key_pair.all["lucas"].key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.main.id]
  }

  user_data = base64encode(file("scripts/nginx.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.infra_name
    }
  }
}

resource "aws_lb" "main" {
  name               = var.infra_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = aws_subnet.public[*].id
  tags = {
    Name = var.infra_name
  }
}

resource "aws_lb_target_group" "http" {
  name     = var.infra_name
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
    Name = var.infra_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_autoscaling_group" "main" {
  name                = var.infra_name
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.http.arn]

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.infra_name}-asg"
    propagate_at_launch = true
  }
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = aws_lb.lb.dns_name
#   validation_method = "DNS"

#   tags = {
#     Name = "esgi-cert-01"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_acm_certificate.cert.domain_validation_options : record.resource_record_name]
# }

# resource "aws_lb_listener" "https-lb-listener" {
#   load_balancer_arn = aws_lb.lb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg.arn
#   }

#   depends_on = [aws_acm_certificate_validation.cert_validation]
# }