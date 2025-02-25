#! /bin/bash
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
done
BASEDIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
source /etc/profile

function test_port(){
local HOST=$1
local PORT=$2
if echo > /dev/tcp/$HOST/$PORT; then
   return 0
else
   return 1
fi
}


function check_svc(){

test_port apim-system-service 28101
system_status=$?

while [[ $system_status -ne 0 ]]
do
   sleep 10  # 添加一个 sleep 来避免无限循环占用 CPU
   test_port apim-system-service 28101
done
}

function encryption_pwd() {
  echo -n $(echo -n "$1" | openssl dgst -sha256 -hex | awk '{print $2}')|md5sum |awk '{print $1}'
}

function print_usage(){
    echo "Usage: sudo ./config.sh  \$password"
}
token=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
private_ip=$(curl -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/local-ipv4)
public_ip=$(curl -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/public-ipv4)
password=$1
if [ -z "$private_ip" ] || [ -z "$public_ip" ] || [ -z "$password" ]; then
 print_usage
 exit 1
fi

# check command
case $1 in
    --help|-help|-h)
        print_usage
        exit 1
        ;;
esac


sleep 30


check_svc

curl --user-agent "paraview" -o /opt/script/.lic 'https://paraview-public-trial-license.s3.ap-southeast-1.amazonaws.com/apigw-ent-trial.lic'

curl --location --request POST 'http://127.0.0.1/api/system/license/upload' \
--header 'Authorization: Para&158*abc34f' \
--form 'file=@"/opt/script/.lic"'

enc_pwd=$(encryption_pwd $password)

psql -U postgres -d api-gateway -c "UPDATE gateway.gw_cluster SET  access_url = 'http://$public_ip:8000',  https_access_url = 'https://$public_ip:8443', cluster_type = 'gateway' WHERE name = 'Demo';"
psql -U postgres -d api-gateway -c "UPDATE portal.collect_file_upload_config SET host = '$public_ip'  WHERE server_id = 'parser'"
psql -U postgres -d api-gateway -c "UPDATE system.users SET  password = '$enc_pwd' where name='admin';"
