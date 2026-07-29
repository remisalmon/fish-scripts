#!/usr/bin/env fish

set author (git config get user.email)
set pretty "%cs %s %b"
set commits

read -P "since [last Sunday]? " since

test -z $since && set since "last Sunday"

read -P "until [today]? " until

test -z $until && set until today

read -P "main/master branch only [Y/n]? " main

test -z $main && set main y

switch (string lower $main)
    case y
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
        set git_branch (git rev-parse --abbrev-ref origin/HEAD | string replace origin/ "")

        git fetch origin $git_branch

        set git_log (git log FETCH_HEAD --pretty={$pretty} --author={$author} --since={$since} --until={$until})
    else
        set git_log (git log --branches --pretty={$pretty} --author={$author} --since={$since}  --until={$until})
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
