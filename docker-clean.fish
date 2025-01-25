#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo "usage: docker-clean.fish regex"
    exit 1
end

set IMAGES (docker image ls | string match -e -r $argv[1])

if test (count $IMAGES) -eq 0
    echo "no images found"
    exit 0
end

echo -s {$IMAGES}\n

read -P "clean [y/n]? " promt

if string match -q -i "y" $promt
    docker image rm -f (echo -s -n {$IMAGES}\n | string replace -a -r " +" " " | string split -f 3 " ")
end
