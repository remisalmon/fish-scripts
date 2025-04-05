#!/usr/bin/env fish

if test (count $argv) -ne 2
    echo "usage: ssh-forward.fish host port"

    exit 1
end

set -g host $argv[1]
set -g port $argv[2]

function run_ssh
    ssh -N -L {$port}:localhost:{$port} $host &

    set -g ssh_pid $last_pid
end

function kill_ssh -s INT
    kill -s KILL $ssh_pid

    exit 0
end

run_ssh

sleep 1s

open http://localhost:{$port}

while true
    if not jobs -q $ssh_pid
        run_ssh
    end

    sleep 1s
end
