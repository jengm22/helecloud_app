resource "aws_lb" "iac-lb" {
  provider           = aws.master
  name               = "iac-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id, aws_subnet.PublicSubnet3.id]
  tags = {
    Name = "iac-lb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.iac-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.iac-lb-tg.arn
    type             = "forward"
  }
}

#Create key-pair for logging into EC2 
resource "aws_key_pair" "master-key" {
  provider   = aws.master
  key_name   = "terraform-iac-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_lb_target_group" "iac-lb-tg" {
  provider = aws.master
  name     = "iac-lb-tg"
  port     = 80
  vpc_id   = aws_vpc.sand.id
  protocol = "HTTP"
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
  tags = {
    Name = "iac-target-group"
  }
}

#Get Linux AMI ID using SSM Parameter endpoint in eu-west-2
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Launch Configuration
resource "aws_launch_configuration" "iac-lc" {
  name            = "iac-lc"
  image_id        = data.aws_ssm_parameter.linuxAmi.value
  instance_type   = var.instance-type
  security_groups = [aws_security_group.iac-instance-sg.id]
  key_name        = "terraform-iac-key-pair"

  user_data = filebase64("${path.module}/install_nginx.sh")
  lifecycle {
    create_before_destroy = true
  }
}

## AutoScaling Group
resource "aws_autoscaling_group" "iac-asg" {
  name                 = "iac-asg"
  launch_configuration = aws_launch_configuration.iac-lc.id
  vpc_zone_identifier  = [aws_subnet.PrivateSubnet1.id, aws_subnet.PrivateSubnet2.id, aws_subnet.PrivateSubnet3.id]
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  target_group_arns    = [aws_lb_target_group.iac-lb-tg.arn]
  health_check_type    = "EC2"
  tag {
    key                 = "Name"
    value               = "iac-asg"
    propagate_at_launch = true
  }
}

#Bastion Server
resource "aws_instance" "bastion" {
  provider                    = aws.master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = "terraform-iac-key-pair"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion-sg.id]
  subnet_id                   = aws_subnet.PublicSubnet2.id
  tags = {
    Name = "Bastion_Server"
  }
}

#cloudwatch
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}
