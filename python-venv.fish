#!/usr/bin/env fish

alias python python3.8

python -m venv venv

source venv/bin/activate.fish

python -m pip install -U pip setuptools

if test -e requirements.txt
    python -m pip install -r requirements.txt
end
