# ============================================================
# VPCs — One per student
# ============================================================

resource "aws_vpc" "student" {
  for_each = var.students

  cidr_block           = each.value.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${each.key}-vpc"
    Student = each.key
  }
}

# ============================================================
# INTERNET GATEWAYS — One per student VPC
# ============================================================

resource "aws_internet_gateway" "student" {
  for_each = var.students

  vpc_id = aws_vpc.student[each.key].id

  tags = {
    Name    = "${each.key}-igw"
    Student = each.key
  }
}

# ============================================================
# SUBNETS — SLO (public) and SLI (private) per student
# ============================================================

resource "aws_subnet" "slo" {
  for_each = var.students

  vpc_id                  = aws_vpc.student[each.key].id
  cidr_block              = each.value.slo_subnet_cidr
  availability_zone       = var.aws_az
  map_public_ip_on_launch = true

  tags = {
    Name    = "${each.key}-slo-subnet"
    Student = each.key
  }
}

resource "aws_subnet" "sli" {
  for_each = var.students

  vpc_id            = aws_vpc.student[each.key].id
  cidr_block        = each.value.sli_subnet_cidr
  availability_zone = var.aws_az

  tags = {
    Name    = "${each.key}-sli-subnet"
    Student = each.key
  }
}

# ============================================================
# ROUTE TABLES
# ============================================================

resource "aws_route_table" "slo" {
  for_each = var.students

  vpc_id = aws_vpc.student[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.student[each.key].id
  }

  tags = {
    Name    = "${each.key}-slo-rt"
    Student = each.key
  }
}

resource "aws_route_table_association" "slo" {
  for_each = var.students

  subnet_id      = aws_subnet.slo[each.key].id
  route_table_id = aws_route_table.slo[each.key].id
}

resource "aws_route_table" "sli" {
  for_each = var.students

  vpc_id = aws_vpc.student[each.key].id

  tags = {
    Name    = "${each.key}-sli-rt"
    Student = each.key
  }
}

resource "aws_route_table_association" "sli" {
  for_each = var.students

  subnet_id      = aws_subnet.sli[each.key].id
  route_table_id = aws_route_table.sli[each.key].id
}

# ============================================================
# SECURITY GROUPS
# ============================================================

resource "aws_security_group" "ce_slo" {
  for_each = var.students

  name        = "${each.key}-ce-slo-sg"
  description = "SLO security group for ${each.key}"
  vpc_id      = aws_vpc.student[each.key].id

  ingress {
    description = "IPSEC IKE"
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "IPSEC NAT-T"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # LOCK THIS DOWN
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${each.key}-ce-slo-sg"
    Student = each.key
  }
}

resource "aws_security_group" "ce_sli" {
  for_each = var.students

  name        = "${each.key}-ce-sli-sg"
  description = "SLI security group for ${each.key}"
  vpc_id      = aws_vpc.student[each.key].id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [each.value.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${each.key}-ce-sli-sg"
    Student = each.key
  }
}

# ============================================================
# NETWORK INTERFACES
# ============================================================

resource "aws_network_interface" "ce_slo" {
  for_each = var.students

  subnet_id         = aws_subnet.slo[each.key].id
  security_groups   = [aws_security_group.ce_slo[each.key].id]
  source_dest_check = false

  tags = {
    Name    = "${each.key}-ce-slo-eni"
    Student = each.key
  }
}

resource "aws_network_interface" "ce_sli" {
  for_each = var.students

  subnet_id         = aws_subnet.sli[each.key].id
  security_groups   = [aws_security_group.ce_sli[each.key].id]
  source_dest_check = false

  tags = {
    Name    = "${each.key}-ce-sli-eni"
    Student = each.key
  }
}

# ============================================================
# ELASTIC IPs
# ============================================================

resource "aws_eip" "ce_slo" {
  for_each = var.students

  domain = "vpc"

  tags = {
    Name    = "${each.key}-ce-slo-eip"
    Student = each.key
  }
}

resource "aws_eip_association" "ce_slo" {
  depends_on = [aws_eip.ce_slo, aws_network_interface.ce_slo]
  for_each = var.students

  allocation_id        = aws_eip.ce_slo[each.key].id
  network_interface_id = aws_network_interface.ce_slo[each.key].id
}

# ============================================================
# CE INSTANCES — Token now comes from volterra_token resource
# ============================================================

resource "aws_instance" "ce_node" {
  for_each = var.students

  ami           = var.ce_ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  user_data = <<-EOF
    #cloud-config
    write_files:
    - path: /etc/vpm/user_data
      content: |
        token: ${volterra_token.student[each.key].id}
        cluster_name: ${each.key}
        hostname: ${each.key}-ce-node
      owner: root
      permissions: '0644'
  EOF

  network_interface {
    network_interface_id = aws_network_interface.ce_slo[each.key].id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ce_sli[each.key].id
    device_index         = 1
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Explicit dependency — don't launch until site object and token exist
  # Explicit dependency - wait for the CE site and token to become usable before bootstrapping the CE node
  depends_on = [
    volterra_securemesh_site_v2.student,
    volterra_token.student,
    time_sleep.token_ready
  ]

  tags = {
    Name    = "${each.key}-ce-node"
    Student = each.key
  }
}
