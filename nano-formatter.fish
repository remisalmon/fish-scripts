#!/usr/bin/env fish

set file $argv[1]

echo (cat $file | string trim -r | string collect) >$file

switch $file
    case "*.fish"
        fish_indent -w $file

    case "*.go"
        gofmt -w $file

    case "*.hcl"
        # terraform fmt $file
        # fails with "Error: Only .tf, .tfvars, and .tftest.hcl files can be processed with terraform fmt"

        # workaround for nano formatter renaming .tftest.hcl files to .hcl in /private/var/folders
        mv $file {$file}.tftest.hcl
        terraform fmt {$file}.tftest.hcl
        set code $status
        mv {$file}.tftest.hcl $file
        exit $code

    case "*.json" "*.jsonl"
        echo (jq . $file | string collect) >$file

    case "*.lkml"
        ~/Work/GitHub/remisalmon/lkmlfmt/venv/bin/lkmlfmt $file

    case "*.py"
        isort $file && black $file

    case "*.sql"
        if string match -q -r ".*snowflake-dbt" (pwd)
            # echo (cat $file | sqlfluff format --stdin-filename (pwd) - | string collect) >$file
            # fails with "Error loading config: Requested templater 'dbt' which is not currently available. Try one of raw, jinja, python,placeholder"

            # echo (cat $file | sqlfluff format --stdin-filename (pwd) --templater jinja --ignore templating - | string collect) >$file
            # works but not great with some dbt macros

            cd (string match -r ".*snowflake-dbt" (pwd))
            source dbt_venv/bin/activate.fish
            set -lx SNOWFLAKE_ACCOUNT $SNOWFLAKE_ACCOUNT_PRODUCTION

            # echo (cat $file | sqlfluff format --stdin-filename (pwd) - | string collect) >$file
            # fails with "User Error: The dbt templater does not support stdin input, provide a path instead"

            # workaround for nano formatter using tempory files in /private/var/folders
            cp $file models/(basename $file)
            sqlfluff fix --quiet models/(basename $file)
            set code $status
            mv models/(basename $file) $file
            exit $code
        else
            echo (cat $file | sqlfluff format --stdin-filename (pwd) - | string collect) >$file
        end

    case "*.tf" "*.tfvars"
        terraform fmt $file

    case "*.yaml" "*.yml"
        yamlfmt $file
end
