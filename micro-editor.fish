#!/usr/bin/env fish

set -x MICRO_FILE $argv[-1]

if test (uname -s) = Linux
    /usr/bin/micro $argv
else
    /opt/local/bin/micro $argv
end
