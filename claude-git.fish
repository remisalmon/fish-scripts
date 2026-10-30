#!/usr/bin/env fish

git add --update || exit 1

cd (git rev-parse --show-toplevel)

set system_prompt "use git rm, git mv, git grep instead of rm, mv, grep with the bash tool"

set allowed_tools (string join "," \
    "Edit(./**)" \
    "Read(./**)" \
    "Bash(git diff *),Bash(git grep *),Bash(git log *),Bash(git ls-files *),Bash(git mv *),Bash(git rm *),Bash(git status *),Bash(git show *)" \
    "Bash(ls *)" \
    "Bash(mkdir *)" \
    "Bash(pyflakes *)" \
    "Bash(terraform validate *)" \
)

/opt/local/bin/claude \
    --model claude-opus-5-5 \
    --permission-mode dontAsk \
    --append-system-prompt $system_prompt \
    --allowed-tools $allowed_tools \
    $argv
