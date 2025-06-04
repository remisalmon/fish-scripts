#!/usr/bin/env fish

if test (count $argv) -gt 0
    llm -x -s "return only a single code block without examples or explanations" (string join " " $argv) | string collect
end
