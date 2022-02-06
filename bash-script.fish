#!/usr/bin/env fish

if test (count $argv) -eq 0
    set FILE "script.sh"
else
    set FILE "$argv[1]"
end

if test -e $FILE
    echo {$FILE}' already exists...'
    exit 1
end

echo -e '#!/usr/bin/env bash\n' > $FILE

chmod +x $FILE
