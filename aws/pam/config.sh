#! /bin/bash
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
BASEDIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

source /etc/profile
function encryption_pwd() {
  salt='CDTawaOQctauRprWRXTCltzPepdgpoWYdPNbnhbidaFovCrlgbRJhxqJGqSRdfUMlKKFXSWaFMLUMBmnVisWpDYddzKPectgZSgtLnpTneSFmwegwoyqPEPPuOJxlIev'
  echo -n "$salt$1" | sha256sum | awk '{print $1}'
}


function print_usage(){
    echo "Usage: sudo ./config.sh \$password"
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

#生成证书
scp /opt/paraview/pam/app/jdk8/jre/lib/security/cacerts /opt/script/certs/cacerts

sed "s/private_ip/$private_ip/g" /opt/script/pam.conf > /opt/script/certs/pam.conf

sed -i "s/public_ip/$public_ip/g" /opt/script/certs/pam.conf

cd /opt/script/certs
./gen_certs.sh
#scp * /opt/paraview/pam/etc/certs/

cd $BASEDIR

#supervisorctl restart epv-server osc-server pas-server


sed  "s/127.0.0.1/$public_ip/g" /opt/script/pasgdb.json.template  >  /opt/script/pasgdb.json

#替换证书逻辑
pam_key=`awk '{ printf("%s\\n", $0) }' ${BASEDIR}/certs/pam.key`
pam_crt=`awk '{ printf("%s\\n", $0) }' ${BASEDIR}/certs/pam.crt`
ca_crt=`awk '{ printf("%s\\n", $0) }'  ${BASEDIR}/certs/ca.crt`
length=`/opt/paraview/pam/bin/jq '.tls|length' $BASEDIR/pasgdb.json`
for ((i = 0; i < $length; i++))
do
  id=`/opt/paraview/pam/bin/jq -r .tls[$i].id $BASEDIR/pasgdb.json`
  if [ "$id"z == "PAM_INNER_CERT"z ] || [ "$id"z == "PAM_CERT"z ];then
     /opt/paraview/pam/bin/jq --arg newval "${pam_key}"  '.tls['$i'].secureContextOptions.key |=$newval' $BASEDIR/pasgdb.json >  $BASEDIR/temp.json && scp $BASEDIR/temp.json $BASEDIR/pasgdb.json
     /opt/paraview/pam/bin/jq --arg newval "${pam_crt}"  '.tls['$i'].secureContextOptions.cert |=$newval' $BASEDIR/pasgdb.json >  $BASEDIR/temp.json && scp $BASEDIR/temp.json $BASEDIR/pasgdb.json
     /opt/paraview/pam/bin/jq --arg newval "${ca_crt}"  '.tls['$i'].secureContextOptions.ca |=$newval' $BASEDIR/pasgdb.json >  $BASEDIR/temp.json && scp $BASEDIR/temp.json $BASEDIR/pasgdb.json
  fi
done

/opt/paraview/pam/app/para-node4/ngw stop

/opt/paraview/pam/app/redis/bin/redis-cli -a 'Demo.123!' flushall

scp $BASEDIR/pasgdb.json /opt/paraview/pam/data/para-node4/db/pasgdb.json

/opt/paraview/pam/app/para-node4/ngw start

curl --user-agent "paraview" -o /opt/script/.lic 'https://paraview-public-trial-license.s3.ap-southeast-1.amazonaws.com/pam-trial.lic'


lic=`cat /opt/script/.lic`
enc_pwd=$(encryption_pwd $password)
psql -U postgres -d pam -c "UPDATE pam.pas_license SET pr_content = '$lic' WHERE pr_type = 1;"
psql -U postgres -d pam -c "UPDATE pam.yaum_user SET  user_pwd = '$enc_pwd'"


sed "s/127.0.0.1:31505/$public_ip:31505/g" /opt/script/pas.properties > /opt/paraview/pam/etc/pas.properties

supervisorctl restart pas-server