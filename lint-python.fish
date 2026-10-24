#!/usr/bin/env fish

isort --gitignore . && black . || exit 1

flake8 --config ~/.flake8 .
