#!/usr/bin/env fish

set commands "
sudo dnf upgrade
sudo dnf autoremove

flatpak update
flatpak uninstall --unused

# conda update --all
# conda clean --all

pipx upgrade-all --include-injected
"

for i in (string join -n \n (echo $commands) | string match -v -r "^#")
    echo (set_color blue)"[eval] "$i(set_color normal)
    eval $i
end
