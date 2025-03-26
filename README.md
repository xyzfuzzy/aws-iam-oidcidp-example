# AWS OIDCプロバイダー検証用

AWSのOIDCプロバイダー機能を検証するための最低限のサンプルです。
ブログ記事用に作りました。

## 使い方

AWSアカウントを用意して、CloudShellから次の順番でコマンドを入力していきます。上から下まで実行すれば、AWSリソースの作成・削除、AWSの認証情報の取得・検証、などが体験できます。

### １．チェックアウト

```
$ git clone https://github.com/xyzfuzzy/aws-iam-oidcidp-example.git
$ cd aws-iam-oidcidp-example
$ . setup_cloudshell.sh
```

本リポジトリをCloudShell内にチェックアウトします。
setup_cloudshell.shではDockerを使ってTerraformが実行できるようにしています。

### ２．検証環境構築

```
$ terraform -chdir=2_terraform init
$ bash 1_newkey.sh

$ terraform -chdir=2_terraform apply

$ terraform -chdir=2_terraform output -json > tmp/terraform_out.json
$ TF_url_issuer=$(jq -r '.url_issuer.value' tmp/terraform_out.json)
$ TF_role_arn=$(jq -r '.role_arn.value' tmp/terraform_out.json)
```

1_newkey.shではIdPが使う鍵ペアを作成しています。鍵ペアはtmp/keypair.pemというファイルに保存されます。

次に、`terraform apply`を実行すると、作成されるリソースの一覧が表示され、入力待ちになりますので`yes`と入力してください。このコマンドで次のものが構築されます。

* API Gateway (OIDC設定値取得エンドポイント)
* IAMロール
* OIDCプロバイダー

API GatewayのアドレスやロールARNを環境変数に入れています。これらの変数は後から使います。

### ３．JWT生成

```sh
$ text=$(python3 3_token.py $TF_url_issuer)
$ jwt=${text}.$(echo -n ${text} | openssl dgst -sha256 -sign tmp/keypair.pem | base64 -w0)
```

JWTは`(text).(署名)`の形をしており、`text`部分は2つのJSONを連結した文字列です。
署名を計算するのにopensslコマンドを使っています。

### ４．短期の認証情報の取得

```sh
$ cred=$(sh 5_assumerole-with-webid.sh $TF_role_arn $jwt)
```

5_assumerole-with-webid.shでは`aws sts assume-role-with-web-identity`コマンドにJWTを渡して認証情報を取得します。


### ５．短期の認証情報の確認

```sh
$ sh 6_check-identity.sh $cred
```

6_check-identity.shはaws sts get-caller-identityを呼び出して認証情報が正しいことを確認します。

### ６．リソース削除

```
$ terraform -chdir=2_terraform destroy
```

## 注意点

CloudShellをご利用の際は、ストレージ領域の残量にご注意ください

## 参考

勉強のために、Pythonで、署名を計算するプログラムを作ってみました。
「３．JWT生成」において`openssl dgst -sha256 -sign tmp/keypair.pem`の代わりに`python3 4_sign.py tmp/keypair.pem`としても動くはずです。
