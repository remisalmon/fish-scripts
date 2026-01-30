#!/usr/bin/env fish

if not set -q argv[1]
    echo "usage: snowflake-sso.fish env [DATABASE.SCHEMA]" && exit 1
end

set username $SNOWFLAKE_USER
set log /tmp/snowflake-sso.log

switch $argv[1]
    case "dev*"
        set account_identifier $SNOWFLAKE_ACCOUNT_DEVELOPMENT
    case "st*g*"
        set account_identifier $SNOWFLAKE_ACCOUNT_STAGING
    case "pr*d*"
        set account_identifier $SNOWFLAKE_ACCOUNT_PRODUCTION
    case "*"
        echo "bad env "$argv[1] && exit 1
end

if test (count $argv) -eq 2
    set dbname (string replace "." "/" $argv[2])
else
    set dbname ""
end

function connect
    usql snowflake://{$username}@{$account_identifier}/{$dbname}\?role=SYSADMIN&warehouse=DEV_WH&authenticator=EXTERNALBROWSER&client_session_keep_alive=true
end

while true
    connect 2>| tee $log

    if not string match -e -q 390195 <$log
        break
    end
end
