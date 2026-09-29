#!/usr/bin/env fish

cd (status dirname)

chmod +x *.fish

ln -f -v -s claude-git.fish claude
ln -f -v -s gemini-api.fish gemini
ln -f -v -s micro-editor.fish micro
ln -f -v -s (pwd)/update-all.fish ~/update.fish
