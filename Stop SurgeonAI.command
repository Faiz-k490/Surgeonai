#!/bin/zsh

set -u

project_dir=${0:A:h}
tmux_bin=/opt/homebrew/bin/tmux

"$tmux_bin" kill-session -t surgeonai-demo-backend 2>/dev/null || true
"$tmux_bin" kill-session -t surgeonai-demo-frontend 2>/dev/null || true
"$tmux_bin" kill-session -t surgeai-demo-backend 2>/dev/null || true
"$tmux_bin" kill-session -t surgeai-demo-frontend 2>/dev/null || true

for port in 5001 5173; do
  for pid in $(/usr/sbin/lsof -tiTCP:$port -sTCP:LISTEN 2>/dev/null); do
    command_line=$(/bin/ps -p "$pid" -o command=)
    if [[ "$command_line" == *"backend/server.py"* || "$command_line" == *"$project_dir/surgeon-hud"* ]]; then
      /bin/kill "$pid" 2>/dev/null || true
    fi
  done
done

echo "All SurgeonAI backend and frontend instances are stopped."

