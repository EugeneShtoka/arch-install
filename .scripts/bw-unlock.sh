#!/bin/zsh

bw_status=$(bw status | jq '.status' | tr -d \")
if [[ "$bw_status" == "locked" ]]; then
  export BW_SESSION=$(bw unlock | grep '$ export' | awk -F'BW_SESSION=' '{print $2}')
fi