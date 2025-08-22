#!/usr/bin/env fish

if test (count $argv) -eq 0
    set file "script.py"
else
    set file $argv[1]
end

if test -e $file
    echo $file" already exists"
    exit 1
end

echo -n "\
#!/usr/bin/env python

# imports

# globals

# functions

# classes


# main
def main():
    return


if __name__ == \"__main__\":
    main()
" > $file
