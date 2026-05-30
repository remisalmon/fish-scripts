#!/usr/bin/env fish

# inspired by https://github.com/simonw/files-to-prompt

if test (count $argv) -eq 0
    echo "usage: llm-context.fish [-n] PATTERN ..." && exit 1
else if test $argv[1] = -n
    set line_numbers true
    set args $argv[2..]
else
    set line_numbers false
    set args $argv
end

if git rev-parse
    set pattern "*"$args"*"
    set files (git ls-files $pattern)
else
    set pattern (string escape --style=regex -- $args | string join "|")
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

    echo -e "---\n"$file"\n---"

    if $line_numbers
        cat -n $file | string trim -l
    else
        cat $file
    end
end
