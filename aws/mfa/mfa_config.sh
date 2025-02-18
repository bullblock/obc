#!/bin/sh

if [ $# == 1 ];then
  echo "Start installing Paraview MFA v6.0.3"
else
  echo "Parameter required." 
  echo "example: sh mfa_config.sh sysadmin_pwd" 
  exit 1
fi

random_pwd=$1

/usr/bin/echo 'devops:Admin!23Admin' | /usr/bin/sudo /usr/sbin/chpasswd
script_dir=$(cd "$(dirname "$0")"; pwd)
cd $script_dir

private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
ssh_user=devops
ssh_pass="Admin!23Admin"

# allow password authentication of ssh
sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# copy template inventory and modify
sudo cp -f inventory.standalone.sudo inventory

# modify host and home_url
sudo sed -i "s/1.1.1.1/${private_ip}/g" inventory
sudo sed -i "s/homeurl=esc.paraview.cn/homeurl=${public_ip}/g" inventory
sudo sed -i "s/gateway_mgmt_url=gateway.paraview.cn/gateway_mgmt_url=${public_ip}/g" inventory

# modify ansible ssh user and password
sudo sed -i "s/ansible_ssh_user=root/ansible_ssh_user=${ssh_user}/g" inventory
sudo sed -i "s/ansible_ssh_pass=123456/ansible_ssh_pass=${ssh_pass}/g" inventory

# modify ansible sudo password (if needed) (some as the ssh user's password)
sudo sed -i "s/ansible_become_pass=123456/ansible_become_pass=${ssh_pass}/g" inventory

# download mfa trial lic
rm -f iam-603-mfa-trial.lic
curl --user-agent "paraview" -o iam-603-mfa-trial.lic 'https://paraview-public-trial-license.s3.ap-southeast-1.amazonaws.com/iam-603-mfa-trial.lic'
lic_string="$(cat iam-603-mfa-trial.lic)"

# make update_lic.sql
cat > ./update_lic.sql << EOF
-- import trial license
truncate table sys_license;
INSERT INTO sys_license VALUES (1111111111111111111, 'sysadmin', 'sysadmin', '2025-01-01 00:00:00', '2025-01-01 00:00:00', 'paraview', '${lic_string}');
EOF

# add sql to idm-6.0.0.1.sql
cat update_lic.sql >> ${script_dir}/tarballs/sql/6.0.3/6.0.3.0/6.0.3.0-idm.sql
rm -f update_lic.sql

# make update_sys_pass.sql 
# 6.0.3 use sha256 as default encrypt method
cat > ./playbook/roles/dbinit/templates/encryption.sql << EOF
-- 更新默认RSA密钥
UPDATE sys_productkey SET key1 = '{{ iam_rsa_key.stdout }}', key2 = '{{ iam_rsa_pub_key.stdout }}', create_time = '{{ current_time.stdout }}', update_time = '{{ current_time.stdout }}' WHERE algorithm = 'RSA';

-- 更新默认SM2密钥
UPDATE sys_productkey SET key1 = '{{ iam_sm2_key.stdout }}', key2 = '{{ iam_sm2_pub_key.stdout }}', create_time = '{{ current_time.stdout }}', update_time = '{{ current_time.stdout }}' WHERE algorithm = 'SM2';

-- 指定加密算法为 SHA256
UPDATE pi_sso_settings_table SET value = 'SHA256' WHERE name = 'sso.authn.cipher.algorithm';

-- 修改sysadmin密码为SHA@256加密
update idt_user set pwd= SHA2(CONCAT('{{ sys_pwd_salt.stdout }}','${random_pwd}'), 256), pwd_salt='{{ sys_pwd_salt.stdout }}' where user_uid = 'sysadmin';
EOF

# begin install
sudo bash install.sh
#nohup sudo bash install.sh > ./install.log 2>&1 &

#deny password authentication of ssh
sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

