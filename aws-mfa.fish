#!/usr/bin/env fish

if test -z $argv[1]
    echo "usage: aws-mfa.fish token-code"
    exit 1
end

set AWS_PROFILE "default"
set AWS_SERIAL_NUMBER ""
set AWS_TOKEN_CODE $argv[1]

set credentials (
    aws sts get-session-token --profile $AWS_PROFILE \
                              --serial-number $AWS_SERIAL_NUMBER \
                              --token-code $AWS_TOKEN_CODE \
    | jq '.Credentials'
)

set -Ux AWS_ACCESS_KEY_ID     (echo $credentials | jq -r '.AccessKeyId')
set -Ux AWS_SECRET_ACCESS_KEY (echo $credentials | jq -r '.SecretAccessKey')
set -Ux AWS_SESSION_TOKEN     (echo $credentials | jq -r '.SessionToken')

echo "Credentials set. Expiration: "(echo $credentials | jq -r '.Expiration')
