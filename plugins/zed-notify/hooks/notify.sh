#!/bin/bash
set -euo pipefail

# Called by terminal-notifier -execute on notification click
if [[ "${1:-}" == "--focus" ]]; then
  project_dir="${2:-}"
  if [[ -n "$project_dir" ]]; then
    /usr/local/bin/zed "$project_dir"
  fi
  exit 0
fi

# Check if the user is focused on the specific project window in Zed
is_focused_on_project() {
  local proj="$1"
  # Fast path: check if Zed is frontmost (~10ms, no permissions needed)
  local front_app
  front_app=$(lsappinfo info -only name -app "$(lsappinfo front)" 2>/dev/null) || return 1
  [[ "$front_app" == *'"Zed"'* ]] || return 1
  # Slow path: check focused window title via Accessibility (~150ms, needs permission)
  local win_title
  win_title=$(osascript -e 'tell application "System Events"
    set zedProc to first application process whose name is "Zed"
    get name of (value of attribute "AXFocusedWindow" of zedProc)
  end tell' 2>/dev/null) || return 1
  [[ "$win_title" == *"$proj"* ]]
}

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')
notif_type=$(echo "$input" | jq -r '.notification_type // empty')
message=$(echo "$input" | jq -r '.message // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

project_dir="${cwd:-${PWD:-}}"
project=$(basename "${project_dir:-unknown}")

title="Claude Code"
subtitle=""
body=""
sound=""

case "$hook_event" in
  Stop)
    subtitle="Task Complete"
    sound="Hero"
    body="$project"
    ;;
  Notification)
    case "$notif_type" in
      permission_prompt)
        subtitle="Permission Needed"
        sound="Ping"
        body="${message:-Approve tool use in $project}"
        ;;
      idle_prompt)
        subtitle="Waiting for Input"
        sound="Glass"
        body="${message:-Claude is idle in $project}"
        ;;
      elicitation_dialog)
        subtitle="Input Required"
        sound="Ping"
        body="${message:-MCP tool needs input in $project}"
        ;;
      *)
        subtitle="Notification"
        sound="Ping"
        body="${message:-$project}"
        ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac

# Truncate body for notification display
body="${body:0:200}"

self="$(realpath "${BASH_SOURCE[0]}")"

# Suppress if user is already focused on this project's window
if is_focused_on_project "$project"; then
  exit 0
fi

if command -v terminal-notifier &>/dev/null; then
  terminal-notifier \
    -title "$title" \
    -subtitle "$subtitle" \
    -message "$body" \
    -sound "$sound" \
    -execute "$self --focus '$project_dir'" \
    -group "claude-code-${project}"
else
  osascript -e "display notification \"$body\" with title \"$title\" subtitle \"$subtitle\" sound name \"$sound\""
fi

exit 0
