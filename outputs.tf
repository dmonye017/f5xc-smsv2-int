output "student_ce_details" {
  description = "CE deployment details per student"
  value = {
    for student, config in var.students : student => {
      public_ip       = aws_eip.ce_slo[student].public_ip
      slo_private_ip  = aws_network_interface.ce_slo[student].private_ip
      sli_private_ip  = aws_network_interface.ce_sli[student].private_ip
      instance_id     = aws_instance.ce_node[student].id
      vpc_id          = aws_vpc.student[student].id
      site_name       = volterra_securemesh_site_v2.student[student].name
      token_name      = volterra_token.student[student].name
    }
  }
  sensitive = false
}