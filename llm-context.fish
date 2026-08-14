#!/usr/bin/env fish

# inspired by https://github.com/simonw/files-to-prompt

argparse n -- $argv || exit 1

if test (count $argv) -eq 0
    echo "usage: llm-context.fish [-n] PATH ..." && exit 1
end

set files (git rev-parse && git ls-files $argv || find $argv)

for file in $files
    if not test -f $file
        continue
    else if test (wc -c $file | string match -r "^\d+") -gt 1e6 # 1 MB
        continue
    else if string match -q -i -r "archives?/|artifacts?/" $file
        continue
    end

    echo $file
    echo ---

    if set -q _flag_n
        set file_content (cat -n $file | string trim -l | string collect)
    else
        set file_content (cat $file | string collect)
    end

    echo $file_content
    echo ---
end
