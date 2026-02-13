#!/usr/bin/env fish

if test (count $argv) -gt 0
    set pattern "*"$argv"*"
else
    set pattern "*"
end

for file in (git ls-files $pattern)
    if not string match -q -i -r "text/.+" (file -i $file | string split -f 2 ":")
        continue
    else if string match -q -i -r "archives?/|artifacts?/" $file
        continue
    end

    echo -e "---\ncontent of "$file":\n---"

    cat -s $file
end
