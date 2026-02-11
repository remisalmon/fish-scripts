#!/usr/bin/env fish

if not set -q argv[1]
    echo "usage: docker-clean.fish regex" && exit 1
end

command -q podman && set command podman || set command docker

set images ($command image ls | string match -e -r '^[^ ]*'$argv[1])

if test (count $images) -eq 0
    echo "no images found" && exit 0
end

$command image ls | head -n 1

string join \n $images

read -p 'echo \n"REMOVE [y/N]? "' a

if string match -q -i y $a
    for image in (string join \n $images | string replace -a -r " +" " " | string split -f 3 " " | uniq)
        $command image rm -f $image
    end
end
