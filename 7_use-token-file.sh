text=$(python3 3_token.py $1)
jwt=${text}.$(echo -n ${text} | python3 4_sign.py tmp/keypair.pem | base64 -w0)

unset AWS_ACCESS_KEY_ID
echo $jwt | AWS_ROLE_ARN=$2 AWS_WEB_IDENTITY_TOKEN_FILE=/dev/stdin AWS_ROLE_SESSION_NAME=tokenfile aws sts get-caller-identity | jq
