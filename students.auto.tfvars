aws_region    = "us-east-1"
aws_az        = "us-east-1a"
ce_ami_id     = "ami-000bc40f0b0d64b35"
instance_type = "m5.2xlarge"
volume_size   = 80
ssh_key_name  = "f5xc-smsv2-key"
f5xc_api_p12_file = "./training1.console.ves.volterra.io.api-creds.p12"
f5xc_api_url      = "https://training1.console.ves.volterra.io/api"

students = {
  "student101" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.101.0/24"
    sli_subnet_cidr = "172.31.121.0/24"
  }
  "student102" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.102.0/24"
    sli_subnet_cidr = "172.31.122.0/24"
  }
  "student103" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.103.0/24"
    sli_subnet_cidr = "172.31.123.0/24"
  }
  "student104" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.104.0/24"
    sli_subnet_cidr = "172.31.124.0/24"
  }
  "student105" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.105.0/24"
    sli_subnet_cidr = "172.31.125.0/24"
  }
  "student106" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.106.0/24"
    sli_subnet_cidr = "172.31.126.0/24"
  }
  "student107" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.107.0/24"
    sli_subnet_cidr = "172.31.127.0/24"
  }
  "student108" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.108.0/24"
    sli_subnet_cidr = "172.31.128.0/24"
  }
  "student109" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.109.0/24"
    sli_subnet_cidr = "172.31.129.0/24"
  }
  "student110" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.110.0/24"
    sli_subnet_cidr = "172.31.130.0/24"
  }
  "student111" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.111.0/24"
    sli_subnet_cidr = "172.31.131.0/24"
  }
  "student112" = {
    vpc_cidr        = "172.31.0.0/16"
    slo_subnet_cidr = "172.31.112.0/24"
    sli_subnet_cidr = "172.31.132.0/24"
  }
}