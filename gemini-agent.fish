#!/usr/bin/env fish

git rev-parse || exit 1

if test (count $argv) -eq 0
    echo "usage: gemini-agent.fish PROMPT ..." && exit 1
end

set prompt (string join " " $argv)" - return a json object having the path of each file as key and the full content of each file (if added or modified) or null (if deleted) as value"

set response (timeout 0.5 cat | gemini-api.fish --json $prompt)

for k in (echo $response | jq -r '.|keys[]')
    set v (echo $response | jq -r '."'$k'"' | string trim -r | string collect)

    if contains $k (git diff --name-only)
        echo "gemini-agent.fish is staging "(set_color green)$k(set_color normal)

        git add $k
    else if not test -e (path dirname $k)
        echo "gemini-agent.fish is making "(set_color red)(path dirname $k)"/"(set_color normal)

        mkdir -p (path dirname $k)
    end

    if test $v = null
        echo "gemini-agent.fish is removing "(set_color red)$k(set_color normal)

        rm -f $k
    else
        echo "gemini-agent.fish is writing to "(set_color red)$k(set_color normal)

        echo $v >$k
    end
end
