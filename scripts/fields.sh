#!/usr/bin/env bash

fields() {
  awk -F "${2:- }" "{ print \$${1:-1} }"
}

export -f fields
