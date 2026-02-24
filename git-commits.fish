#!/usr/bin/env fish

set author (git config get user.email)
set pretty "%cs %s %b"
set commits

read -P "since [last Sunday]? " since

if test -z $since
    set since "last Sunday"
end

read -P "main/master branch only [Y/n]? " main

switch (string lower $main)
    case "" y
        set main true
    case n
        set main false
    case "*"
        exit 1
end

for git_repo in ~/Work/GitHub/HotelEngine/*/
    cd $git_repo

    if not git rev-parse
        continue
    end

    if $main
        set git_branch (git branch | string match -q -r "^[* ]+master\$" && echo "master" || echo "main")

        git fetch origin $git_branch

        set git_log (git log FETCH_HEAD --pretty={$pretty} --author={$author} --since={$since})
    else
        set git_log (git log --branches --pretty={$pretty} --author={$author} --since={$since})
    end

    for i in $git_log
        if test -n $i
            set -a commits (path basename $git_repo)": "$i
        end
    end
end

if test -z (string join "" $commits)
    echo -e "---\nno git commits..."
else
    echo -e "---\ngit commits:"

    string join \n $commits
end
