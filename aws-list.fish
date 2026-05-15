#!/usr/bin/env fish

set aws_account (aws sts get-caller-identity | jq -r '.Account')

if test -z $aws_account
    exit 1
end

set aws_profile (grep -B 2 $aws_account ~/.aws/config | grep "profile")
set aws_profiles (grep "profile" ~/.aws/config)

for i in $aws_profiles
    set profile (echo $i | string sub -s 10 -e -1)

    if test $i = $aws_profile
        echo (set_color green)"* "$profile(set_color normal)
    else
        echo "  "$profile
    end
end
