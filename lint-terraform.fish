#!/usr/bin/env fish

terraform fmt || exit 1
terraform validate
