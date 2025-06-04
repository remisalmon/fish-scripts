#!/usr/bin/env fish

# Option 1
# set pipe ""
# while read line
#     set pipe {$pipe}{$line}"\n"
# end

# Option 2
# set pipe (read -z | string join "\n")

# Option 3
# set pipe (cat | string join "\n")

# Option 4 (also works with no pipe)
set pipe (timeout 0.5s cat | string join "\n" || echo "")

echo "argv="(string join " " $argv)
echo "pipe="$pipe
