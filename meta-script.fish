#!/usr/bin/env fish

if not test -e gemini
    ln -v -s gemini-cli.fish gemini
end

if not test -e micro
    ln -v -s micro-editor.fish micro
end
