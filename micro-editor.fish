#!/usr/bin/env fish

set -x MICRO_FILE $argv[-1]

test (uname -s) = Linux && /usr/bin/micro $argv
test (uname -s) = Darwin && /opt/local/bin/micro $argv
