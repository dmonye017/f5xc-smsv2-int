# ============================================================
# SITE TOKEN — One per student, auto-generated
# ============================================================

resource "volterra_token" "student" {
  depends_on = [volterra_securemesh_site_v2.student]
  for_each = var.students

  name      = "${each.key}-site-token"
  namespace = "system"
  type      = 1
  site_name = volterra_securemesh_site_v2.student[each.key].name
}

# ============================================================
# SMSv2 SITE OBJECT — One per student, auto-created
# ============================================================

resource "volterra_securemesh_site_v2" "student" {
  for_each = var.students

  name        = "${lower(each.key)}-smsv2-ce"
  namespace   = "system"
  description = "SMSv2 CE site for ${each.key}"

  # Label for virtual site grouping
  labels = {
    "ves.io/provider" = "ves-io-AWS",
    "${each.key}-key" = "${each.key}-value"
  }

  # Block external services
  block_all_services = false

  # Performance mode
  logs_streaming_disabled = true
  enable_ha = false

  re_select {
    geo_proximity = true
  }

  aws {
    not_managed {
    }
  }

}
