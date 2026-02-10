#!/usr/bin/env fish

if not git rev-parse
    exit 1
end

set pattern (string join ".*" $argv)
set editor (git config get core.editor)
set toplevel (git rev-parse --show-toplevel)
set files (git ls-files $toplevel | string match -i -e -r $pattern)

if test (count $files) -eq 0
    set files (git grep -i -l $pattern $toplevel)
end

set files (string match -v -i -r "archives/|artifacts/" $files)

if test (count $files) -eq 0
    exit 1
end

echo (set_color green)"candidate(s):"(set_color normal)

string join \n $files | cat -n -

if test (count $files) -eq 1
    set n 1
else
    read -p 'echo -n (set_color green)\n"choice: "(set_color normal)' n
end

$editor $files[$n]
