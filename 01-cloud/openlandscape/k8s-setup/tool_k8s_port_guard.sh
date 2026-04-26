#!/usr/bin/env bash
# lb-port-preflight.sh
# Purpose: Display listening ports and validate port ownership safety
# Scope  : Runtime inspection using kernel socket state (NOT config-based)
# Author : Platform / SRE Team

set -euo pipefail
clear


# Root enforcement
# --------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "[CRITICAL] This script must be run as root."
  echo "           Re-run with: sudo $0"
  exit 1
fi


# ANSI colors
# --------------------------------------------------
C_RESET=$'\033[0m'
C_BLUE=$'\033[1;34m'
C_CYAN=$'\033[1;36m'
C_GREEN=$'\033[1;32m'
C_YELLOW=$'\033[1;33m'
C_RED=$'\033[1;31m'
C_GRAY=$'\033[0;90m'


# Time helpers
# --------------------------------------------------
ts_hms()  { date "+%H:%M:%S"; }
ts_date() { date "+%Y-%m-%d"; }


# Logging helpers
# --------------------------------------------------
log_info() { printf "[%s%s%s] [%sINFO%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_GREEN" "$C_RESET" "$*"; }
log_warn() { printf "[%s%s%s] [%sWARNING%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_YELLOW" "$C_RESET" "$*"; }
log_fail() { printf "[%s%s%s] [%sFAIL%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_RED" "$C_RESET" "$*"; }


# Banner
# --------------------------------------------------
print_banner() {
  local C_BANNER=$'\033[38;2;255;165;0m'
  printf "%s\n" "$C_BANNER"
  cat <<'EOF'
 _      ____    ____            ____            _
| |    |  _ \  |  _ \ ___  _ __|  _ \ ___  _ __| |_
| |    | |_) | | |_) / _ \| '__| |_) / _ \| '__| __|
| |___ |  __/  |  __/ (_) | |  |  __/ (_) | |  | |_
|_____ |_|     |_|   \___/|_|  |_|   \___/|_|   \__|
EOF
  printf "%s\n\n" "$C_RESET"
}


# Machine identity (runtime, OS-sourced)
# --------------------------------------------------
HOSTNAME_FQDN="$(hostname -f 2>/dev/null || hostname)"
PRIMARY_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"
[[ -z "$PRIMARY_IP" ]] && PRIMARY_IP="unknown"


# Critical ports (policy)
# --------------------------------------------------
declare -A CRITICAL_PORTS=(
  [22]="SSH"
  [53]="DNS"
  [80]="HTTP (Public)"
  [443]="HTTPS (Public)"
  [6443]="Kubernetes API"
)


# Counters
# --------------------------------------------------
PASS_COUNT=0
FAIL_COUNT=0
FAILED_ITEMS=()


# Main
# --------------------------------------------------
print_banner

printf "[!] Legal notice: This script inspects kernel-level socket state on systems you own.\n"
printf "[!] Inspection source: OS runtime (ss / kernel sockets), NOT application configs.\n\n"

printf "[*] Hostname : %s\n" "$HOSTNAME_FQDN"
printf "[*] Node IP  : %s\n" "$PRIMARY_IP"
printf "[*] Date     : %s\n" "$(ts_date)"
printf "[*] Time     : %s\n\n" "$(ts_hms)"

log_info "collecting listening sockets from OS kernel (runtime inspection)"
sleep 0.1
printf "\n"


# Table header
# --------------------------------------------------
printf "%s%-6s %-7s %-8s %-22s %-20s%s\n" \
  "$C_CYAN" "PROTO" "PORT" "PID" "PROCESS" "NOTE" "$C_RESET"

printf "%s%s%s\n" \
  "$C_GRAY" "----------------------------------------------------------------------" "$C_RESET"


# Print listeners (runtime sockets)
# --------------------------------------------------
ss -lntup | tail -n +2 | while read -r line; do
  PROTO="$(awk '{print $1}' <<<"$line")"
  LOCAL_ADDR="$(awk '{print $5}' <<<"$line")"
  PORT="${LOCAL_ADDR##*:}"

  PROC_BLOCK="$(sed -n 's/.*users:(\(.*\))/\1/p' <<<"$line")"
  PID="$(sed -n 's/.*pid=\([0-9]*\).*/\1/p' <<<"$PROC_BLOCK")"
  PROC_NAME="$(sed -n 's/.*"\([^"]*\)".*/\1/p' <<<"$PROC_BLOCK")"

  [[ -z "$PID" ]] && PID="-"
  [[ -z "$PROC_NAME" ]] && PROC_NAME="-"

  NOTE="${CRITICAL_PORTS[$PORT]:-}"

  printf "%-6s %-7s %-8s %-22s %-20s\n" \
    "$PROTO" "$PORT" "$PID" "$PROC_NAME" "$NOTE"
done

printf "\n"


# Safety analysis (policy vs runtime)
# --------------------------------------------------
log_info "evaluating port safety against runtime state"

for port in "${!CRITICAL_PORTS[@]}"; do
  LISTENERS="$(ss -lntp | grep -w ":$port" | wc -l || true)"

  if [[ "$LISTENERS" -gt 1 ]]; then
    FAIL_COUNT=$((FAIL_COUNT+1))
    FAILED_ITEMS+=("port $port has multiple active listeners (${CRITICAL_PORTS[$port]})")
    log_fail "port $port has multiple active listeners (${CRITICAL_PORTS[$port]})"
  else
    PASS_COUNT=$((PASS_COUNT+1))
    log_info "port $port listener count OK (${CRITICAL_PORTS[$port]})"
  fi
done


# Summary
# --------------------------------------------------
printf "\n"
log_info "preflight summary on ${HOSTNAME_FQDN} (${PRIMARY_IP}): passed=${PASS_COUNT}, failed=${FAIL_COUNT}"

if [[ "$FAIL_COUNT" -eq 0 ]]; then
  log_info "${C_GREEN}preflight PASSED${C_RESET} - no runtime port conflicts detected"
  exit 0
else
  log_fail "preflight FAILED - runtime conflicts detected:"
  for item in "${FAILED_ITEMS[@]}"; do
    printf " - %s%s%s\n" "$C_RED" "$item" "$C_RESET"
  done
  exit 1
fi
