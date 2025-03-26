import json,base64,datetime,sys

head1 = {"alg":"RS256","kid":"k1"}
head = base64.b64encode(json.dumps(head1).encode()).decode()

iat = int(datetime.datetime.now().timestamp())
payload1 = {
    "sub":"sub1",
    "exp": iat + 3600,
    "iss": sys.argv[1],
    "iat": iat,
    "aud":"sts.amazonaws.com"}
payload = base64.b64encode(json.dumps(payload1).encode()).decode()

print(f"{head}.{payload}",end="")
