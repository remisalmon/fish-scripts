#!/usr/bin/env fish

# inspired by https://github.com/simonw/files-to-prompt

if test $argv[1] = --debug
    set debug true
    set argv $argv[2..-1]
else
    set debug false
end

if git rev-parse
    if test (count $argv) -gt 0
        set pattern "*"$argv"*"
    else
        set pattern "*"
    end

    echo $pattern

    set files (git ls-files $pattern)
else
    set pattern (string join "|" (string escape --style=regex $argv))

    set files (string match -e -r $pattern (ls -1 -a))
end

for file in $files
    if test (wc -c $file | string match -r "^\d+") -gt 1e6 # 1 MB
        continue
    else if string match -q -i -r "archives?/|artifacts?/" $file
        continue
    end

    if $debug
        echo "content of: "$file
    else
        echo -e "---\ncontent of "$file":\n---"

        cat -s $file
    end
end
