#!/usr/bin/env fish

set namespace (kubectl get namespaces -o name | string match -e "kafka" | string split "/" -f 2)
set service (kubectl get services -o name -n $namespace | string match -e "kafka-connect" | string split "/" -f 2)

kubectl port-forward -n $namespace service/{$service} 8083 &

set kubectl_pid $last_pid

set duckdb_query "
select
    je.key as connector,
    je.value->>'\$.status.connector.state' as state
from read_json('/dev/stdin') as j, json_each(j) as je
order by
    state desc,
    connector asc;
"

curl --silent --retry 3 --retry-all-errors -X GET http://localhost:8083/connectors?expand=status | duckdb -table -c $duckdb_query

kill $kubectl_pid
