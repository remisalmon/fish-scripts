#!/usr/bin/env fish

git rev-parse || exit 1

set git_branch (git rev-parse --abbrev-ref origin/HEAD | string replace origin/ "")
set git_diff (git diff --staged --merge-base $git_branch | string collect)

test -z $git_diff && exit 0

echo $git_diff | claude-git.fish -p "review this git diff for logic bugs - summarize potential logic bugs as low or medium or high severity with 3 lines of code for context" # see https://cursor.com/bugbot
