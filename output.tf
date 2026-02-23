# output "instance_public_ip" {
#   value = aws_instance.ec2.public_ip
# }

output "lb_dns_name" {
  value       = aws_lb.lb.dns_name
}