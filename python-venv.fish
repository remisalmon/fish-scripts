#!/usr/bin/env fish

alias python python3.8

if test (count $argv) -eq 0
    set VENV "venv"
else
    set VENV "$argv[1]"
end

python -m venv $VENV

source {$VENV}/bin/activate.fish

python -m pip install -U pip setuptools

if test -e requirements.txt
    python -m pip install -r requirements.txt
end
