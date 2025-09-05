#!/usr/bin/env fish

if not git rev-parse
    exit 1
end

set log "/tmp/git-open-"(basename (git rev-parse --show-toplevel))".log"
set editor (git config get core.editor)

# files with name match
set files (git ls-files | string match -i -e (string join "*" $argv))

# files with content match
if test (count $files) -eq 0
    set files (git grep -i -l (string join ".*" $argv))
end

set files (echo -s -n $files\n | grep -v -i -E "(archives|artifacts)/")

if test (count $files) -eq 0
    exit 1

else if test (count $files) -eq 1
    $editor $files[1]

else
    if not test -e $log
        or test (git log --oneline --max-count=1 | string split -f 1 " ") != (head -n 1 $log | string split -f 1 " ")
        git log --oneline --name-only >$log
    end

    set data

    for file in $files
        set n (string match -g -r "(^|/)"(basename $file) < $log | count) # is (grep -E "(^|/)"(basename $file) $log | count)
        set -a data $n" "$file
    end

    echo -s -n $data\n | sort -n -r & # debug

    $editor (echo -s -n $data\n | sort -n -r | head -n 1 | string split -f 2 " ")
end
