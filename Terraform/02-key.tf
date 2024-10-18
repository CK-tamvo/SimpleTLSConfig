## Key pair
resource "aws_key_pair" "EC2key" {
  key_name   = var.ec2_key_name
  public_key = file("${path.module}/my_key.pub")
}