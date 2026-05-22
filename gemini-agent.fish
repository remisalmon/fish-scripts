#!/usr/bin/env fish

git rev-parse || exit 1

if test (count $argv) -eq 0
    echo "usage: gemini-agent.fish PROMPT ..." && exit 1
end

set prompt (string join " " $argv)" - answer in a single json object having the path of each new or modified file as key and the full content of each new or modified file as value"

set response (timeout 0.5 cat | gemini-api.fish $prompt)

for k in (echo $response | jq -r '.|keys[]')
    set v (echo $response | jq -r '."'$k'"' | string collect)

    if contains $k (git diff --name-only)
        echo "gemini-agent.fish is staging "(set_color green)$k(set_color normal)

        git add $k
    else if not test -e (path dirname $k)
        echo "gemini-agent.fish is making "(set_color red)(path dirname $k)"/"(set_color normal)

        mkdir -p (path dirname $k)
    end

    echo "gemini-agent.fish is writing to "(set_color red)$k(set_color normal)
    echo $v >$k
end
