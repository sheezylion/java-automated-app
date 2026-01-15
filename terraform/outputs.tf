output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "tomcat_public_ip" {
  value = aws_instance.tomcat.public_ip
}
