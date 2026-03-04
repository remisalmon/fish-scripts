#!/usr/bin/env fish

# inspired by https://github.com/simonw/files-to-prompt

if git rev-parse
    if test (count $argv) -gt 0
        set pattern "*"$argv"*"
    else
        set pattern "*"
    end

    set files (git ls-files $pattern)
else
    set pattern (string escape --style=regex $argv | string join "|")

    set files (ls -1 -a -p | string match -v -r "/\$" | string match -e -r $pattern)
end

for file in $files
    if test (wc -c $file | string match -r "^\d+") -gt 1e6 # 1 MB
        continue
    else if string match -q -i -r "archives?/|artifacts?/" $file
        continue
    end

    echo -e "---\ncontent of "$file":\n---"

    cat -s $file
end
