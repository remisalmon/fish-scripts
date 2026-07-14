#!/usr/bin/env fish

source ~/.env

echo -n $OKTA_PASSWORD | pbcopy

if test (uname -s) = Linux
    set commands "
    sudo dnf upgrade
    sudo dnf autoremove

    flatpak update
    flatpak uninstall --unused

    # conda update --all
    # conda clean --all

    pipx upgrade-all --include-injected
    "
else if test (uname -s) = Darwin
    set commands "
    # test

    sudo port selfupdate
    sudo port upgrade outdated
    sudo port reclaim

    conda activate base
    conda update --all

    conda activate spyder
    conda list > pre.txt
    conda env update --file ~/Work/Python/conda_spyder.yml --prune
    conda list > post.txt; diff pre.txt post.txt; rm -f pre.txt post.txt

    conda activate hotelengine
    conda list > pre.txt
    conda env update --file ~/Work/Python/conda_hotelengine.yml --prune
    conda list > post.txt; diff pre.txt post.txt; rm -f pre.txt post.txt

    conda clean --all --yes

    pipx upgrade-all --include-injected

    podman machine start && touch pms.txt
    podman machine os upgrade
    podman system prune

    test -e pms.txt && podman machine stop; rm -rf pms.txt

    rm -r -f -v ~/airflow/
    rm -r -f -v ~/__pycache__/
    "
end

for i in (echo $commands | string join -n \n | string match -v -r "^ *#")
    echo (set_color blue)"[eval] "$i(set_color normal)
    eval $i
end
