#!/usr/bin/env fish

set gemini /opt/local/bin/gemini

set model "gemini-2.5-flash"

set prompt (string join " " $argv | string escape -n)

if test -z $prompt
    exit 1
end

set data (timeout 0.5s cat | base64 -w 0)

if test -z $data
    set prompt "do not read or write any file - print the answer to the following instructions in a single code block: "$prompt

    set response ($gemini -m $model -p $prompt -y 2>>(status dirname)/gemini-cli.log | string collect)
else
    set prompt "do not read or write any file - decode this base64 encoded text, edit it with the following instructions, and print the decoded edited text in a single code block: "$prompt

    set response (echo $data | $gemini -m $model -p $prompt -y 2>>(status dirname)/gemini-cli.log | string collect)
end

if string match -q "```*```" $response
    echo $response | head -n -1 | tail -n +2
else
    echo $response
end
