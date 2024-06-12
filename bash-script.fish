#!/usr/bin/env fish

if test (count $argv) -eq 0
    set file "script.sh"
else
    set file $argv[1]
end

if test -e $file
    echo $file" already exists"
    exit 1
end

echo -e "#!/usr/bin/env bash\n" > $file

chmod +x $file
