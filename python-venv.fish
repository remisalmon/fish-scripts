#!/usr/bin/env fish

set version "3.11"

if test (count $argv) -eq 0
    set venv "venv"
else
    set venv $argv[1]
end

python{$version} -m venv $venv

source {$venv}/bin/activate.fish

python -m pip install -U pip setuptools

if test -e requirements.txt
    python -m pip install -r requirements.txt
end
