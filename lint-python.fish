#!/usr/bin/env fish

isort --gitignore . && black . || exit 1

# see https://flake8.pycqa.org/en/latest/user/options.html
flake8 \
    --extend-exclude="*venv/,.terraform/,archive*/,repos/" \
    --extend-ignore="E1,E2,E3,E4,E5,E7,W" \
    --require-plugins="flake8-bugbear" \
    .
