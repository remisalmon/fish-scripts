#!/usr/bin/env fish

nano (git ls-files | string match -m 1 -e $argv[1] || true)
