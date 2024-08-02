#!/usr/bin/env fish

if test (count $argv) -ne 1
    echo "usage: aws-sso.fish profile"
    exit 1
end

set AWS_PROFILE $argv[1]

if not aws sts get-caller-identity &> /dev/null
    aws sso login --profile $AWS_PROFILE || exit 1
end

set credentials (aws configure export-credentials --profile $AWS_PROFILE)

set -Ux AWS_REGION            (aws configure get region --profile $AWS_PROFILE)
set -Ux AWS_ACCESS_KEY_ID     (echo $credentials | jq -r '.AccessKeyId')
set -Ux AWS_SECRET_ACCESS_KEY (echo $credentials | jq -r '.SecretAccessKey')
set -Ux AWS_SESSION_TOKEN     (echo $credentials | jq -r '.SessionToken')

echo "AWS credentials exported. Expiration: "(echo $credentials | jq -r '.Expiration')
