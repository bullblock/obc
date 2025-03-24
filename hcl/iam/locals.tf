

locals {
  // you need to specify a unique name under a tenant according to the business, which will be used as part of the resource name
  app_id = format("%s-%s", "app", formatdate("hhmm", timestamp()))

  name_suffix = "hcl"

  // Tags of HUAWEI CLOUD resources. You can add tags to resources to classify resources.
  // for more details, please refer to https://support.huaweicloud.com/usermanual-tms/zh-cn_topic_0056266263.html
  tags = { Purpose = "MkpApplication" }

  # Configuration of the ECS memory size and number of cores
  instance_flavor_cpu    = 4
  instance_flavor_memory = 16
  #  规格·通用计算增强型
  instance_performance_type = "computingv3"
  # 系统盘: 通用SSD
  ecs_volume_type = "GPSSD"
  # 系统盘大小：G
  ecs_volume_size = 128
  # 规格：通用计算增强型
  ecs_flavor = "c6s.xlarge.4"

  # 开启企业主机安全
  ecs_agent_list = "hss"

  // Billing model for cloud resources, You need to modify it according to your actual situation.
  // In the development and testing phase, pay-per-use billing is recommended.
  // You can also set these three parameters as variables, allowing users to select at deployment time.
  charging_mode = var.charging_mode
  period_unit   = var.period_unit
  period        = var.period

  // The billing model for bandwidth, You need to modify it according to your actual situation.
  publicip_type         = "5_bgp"   # 全动态
  bandwidth_share_type  = "PER"     # 独享带宽
  bandwidth_charge_mode = "bandwidth" # 按带宽计费:bandwidth,  按流量计费：   traffic
  bandwidth_size        = 10        # 带宽大小


  # Image information in different regions, you need to enter your own image ID or add another region.
  # For Marketplace Image Id,you can log in to Seller Console, view the marketplace image id on Product Specifications section of My Products detail page.
  #镜像版本：Centos 8.2  标准版64位
  # cn-north-4 北京4;  cn-southwest-2 贵阳1; south-1 广州,cn-east-3 ; cn-east3 上海一；cn-north-9 乌兰察布,ap-southeast-3 新加坡
  instance_image_id_maps = {
  # ap-southeast-3 = "4a0e5529-986b-4040-8951-817f456f7139"
    ap-southeast-3 = "f98f789a-d89f-4a64-96f0-a75e5408de01"
    cn-north-4     = "638a15ac-bc2b-4f87-a896-047a271caf65"
    cn-south-1     = "b5331dc9-9a18-4dcc-98c4-0c6d335aa548"
    cn-east-3      = "6674d782-54ba-4f04-896d-95edd50f2eb9"
    cn-north-9     = "1e24c609-dda2-4e13-9432-23c55ec4a708"
    cn-southwest-2 = "2316191e-117b-42b1-828c-a9a6e8a64e3a"
  }

  # Specifies the DNS server address list of a subnet. For details about the private DNS address, see https://support.huaweicloud.com/dns_faq/dns_faq_002.html#?
  subnet_dns_list_maps = {
    ap-southeast-3 = ["100.125.1.250","100.125.128.250"]
    cn-north-4     = ["100.125.1.250", "100.125.129.250"]
    cn-south-1     = ["100.125.1.250", "100.125.136.29"]
    cn-east-3      = ["100.125.1.250", "100.125.64.250"]
    cn-north-9     = ["100.125.1.250", "100.125.107.250"]
    cn-southwest-2 = ["100.125.1.250", "100.125.129.250"]
  }
  az_maps = {
    ap-southeast-3 = "ap-southeast-3a"
    cn-north-4     = "cn-north-4a"
    cn-south-1     = "cn-south-1c"
    cn-east-3      = "cn-east-3a"
    cn-north-9     = "cn-north-9a"
    cn-southwest-2 = "cn-southwest-2a"
  }


}

