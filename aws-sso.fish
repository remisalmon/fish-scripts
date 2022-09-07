#!/usr/bin/env fish

set AWS_PROFILE "default"

aws sso login --profile $AWS_PROFILE

set json_web_token (jq '.' (ls -t ~/.aws/sso/cache/*.json | head -n 1))

set AWS_REGION       (echo $json_web_token | jq -r '.region')
set AWS_ACCESS_TOKEN (echo $json_web_token | jq -r '.accessToken')
set AWS_ROLE_NAME    (aws configure get sso_role_name --profile $AWS_PROFILE)
set AWS_ACCOUNT_ID   (aws configure get sso_account_id --profile $AWS_PROFILE)

set role_credentials (
    aws sso get-role-credentials --region $AWS_REGION \
                                 --role-name $AWS_ROLE_NAME  \
                                 --account-id $AWS_ACCOUNT_ID \
                                 --access-token $AWS_ACCESS_TOKEN \
    | jq '.roleCredentials'
)

set -Ux AWS_ACCESS_KEY_ID     (echo $role_credentials | jq -r '.accessKeyId')
set -Ux AWS_SECRET_ACCESS_KEY (echo $role_credentials | jq -r '.secretAccessKey')
set -Ux AWS_SESSION_TOKEN     (echo $role_credentials | jq -r '.sessionToken')

echo "AWS SSO role credentials set. Expiration: "(echo $json_web_token | jq -r '.expiresAt')
