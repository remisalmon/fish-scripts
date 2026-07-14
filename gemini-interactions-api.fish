#!/usr/bin/env fish

argparse json -- $argv || exit 1

if test (count $argv) -eq 0
    echo "usage: gemini-interactions-api.fish [--json] PROMPT ..." && exit 1
end

set model "gemini-3.5-flash"
set system_instruction "you are a text editor assistant running in a unix shell, return a single code block" # from https://ai.google.dev/gemini-api/docs/prompting-strategies

set response_format_mime_type (set -q _flag_json && echo "application/json" || echo "text/plain")
set prompt (string join " " -- $argv | string replace -a "\\" "\\\\" | string replace -a "\"" "\\\"")
set pipe (timeout 0.5 cat | base64 -w 0)
set previous_interaction_id (cat .gemini_interaction_id)

set response_format '{"type": "text", "mime_type": "'$response_format_mime_type'"}'

if not test -z $pipe
    set input '[{"type": "text", "text": "'$pipe'"}, {"type": "text", "text": "'$prompt'"}]'
else
    set input '"'$prompt'"'
end

if not test -z $previous_interaction_id
    set data '{"model": "'$model'", "system_instruction": "'$system_instruction'", "response_format": '$response_format', "input": '$input', "previous_interaction_id": "'$previous_interaction_id'"}'
else
    set data '{"model": "'$model'", "system_instruction": "'$system_instruction'", "response_format": '$response_format', "input": '$input'}'
end

set response (
    curl https://generativelanguage.googleapis.com/v1beta/interactions \
    --silent --retry 3 --max-time 300 \
    -H 'Content-Type: application/json' \
    -H 'x-goog-api-key: '$GEMINI_API_KEY \
    -X POST \
    -d $data \
    | string collect
)

if test -z $response
    set response null
else
    set response (echo $response | jq -s '.[-1]' | string collect)

    echo $response | jq -r '.id' >.gemini_interaction_id
end

duckdb (status dirname)/gemini-interactions-api.db \
    -c 'create table if not exists logs (created_at timestamp default current_localtimestamp(), model varchar, prompt varchar, response json);' \
    -c 'insert into logs (model, prompt, response) values ($_$'$model'$_$, $_$'$prompt'$_$, $_$'$response'$_$);' &

set text (echo $response | jq -r '.steps[-1].content[0].text' | string match -v -r "^```" | string collect)

test $text = null && exit 1

echo $text
