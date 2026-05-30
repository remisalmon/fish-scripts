#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo "usage: gemini-interactions-api.fish PROMPT ..." && exit 1
end

set model "gemini-3.5-flash"
set system_instruction "you are a coding assistant running in a unix shell, return a single code block" # from https://ai.google.dev/gemini-api/docs/prompting-strategies

set prompt (string join " " -- $argv | string replace -a "\\" "\\\\" | string replace -a "\"" "\\\"")
set pipe (timeout 0.5 cat | base64 -w 0)
set previous_interaction_id (cat .gemini_interaction_id)

if not test -z $pipe
    set input '[{"type": "text", "text": "'$pipe'"}, {"type": "text", "text": "'$prompt'"}]'
else
    set input '"'$prompt'"'
end

if not test -z $previous_interaction_id
    set data '{"model": "'$model'", "system_instruction": "'$system_instruction'", "input": '$input', "previous_interaction_id": "'$previous_interaction_id'"}'
else
    set data '{"model": "'$model'", "system_instruction": "'$system_instruction'", "input": '$input'}'
end

for try in (seq 3)
    set tic (date +%s)
    set response (
        curl https://generativelanguage.googleapis.com/v1beta/interactions \
        -s \
        -m 300 \
        -X POST \
        -H 'Content-Type: application/json' \
        -H 'x-goog-api-key: '$GEMINI_API_KEY \
        -d $data \
        | string collect
    )
    set toc (date +%s)

    if test -z $response
        set response "{}"
    else
        echo $response | jq -r '.id' >.gemini_interaction_id
    end

    duckdb (status dirname)/gemini-interactions-api.db \
        -c 'create table if not exists logs (created_at timestamp default current_localtimestamp(), model varchar, prompt varchar, response json, response_time_seconds integer, retry_count integer);' \
        -c 'insert into logs (model, prompt, response, response_time_seconds, retry_count) values($$'$model'$$, $$'$prompt'$$, nullif($$'(string replace -a "\$" "\\\\\$" $response | string collect)'$$, $${}$$), $$'(math $toc - $tic)'$$, $$'(math $try - 1)'$$);' &

    if test (echo $response | jq -r '.error.code') != 503
        break
    else
        sleep $try
    end
end

echo $response | jq -r '.outputs[-1].text' | string match -v -r "^```"
