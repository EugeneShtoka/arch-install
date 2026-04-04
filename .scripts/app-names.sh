#!/bin/zsh
# Shared app display name mapping
# Source this file; use APP_NAMES_JQ for jq calls, app_display_name() for shell

APP_NAMES_JQ='{"Vivaldi-stable":"Web browser","NeoMutt":"Email","Yazi":"File browser","ticker":"Stocks","BeeperTexts":"Messenger"}'

app_display_name() {
  case "$1" in
    "Vivaldi-stable") echo "Web browser" ;;
    "NeoMutt")        echo "Email" ;;
    "Yazi")           echo "File browser" ;;
    "ticker")         echo "Stocks" ;;
    "BeeperTexts")    echo "Messenger" ;;
    *)                echo "$1" ;;
  esac
}
