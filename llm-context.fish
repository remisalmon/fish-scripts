#!/usr/bin/env fish

# inspired by https://github.com/simonw/files-to-prompt

if test (count $argv) -eq 0
    echo "usage: llm-context.fish PATTERN ..." && exit 1
end

if git rev-parse
    set pattern "*"$argv"*"
    set files (git ls-files $pattern)
else
    set pattern (string escape --style=regex -- $argv | string join "|")
    set files (ls -1 -a | string match -e -r $pattern)
end

for file in $files
    if not test -f $file
        continue
    else if test (wc -c $file | string match -r "^\d+") -gt 1e6 # 1 MB
        continue
    else if string match -q -i -r "archives?/|artifacts?/" $file
        continue
    end

    echo -e "---\ncontent of "$file":\n---"

    cat $file
end
