#!/usr/bin/env fish

set max_time (math "60 * 5")

set model "gemini-2.5-flash"
# set model "gemini-2.5-pro"

set system_instruction "return only one code block without examples or explanations"

set prompt (string join " " $argv)

if test -z $prompt
    exit 1
end

set data (timeout 0.5 cat | string join "\n" | string escape -n || echo "")

set contents (string trim $data" "$prompt)

set tic (date +%s)

set response (
    curl https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$GEMINI_API_KEY} \
    -s \
    -m $max_time \
    -H 'Content-Type: application/json' \
    -d '{"system_instruction": {"parts": [{"text": "'{$system_instruction}'"}]}, "contents": [{"parts": [{"text": "'{$contents}'"}]}]}' \
    | string collect
)

set toc (date +%s)

set response_time (math $toc" - "$tic)

if test -z $response
    exit 1
end

duckdb (status dirname)/gemini-cli.db \
    -c "create table if not exists logs (created_at timestamp default current_timestamp, model varchar, prompt varchar, response json, response_time integer);" \
    -c "insert into logs (model, prompt, response, response_time) values(\$\$"$model"\$\$, \$\$"$prompt"\$\$, \$\$"$response"\$\$, \$\$"$response_time"\$\$);" &

set response (echo $response | jq -r '.candidates[0].content.parts[0].text' | string collect)

if string match -q "```*```" $response
    echo $response | head -n -1 | tail -n +2
else
    echo $response
end
