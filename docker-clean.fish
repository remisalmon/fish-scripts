#!/usr/bin/env fish

if not set -q argv[1]
    echo "usage: docker-clean.fish regex" && exit 1
end

set IMAGES (docker image ls | string match -e -r "^[^ ]*"$argv[1])

if test (count $IMAGES) -eq 0
    echo "no images found" && exit 0
end

docker image ls | head -n 1

echo -s {$IMAGES}\n

read -P "clean [y/N]? " a

if string match -q -i y $a
    docker image rm -f (echo -s -n {$IMAGES}\n | string replace -a -r " +" " " | string split -f 3 " ")
end
