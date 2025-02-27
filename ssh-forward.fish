#!/usr/bin/env fish

if test (count $argv) -ne 2
    echo "usage: ssh-forward.fish host port"

    exit 1
end

function kill_exit -s INT
    kill -s KILL $ssh_pid

    exit 0
end

set -l host $argv[1]
set -l port $argv[2]

ssh -N -L {$port}:localhost:{$port} $host &

set -g ssh_pid $last_pid

sleep 1s

open http://localhost:{$port}

while true
    if not jobs -q $ssh_pid
        echo "ssh job "$ssh_pid" is dead (RIP)"

        exit 1
    end

    sleep 1s
end
