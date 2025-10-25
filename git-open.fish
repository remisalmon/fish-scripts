#!/usr/bin/env fish

if not git rev-parse
    exit 1
end

set pattern (string join ".*" $argv)
set editor (git config get core.editor)
set files (git ls-files | string match -i -e -r $pattern)

if test (count $files) -eq 0
    set files (git grep -i -l $pattern)
end

set files (echo -s -n $files\n | grep -v -i -E "(archives|artifacts)/")

if test (count $files) -eq 0
    exit 1
end

set_color green && echo "candidate(s):"
set_color normal && echo -s -n $files\n | cat -n -

if test (count $files) -eq 1
    set n 1
else
    read -p "set_color green && echo -n -e \"\nchoice: \" && set_color normal" n
end

$editor $files[$n]
