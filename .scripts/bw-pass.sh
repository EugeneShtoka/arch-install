#!/bin/zsh

bw get item $1 | jq '.login.password' |  tr -d \"
