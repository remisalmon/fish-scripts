#!/usr/bin/env fish

set PYTHON_VERSION "3.8"

if test (count $argv) -eq 0
    set VENV "venv"
else
    set VENV $argv[1]
end

python{$PYTHON_VERSION} -m venv $VENV

source {$VENV}/bin/activate.fish

python -m pip install -U pip setuptools

if test -e requirements.txt
    python -m pip install -r requirements.txt
end
