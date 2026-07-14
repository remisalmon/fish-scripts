#!/usr/bin/env fish

cd (status dirname)

ln -f -v -s gemini-api.fish gemini
ln -f -v -s micro-editor.fish micro

if test (uname -s) = Linux
    ln -f -v -s (pwd)/update-linux.fish ~/update.fish
else
    ln -f -v -s (pwd)/update-mac.fish ~/update.fish
end
