

# Create security group for ecs
module "ecs-security-group" {
  source = "./modules/security-group"

  is_secgroup_create = true

  name_suffix             = local.name_suffix
  # secgroup_name           = format("%s-%s", local.app_id, "ecssecgroup")
  secgroup_name           = "paraview-iam-standalone-trial-secgroup"
  is_delete_default_rules = true

  secgroup_rules_configuration = [
    { description = null, direction = "ingress", ethertype = "IPv4", protocol = "tcp", ports = "22,443,80,10000", remote_ip_prefix = "0.0.0.0/0", remote_group_id = null },
    { description = null, direction = "ingress", ethertype = "IPv4", protocol = null, ports = null, remote_ip_prefix = local.cidr, remote_group_id = null },
    { description = null, direction = "egress", ethertype = "IPv4", protocol = null, ports = null, remote_ip_prefix = "0.0.0.0/0", remote_group_id = null }
  ]
}

// Create  ECS
module "ecs" {
  source = "./modules/ecs"

  is_instance_create = true
  # The total number of The ECS instance
  instance_count = 1

  instance_image_id  = local.instance_image_id_maps[data.huaweicloud_availability_zones.az.region]
  instance_flavor_id = local.ecs_flavor

  # You need to change the performance type of the cpu and memory of the ECS based on the your requirements.
  instance_flavor_performance = local.instance_performance_type
  instance_flavor_cpu         = local.instance_flavor_cpu
  instance_flavor_memory      = local.instance_flavor_memory

  agent_list    = local.ecs_agent_list
  name_suffix   = local.name_suffix
  # instance_name = format("%s-%s", local.app_id, "ecs")
  instance_name = "paraview-iam-standalone-trial"

  security_group_ids = module.ecs-security-group.secgroup_id

  # Default size and type of the system disk, You need to modify it according to your actual situation. And the size must be greater than the minimum memory size required by the image.
  system_disk_type = local.ecs_volume_type
  system_disk_size = local.ecs_volume_size

  # 绑定eip
  eip_id = module.eip.id != null && length(module.eip.id) > 0 ? module.eip.id[0] : null

  # If you need to create multiple network adapters, you need to configure multiple data records.
  networks_configuration = [
    { subnet_id = var.subnet_id, fixed_ip_v4 = null, ipv6_enable = false, source_dest_check = true, access_network = false },
  ]

  charging_mode = local.charging_mode
  period_unit   = local.period_unit
  period        = local.period

  instance_tags = local.tags
  admin_pass    = var.admin_password
  key_pair      = var.key_pair

  user_data = <<-EOF
  #!/bin/bash
  str=${var.admin_password}
  length=$${#str}
  if [ $length -ge 8 ]; then
      echo 'root:${var.admin_password}' | chpasswd
  fi
  public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  /home/devops/deploy-script-6.0.2.3/config.sh $public_ip
  userdel -r devops
  rm -rf /home/devops
  sleep 5m
  echo "***end of ansible playbook deployment***"
  EOF
}


// Create an EIP, if you do not need to create an EIP, delete the code and modules/eip directory
module "eip" {
  source = "./modules/eip"

  is_eip_create = true

  name_suffix = local.name_suffix
  # eip_name    = format("%s-%s", local.app_id, "eip")
  eip_name    = "paraview-iam-standalone-trial-eip"

  publicip_type         = local.publicip_type
  # bandwidth_name        = format("%s-%s", local.app_id, "bandwidth")
  bandwidth_name        = "paraview-iam-standalone-trial-bandwidth"
  bandwidth_share_type  = local.bandwidth_share_type
  bandwidth_charge_mode = local.bandwidth_charge_mode
  bandwidth_size        = local.bandwidth_size

  charging_mode = local.charging_mode
  period_unit   = local.period_unit
  period        = local.period

  eip_tags = local.tags
}

