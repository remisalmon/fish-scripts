#!/usr/bin/env fish

set data (cat -s - | string trim -r | string collect)

switch (path extension $MICRO_FILE)
    case ".go"
        echo $data | gofmt

    case ".fish"
        echo $data | fish_indent

    case ".json" ".jsonl"
        echo $data | jq

    case ".py"
        # echo $data | black -
        echo $data | isort - | black -

    case ".sql"
        if string match -q -e dbt (pwd)
            cd (git rev-parse --show-toplevel)

            source dbt_venv/bin/activate.fish

            set TMP_FILE (path change-extension "" $MICRO_FILE)_tmp.sql

            echo $data >$TMP_FILE

            sqlfluff fix $TMP_FILE >/dev/null

            set code $status

            cat $TMP_FILE && rm -f $TMP_FILE

            exit $code
        else
            echo $data | sqlfluff format -
        end

    case ".tf" ".tfvars" ".tfbackend"
        echo $data | terraform fmt -

    case ".yaml" ".yml"
        echo $data | yamlfmt -

    case "*"
        echo $data
end
