#!/usr/bin/env fish

argparse json -- $argv || exit 1

test (count $argv) -eq 0 && exit 1

set model "gemini-3.5-flash"
set system_instruction "you are a text editor assistant running in a unix shell, return a single code block" # from https://ai.google.dev/gemini-api/docs/prompting-strategies

set response_mime_type (set -q _flag_json && echo "application/json" || echo "text/plain")
set prompt (string join " " -- $argv | string replace -a "\\" "\\\\" | string replace -a "\"" "\\\"")
set data (timeout 0.5 cat | base64 -w 0)

set content '{"text": "'$prompt'"}'

if not test -z $data
    set content '{"inlineData": {"mimeType": "text/plain", "data": "'$data'"}}, '$content
end

set response (
    curl https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent \
    --silent --retry 3 --max-time 300 \
    -H 'x-goog-api-key: '$GEMINI_API_KEY \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{"systemInstruction": {"parts": [{"text": "'$system_instruction'"}]}, "generationConfig": {"responseMimeType": "'$response_mime_type'"}, "contents": [{"parts": ['$content']}]}' \
    | string collect
)

if test -z $response
    set response null
end

duckdb (status dirname)/gemini-api.db \
    -c 'create table if not exists logs (created_at timestamp default current_localtimestamp(), model varchar, prompt varchar, response json);' \
    -c 'insert into logs (model, prompt, response) values ($_$'$model'$_$, $_$'$prompt'$_$, $_$'$response'$_$);' &

set text (echo $response | jq -r '.candidates[0].content.parts[0].text' | string match -v -r "^```" | string collect)

test $text = null && exit 1

echo $text
