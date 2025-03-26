# AWS CLIが環境変数から認証情報を読み取る
AWS_ACCESS_KEY_ID="$1" AWS_SECRET_ACCESS_KEY="$2" AWS_SESSION_TOKEN="$3" aws sts get-caller-identity | jq
