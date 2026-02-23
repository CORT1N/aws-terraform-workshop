# resource "aws_instance" "ec2" {
#   ami                    = data.aws_ami.amazon-linux.id
#   instance_type          = "t3.micro"
#   subnet_id              = aws_subnet.all["pub-01"].id
#   vpc_security_group_ids = [aws_security_group.sg.id]
#   key_name               = aws_key_pair.key.key_name
#   associate_public_ip_address = true

#   provisioner "file" {
#     source = "nginx.sh"
#     destination = "/tmp/nginx.sh"
#     connection {
#         user = "ec2-user"
#         private_key = file("/home/vscode/.ssh/id_rsa")
#         host = self.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#           "chmod +x /tmp/nginx.sh",
#           "sudo /tmp/nginx.sh"
#     ]
#     connection {
#         user = "ec2-user"
#         private_key = file("/home/vscode/.ssh/id_rsa")
#         host = self.public_ip
#     }
#   }  

#   tags = {
#     Name = "esgi-ec2-01"
#   }
# }

resource "aws_launch_template" "esgi" {
  image_id      = data.aws_ami.amazon-linux.id
  instance_type = "t3.micro"

  key_name               = aws_key_pair.key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg.id]
  }

  user_data = base64encode(file("nginx.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "esgi-ec2-01"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "esgi-asg-01"
  vpc_zone_identifier = [for k, v in local.subnets : aws_subnet.all[k].id if v.public]
  target_group_arns   = [aws_lb_target_group.tg.arn]

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.esgi.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "esgi-ec2-asg"
    propagate_at_launch = true
  }
}