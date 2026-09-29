#!/usr/bin/env fish

git add --update || exit 1

set system_prompt "use git rm and git mv instead of bash rm and bash mv to remove or rename files"

/opt/local/bin/claude --append-system-prompt $system_prompt $argv
