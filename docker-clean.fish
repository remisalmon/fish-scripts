#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo "usage: docker-clean.fish regex"
    exit 1
end

set IMAGES (
    docker images \
    | string match -e -r $argv[1] \
    | string replace -a -r " +" " " \
    | string split -f 3 " "
)

if test -z "$IMAGES"
    echo "no images found"
    exit 0
end

docker image rm $IMAGES
