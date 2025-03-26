alias terraform='docker run -it -v $(pwd):/code -w /code $(get_cred) hashicorp/terraform:latest'
get_cred() { curl -s -H "Authorization:${AWS_CONTAINER_AUTHORIZATION_TOKEN}" ${AWS_CONTAINER_CREDENTIALS_FULL_URI} | jq -r '"-e AWS_ACCESS_KEY_ID=\(.AccessKeyId) -e AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey) -e AWS_SESSION_TOKEN=\(.Token)"';}
