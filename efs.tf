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
