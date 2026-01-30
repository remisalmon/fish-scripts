#!/usr/bin/env fish

if not set -q argv[1]
    echo "usage: aws-sso.fish profile" && exit 1
end

set -g profile $argv[1]

function set_credentials
    set -g credentials (aws configure export-credentials --profile $profile)
end

if not set_credentials
    aws sso login --profile $profile && set_credentials || exit 1
end

set -Ux AWS_REGION            (aws configure get region --profile $profile)
set -Ux AWS_ACCESS_KEY_ID     (echo $credentials | jq -r '.AccessKeyId')
set -Ux AWS_SECRET_ACCESS_KEY (echo $credentials | jq -r '.SecretAccessKey')
set -Ux AWS_SESSION_TOKEN     (echo $credentials | jq -r '.SessionToken')

echo "AWS credentials exported. Expiration: "(echo $credentials | jq -r '.Expiration')
