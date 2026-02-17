#!/usr/bin/env fish

set data (cat -s - | string trim -r | string collect)

switch (path extension $MICRO_FILE)
    case ".fish"
        echo $data | fish_indent

    case ".go"
        echo $data | gofmt

    case ".json" ".jsonl"
        echo $data | jq

    case ".py"
        echo $data | black -

    case ".sql"
        echo $data | sqlfluff format -

    case ".tf" ".tfvars" ".tfbackend"
        echo $data | terraform fmt -

    case ".yaml" ".yml"
        echo $data | yamlfmt -

    case "*"
        echo $data
end
