#!/usr/bin/env fish

set use_diff true

git rev-parse || exit 1

if test (count $argv) -eq 0
    echo "usage: gemini-git.fish PROMPT ..." && exit 1
end

if $use_diff
    set prompt (string join " " $argv)" - return a json object having the path of each file as key and a unified diff with no prefix of each file (if added or modified) or a null (if deleted) as value"
else
    set prompt (string join " " $argv)" - return a json object having the path of each file as key and the full content of each file (if added or modified) or null (if deleted) as value"
end

set response (timeout 0.5 cat | gemini-api.fish --json $prompt)

for k in (echo $response | jq -r '.|keys[]')
    set v (echo $response | jq -r '."'$k'"' | string trim -r | string collect)

    if contains $k (git diff --name-only)
        echo "gemini-git.fish is staging "(set_color green)$k(set_color normal)

        git add $k
    else if not test -e (path dirname $k)
        echo "gemini-git.fish is making "(set_color red)(path dirname $k)"/"(set_color normal)

        mkdir -p (path dirname $k)
    end

    if test $v = null
        echo "gemini-git.fish is removing "(set_color green)$k(set_color normal)

        git rm --force --quiet $k
    else
        echo "gemini-git.fish is editing "(set_color red)$k(set_color normal)

        if $use_diff
            echo $v | git apply -p0 --ignore-whitespace --recount
        else
            echo $v >$k
        end
    end
end
