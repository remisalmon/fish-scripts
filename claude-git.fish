#!/usr/bin/env fish

git add --update || exit 1

set system_prompt "use git rm, git mv, git grep instead of rm, mv, grep in bash"

/opt/local/bin/claude --append-system-prompt $system_prompt $argv
