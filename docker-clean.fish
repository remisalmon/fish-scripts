#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo 'usage: docker-clean \'regex\''
    exit 1
end

set REGEX "$argv[1]"

set IDS (
    docker images \
    | string match -e -i -r $REGEX \
    | string replace -a -r ' +' ' ' \
    | string split -f 3 ' '
)

if test -z "$IDS"
    echo 'No images found'
    exit 0
end

docker image rm $IDS
