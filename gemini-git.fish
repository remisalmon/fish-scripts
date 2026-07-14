#!/usr/bin/env fish

set use_diff false

git rev-parse || exit 1

if test (count $argv) -eq 0
    echo "usage: gemini-git.fish PROMPT ..." && exit 1
end

if $use_diff
    set prompt (string join " " $argv)" - return a single valid json object where each key is a file path and each value its unified diff with no prefix (for added or modified files) or null (for deleted files)"
else
    set prompt (string join " " $argv)" - return a single valid json object where each key is a file path and each value its full content (for added or modified files) or null (for deleted files)"
end

set response (timeout 0.5 cat | gemini-api.fish --json $prompt)

for k in (echo $response | jq -r '.|keys[]')
    set v (echo $response | jq -r '."'$k'"' | string trim -r | string collect)

    if test $v = null
        echo "gemini-git.fish is removing "(set_color green)$k(set_color normal)

        git rm --force --quiet $k
    else
        if contains $k (git ls-files $k)
            if contains $k (git diff --name-only --relative)
                echo "gemini-git.fish is staging "(set_color green)$k(set_color normal)

                git add $k
            end

            echo "gemini-git.fish is modifying "(set_color red)$k(set_color normal)
        else
            if not test -e (path dirname $k)
                echo "gemini-git.fish is making "(set_color red)(path dirname $k)"/"(set_color normal)

                mkdir -p (path dirname $k)
            end

            echo "gemini-git.fish is adding "(set_color red)$k(set_color normal)
        end

        if $use_diff
            echo $v | git apply -p0 --ignore-whitespace --recount
        else
            echo $v >$k
        end
    end
end
