resource "aws_instance" "attacker" {
  count         = 10
  ami           = "ami-002f6e91abff6eb96" # Ubuntu AMI
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y docker.io
              docker run --rm hardcorebihari/dos-machine
              shutdown -h now
              EOF

  tags = {
    Name = "attacker-${count.index}"
  }
}