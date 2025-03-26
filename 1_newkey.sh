mkdir -p tmp
openssl genrsa -out tmp/keypair.pem 2048
openssl pkey -in tmp/keypair.pem -pubout -out tmp/publickey.pem
openssl rsa -in tmp/publickey.pem -noout -pubin -modulus | cut -d= -f2 | xxd -r -p | base64 -w0 > tmp/public_modulus_base64

# このスクリプトでは次を作成します
# tmpというディレクトリ
# tmpディレクトリ内のファイル
#    keypair.pem ・・・ランダムにに生成した秘密鍵ファイル
#    publilckey.pem・・・上記秘密鍵に対応する公開鍵ファイル
#    public_modulus_base64・・・上記公開鍵ファイルから抽出したmodulusの値
# このスクリプトを実行するたびに各ファイルは上書きされます
