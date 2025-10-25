#!/usr/bin/env fish

set gemini /opt/local/bin/gemini

# set model "gemini-2.5-pro"
set model "gemini-2.5-flash"

set prompt (string join " " $argv | string escape -n)

if test -z $prompt
    exit 1
end

set prompt $prompt" - output a single code block and preserve the input format - do not add examples or explanations - do not try to read or write files"

set response ($gemini -m $model -p $prompt 2>>(status dirname)/gemini-cli.log | string collect)

if string match -q "```*```" $response
    echo $response | head -n -1 | tail -n +2
else
    echo $response
end
