output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_url" {
  description = "URL to access the app"
  value       = "http://${aws_instance.app_server.public_ip}:5001"
}

output "ssh_command" {
  description = "Command to SSH into the server"
  value       = "ssh -i ~/devops-lab/aws/terraform-key.pem ubuntu@${aws_instance.app_server.public_ip}"
}
