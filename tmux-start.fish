#!/usr/bin/env fish

set SESSION "tmux"

tmux has-session -t $SESSION 2> /dev/null && exit 1

tmux new-session -s $SESSION -n "base" -d

#tmux new-window -t $SESSION -n "window-name" -c window/path

#tmux send-key -t $SESION:"window-name" "command" Enter

tmux set-option -t $SESSION -g mouse on

tmux select-window -t $SESSION:"base"

tmux attach-session -t $SESSION
