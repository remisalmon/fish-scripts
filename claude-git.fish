#!/usr/bin/env fish

git add --update || exit 1

cd (git rev-parse --show-toplevel)

set system_prompt "use git rm, git mv, git grep instead of rm, mv, grep with the bash tool"

/opt/local/bin/claude --append-system-prompt $system_prompt $argv
