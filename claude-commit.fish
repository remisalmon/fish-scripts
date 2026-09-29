#!/usr/bin/env fish

git add --patch
git status --short
git diff --staged --quiet && exit 0

read -P "commit [y/N]? " a

string match -q -i $a y || exit 0

claude -p "git commit the staged changes with a one line lowercase message starting with a capitalized action verb - ignore all unstaged and untracked changes - add yourself as co author"

git show --stat
