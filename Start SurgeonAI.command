#!/bin/zsh

set -u

project_dir=${0:A:h}
tmux_bin=/opt/homebrew/bin/tmux
npm_bin=/opt/homebrew/bin/npm
backend_session=surgeonai-demo-backend
frontend_session=surgeonai-demo-frontend

if [[ ! -x "$tmux_bin" || ! -x "$npm_bin" || ! -x "$project_dir/.venv/bin/python" ]]; then
  echo "SurgeonAI cannot start because tmux, npm, or the Python environment is missing."
  echo "Project: $project_dir"
  read -k 1 "?Press any key to close."
  exit 1
fi

# Replace only SurgeonAI sessions created by this launcher.
"$tmux_bin" kill-session -t "$backend_session" 2>/dev/null || true
"$tmux_bin" kill-session -t "$frontend_session" 2>/dev/null || true

for port in 5001 5173; do
  if /usr/sbin/lsof -nP -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Port $port is already in use. Double-click Stop SurgeonAI.command, then try again."
    read -k 1 "?Press any key to close."
    exit 1
  fi
done

echo "Starting SurgeonAI…"
"$tmux_bin" new-session -d -s "$backend_session" -c "$project_dir" \
  "$project_dir/.venv/bin/python backend/server.py"
"$tmux_bin" new-session -d -s "$frontend_session" -c "$project_dir/surgeon-hud" \
  "$npm_bin run dev -- --host 0.0.0.0"

ready=false
for attempt in {1..45}; do
  if /usr/bin/curl -fsS http://localhost:5001/health >/dev/null 2>&1 \
    && /usr/bin/curl -fsS http://localhost:5173/ >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 1
done

if [[ "$ready" != true ]]; then
  echo "SurgeonAI did not become ready. Stopping the partial launch."
  "$tmux_bin" kill-session -t "$backend_session" 2>/dev/null || true
  "$tmux_bin" kill-session -t "$frontend_session" 2>/dev/null || true
  read -k 1 "?Press any key to close."
  exit 1
fi

if [[ "${SURGEONAI_NO_OPEN:-false}" != true ]]; then
  /usr/bin/open http://localhost:5173/
fi
echo "SurgeonAI is ready. You can close this window."
echo "Use the in-app controls for session resets, or double-click Stop SurgeonAI.command to shut down everything."
