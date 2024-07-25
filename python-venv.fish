#!/usr/bin/env fish

set python_version "3.11"

if test (count $argv) -eq 0
    set venv_name "venv"
else
    set venv_name $argv[1]
end

python{$python_version} -m venv $venv_name

source {$venv_name}/bin/activate.fish || exit 1

python -m pip install -U pip setuptools

if test -e requirements.txt
    python -m pip install -r requirements.txt
end
