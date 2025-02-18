MFA v6.0.3 on AWS 部署说明

1. 登陆地址: http://$public_ip:80
2. 账号密码: sysadmin/$sysadmin_pwd   # sysadmin_pwd是部署脚本的参数,安装时设置随机密码。
3. 端口需求: 80,443                   # 部署完毕默认使用80端口,如果后续修改为https访问则需要使用443端口
4. 部署脚本使用: sh /opt/script/mfa_config.sh sysadmin_pwd    # sysadmin_pwd为传入的MFA默认账号密码(web登陆后仍然强制更新默认密码)
5. MFA服务管理命令: sudo su - esc -c '/opt/paraview/esc/bin/esc.sh all start|stop|status'
