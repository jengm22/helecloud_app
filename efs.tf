## EFS
resource "aws_efs_file_system" "iac-efs" {
  creation_token = "my-product"

  tags = {
    Name = "MyProduct"
  }
}

# Creating the EFS access point for AWS EFS File system
resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.iac-efs.id
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id = aws_efs_file_system.iac-efs.id
  subnet_id      = aws_subnet.PrivateSubnet1.id
}

# # Creating Mount Point for EFS
# resource "null_resource" "connection" {
#   depends_on = [aws_efs_mount_target.efs_mount, ]
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = tls_private_key.p_key.private_key_pem
#     # host        = aws_instance.task2-instance.public_ip
#   }

#   // Mounting the EFS on the folder /var/www/html and pulling the code from github
#   provisioner "remote-exec" {
#     inline = [
#       "sudo echo ${aws_efs_file_system.iac-efs.dns_name}:/var/www/html efs defaults,_netdev 0 0 >> sudo /etc/fstab",
#       "sudo mount  ${aws_efs_file_system.iac-efs.dns_name}:/  /var/www/html",
#       # "sudo git clone https://github.com/Priyanshi541/HTask2.git /var/www/html/",
#     ]
#   }
# }
