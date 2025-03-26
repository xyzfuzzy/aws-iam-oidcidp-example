terraform -chdir=2_terraform init

# generate RSA key
bash 1_newkey.sh

# setup AWS OIDC IdP
terraform -chdir=2_terraform apply --auto-approve
terraform -chdir=2_terraform apply --auto-approve

# extract variables
terraform -chdir=2_terraform output -json > tmp/terraform_out.json
TF_url_issuer=$(jq -r '.url_issuer.value' tmp/terraform_out.json)
TF_role_arn=$(jq -r '.role_arn.value' tmp/terraform_out.json)

sleep 5

# generate jwt
text=$(python3 3_token.py $TF_url_issuer)
jwt=${text}.$(echo -n ${text} | openssl dgst -sha256 -sign tmp/keypair.pem | base64 -w0)

# get credential using jwt
cred=$(sh 5_assumerole-with-webid.sh $TF_role_arn $jwt)

# test credential
sh 6_check-identity.sh $cred

# alternative way
sh 7_use-token-file.sh $TF_url_issuer $TF_role_arn

# clean up
terraform -chdir=2_terraform destroy --auto-approve
