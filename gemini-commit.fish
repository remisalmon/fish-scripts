#!/usr/bin/env fish

git add --patch
git status --short

set git_diff (git diff --staged | string collect)

test -z $git_diff && exit 0

read -P "commit [y/N]? " a

string match -q -i $a y || exit 0

set git_message (echo $git_diff | gemini-api.fish "summarize this git diff in a one line lowercase commit message starting with a capitalized action verb" | string collect)

test -z $git_message && exit 1

git commit --message $git_message --message "Co-authored-by: gemini-code-assist <gemini-code-assist@users.noreply.github.com>" --edit
git show --stat
