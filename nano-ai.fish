#!/usr/bin/env fish

set model "gemini-2.5-flash"
# set model "gemini-2.5-pro"

set system_instruction "You are a code assistant for a text editor, return only a single code block without examples or explanations."

set prompt (string join " " $argv)

if test -z $prompt
    exit 1
end

set data (timeout 0.5 cat | string join "\n" | string escape -n || echo "")

set contents (string trim $data" "$prompt)

set response (
    curl https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$GEMINI_API_KEY} \
    -s \
    -m 50 \
    -H 'Content-Type: application/json' \
    -d '{"system_instruction": {"parts": [{"text": "'{$system_instruction}'"}]}, "contents": [{"parts": [{"text": "'{$contents}'"}]}]}' \
    | string collect
)

if test -z $response
    exit 1
end

echo $response | jq -r '.candidates[0].content.parts[0].text' | string collect | head -n -1 | tail -n +2

duckdb (status dirname)/nano-ai.db \
    -c "create table if not exists logs (created_at timestamp default current_timestamp, model varchar, prompt varchar, response json);" \
    -c "insert into logs (model, prompt, response) values(\$\$"$model"\$\$, \$\$"$prompt"\$\$, \$\$"$response"\$\$);" &
