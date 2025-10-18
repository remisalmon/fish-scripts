#!/usr/bin/env fish

set gemini /opt/local/bin/gemini

# set model "gemini-2.5-pro"
set model "gemini-2.5-flash"

set prompt (string join " " $argv | string escape -n)

if test -z $prompt
    exit 1
end

set prompt $prompt" - return one code block with the given files and instructions, without adding examples or explanations, without using tools or extensions"

set response ($gemini -m $model -p $prompt 2>>(status dirname)/gemini-cli.log | string collect)

if string match -q "```*```" $response
    echo $response | head -n -1 | tail -n +2
else
    echo $response
end
