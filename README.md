# AWS OIDCプロバイダー検証用

## 使い方

AWSアカウントを用意して、CloudShellから次のようにするとOIDCプロバイダーが体験できます。実行例は当リポジトリのActionからも確認できます。

```
$ git clone https://github.com/xyzfuzzy/public-test.git
$ cd public-test
$ . setup_cloudshell.sh
$ terraform -chdir=2_terraform init
$ bash 1_newkey.sh

$ terraform -chdir=2_terraform apply

$ terraform -chdir=2_terraform output -json > tmp/terraform_out.json
$ TF_url_issuer=$(jq -r '.url_issuer.value' tmp/terraform_out.json)
$ TF_role_arn=$(jq -r '.role_arn.value' tmp/terraform_out.json)

$ tosign=$(python3 3_token.py $TF_url_issuer)
$ jwt=${tosign}.$(echo -n ${tosign} | openssl dgst -sha256 -sign tmp/keypair.pem | base64 -w0)

$ cred=$(sh 5_assumerole-with-webid.sh $TF_role_arn $jwt)
$ sh 6_check-identity.sh $cred

$ terraform -chdir=2_terraform destroy
```

※ CloudShellをご利用の際は、ストレージ領域の残量にご注意ください

