#!/usr/bin/env fish

set model gemini-3-flash-preview

set system_instruction "you are a code assistant running in a unix shell, answer without examples or explanations"

set prompt (string join " " -- $argv | string replace -a "\"" "\\\"")

if test -z $prompt
    exit 1
end

set data (timeout 0.5 cat | base64 -w 0)

set content '{"text": "'$prompt'"}'

if not test -z $data
    set content '{"inline_data": {"mime_type": "text/plain", "data": "'$data'"}}, '$content
end

for try in (seq 3)
    set tic (date +%s)

    set response (
        curl https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent \
        -s \
        -m 300 \
        -H 'x-goog-api-key: '$GEMINI_API_KEY \
        -H 'Content-Type: application/json' \
        -X POST \
        -d '{"system_instruction": {"parts": [{"text": "'$system_instruction'"}]}, "contents": [{"parts": ['$content']}]}' \
        | string collect
    )

    set toc (date +%s)

    if test -z $response
        set response null
    end

    duckdb (status dirname)/gemini-api.db \
        -c 'create table if not exists logs (created_at timestamp default current_localtimestamp(), model varchar, prompt varchar, response json, response_time_seconds integer, retry_count integer);' \
        -c 'insert into logs (model, prompt, response, response_time_seconds, retry_count) values($$'$model'$$, $$'$prompt'$$, $$'$response'$$, $$'(math $toc - $tic)'$$, $$'(math $try - 1)'$$);' &

    if test (echo $response | jq -r '.error.code') != 503
        break
    else
        sleep $try
    end
end

echo $response | jq -r '.candidates[0].content.parts[0].text' | string match -v -r "^```"
