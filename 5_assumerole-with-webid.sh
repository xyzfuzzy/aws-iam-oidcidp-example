set -e
time=$(date +%Y%m%d-%H%M%S)
result=$(aws sts assume-role-with-web-identity --duration-seconds 900 \
                                               --role-session-name webid-${time} \
                                               --role-arn $1 \
                                               --web-identity-token $2)


# 参考までにcurlコマンドでもAssumeRoleWithWebIdentityは呼び出せる
curl -s --data Action=AssumeRoleWithWebIdentity \
        --data DurationSeconds=900 \
        --data RoleSessionName=session1 \
        --data Version=2011-06-15 \
        --data RoleArn=$1 \
        --data-urlencode WebIdentityToken=$2 \
        https://sts.amazonaws.com/ > /dev/null


echo $result |jq -r '.Credentials| (.["AccessKeyId"] + " " + .["SecretAccessKey"] + " " + .["SessionToken"])'
