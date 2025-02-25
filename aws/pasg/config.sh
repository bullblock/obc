#! /bin/bash
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
BASEDIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

function print_usage(){
    echo "Usage: sudo ./config.sh  \$password"
}

secret="KI3!f5ASA@klKSDK@)_!&112fc1"

# 将密码转换为MD5值
function password2Md5() {
    local password=$1
    # 先计算 password + secret 的 MD5，再与 secret 拼接后计算总的 MD5
    local step1=$(echo -n "$password$secret" | md5sum | awk '{print $1}')
    local final=$(echo -n "$secret$step1" | md5sum | awk '{print $1}')
    echo $final
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

hashed_password=$(password2Md5 "$password")
echo $hashed_password
curl --user-agent "paraview" -o /opt/pasg/data/.lic 'https://paraview-public-trial-license.s3.ap-southeast-1.amazonaws.com/pasg-trial.lic'
jq ".user[0].password = \"$hashed_password\"" $BASEDIR/pasgdb.json > /opt/pasg/db/pasgdb.json
sed -i "s/public_ip/$public_ip/g"  /opt/pasg/db/pasgdb.json
/opt/pasg/ngw restart
