#!/usr/bin/env fish

git add --patch || exit 1
git status --short
git diff --staged --quiet && exit 0

read -P "commit [y/N]? " a

string match -q -i $a y || exit 0

git diff --staged | /opt/local/bin/claude -p "git commit with a one line lowercase message starting with a capitalized action verb - ignore all unstaged and untracked changes - add yourself as co author"
git show --stat
