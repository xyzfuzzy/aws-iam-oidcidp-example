mkdir -p tmp
openssl genrsa -out tmp/keypair.pem 2048
openssl rsa -in tmp/keypair.pem -noout -modulus | cut -d= -f2 | xxd -r -p | base64 -w0 > tmp/public_modulus_base64
