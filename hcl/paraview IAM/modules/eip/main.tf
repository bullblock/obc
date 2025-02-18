//  Parameter details refer to:https://support.huaweicloud.com/api-eip/BatchCreatePublicips.html
resource "huaweicloud_vpc_eip" "eip" {
  count = var.is_eip_create ? 1 : 0

  publicip {
    type       = var.publicip_type
    ip_address = var.publicip_address
    ip_version = var.publicip_version
  }

  bandwidth {
    name        = var.bandwidth_share_type
    size        = var.bandwidth_size
    share_type  = var.bandwidth_share_type
    charge_mode = var.bandwidth_charge_mode
    id          = var.bandwidth_id
  }

  charging_mode = var.charging_mode
  period_unit   = var.period_unit
  period        = var.period
  auto_renew = var.is_auto_renew

  name          = var.name_suffix != null ? format("%s-%s", var.eip_name, var.name_suffix) : var.eip_name

  tags = var.eip_tags
}

resource "huaweicloud_vpc_eip_associate" "associated" {
  count = var.is_port_associate ? 1 : 0
  public_ip = huaweicloud_vpc_eip.eip[0].address
  port_id   = var.port_id
}
