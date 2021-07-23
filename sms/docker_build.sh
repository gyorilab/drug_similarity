# Create file synapse_auth_token before running:
# [authentication]
# authtoken=xxx

docker build --secret id=synapse,src=synapse_auth_token -t drug-similarity-sms --progress plain . 2>&1 | less
