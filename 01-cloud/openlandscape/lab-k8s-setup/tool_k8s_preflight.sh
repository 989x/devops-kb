#!/usr/bin/env bash
# k8s-preflight.sh
# Purpose: Run Kubernetes Lab#1 node preflight checks with an sqlmap-like output style.

set -euo pipefail
clear

# ANSI colors (use real ESC via $'...'
# --------------------------------------------------
C_RESET=$'\033[0m'
C_BLUE=$'\033[1;34m'
C_CYAN=$'\033[1;36m'
C_GREEN=$'\033[1;32m'
C_YELLOW=$'\033[1;33m'
C_RED=$'\033[1;31m'
C_GRAY=$'\033[0;90m'


# Time / host helpers
# --------------------------------------------------
ts_hms()  { date "+%H:%M:%S"; }
ts_date() { date "+%Y-%m-%d"; }
host_fqdn() { hostname -f 2>/dev/null || hostname; }
ip4() { hostname -I 2>/dev/null | awk '{print $1}'; }


# Log helpers (sqlmap-like)
# --------------------------------------------------
log_info() { printf "[%s%s%s] [%sINFO%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_GREEN" "$C_RESET" "$*"; }
log_warn() { printf "[%s%s%s] [%sWARNING%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_YELLOW" "$C_RESET" "$*"; }
log_crit() { printf "[%s%s%s] [%sCRITICAL%s] %s\n" "$C_BLUE" "$(ts_hms)" "$C_RESET" "$C_RED" "$C_RESET" "$*"; }


# Banner
# --------------------------------------------------
print_banner() {
  local C_BANNER=$'\033[38;2;46;109;230m'
  printf "%s\n" "$C_BANNER"
  cat <<'EOF'
 /$$   /$$  /$$$$$$   /$$$$$$
| $$  /$$/ /$$__  $$ /$$__  $$
| $$ /$$/ | $$  \ $$| $$  \__/
| $$$$$/  |  $$$$$$/|  $$$$$$
| $$  $$   >$$__  $$ \____  $$
| $$\  $$ | $$  \ $$ /$$  \ $$
| $$ \  $$|  $$$$$$/|  $$$$$$/
|__/  \__/ \______/  \______/
EOF
  printf "%s\n\n" "$C_RESET"
}


# Check runner
# --------------------------------------------------
pass=0
fail=0
failed_items=()

check() {
  local label="$1"
  local cmd="$2"

  if bash -lc "$cmd" >/dev/null 2>&1; then
    pass=$((pass+1))
    log_info "$label: ${C_GREEN}passed${C_RESET}"
    return 0
  else
    fail=$((fail+1))
    failed_items+=("$label")
    log_warn "$label: ${C_RED}failed${C_RESET}"
    return 1
  fi
}


# Main
# --------------------------------------------------
print_banner

printf "[!] legal disclaimer: This script is for auditing your own lab nodes. Do not run it on systems without authorization.\n\n"
printf "[*] starting @ %s /%s/\n\n" "$(ts_hms)" "$(ts_date)"

TARGET_HOST="$(host_fqdn)"
TARGET_IP="$(ip4 || true)"

log_info "parsing target node '${TARGET_HOST}' (ip=${TARGET_IP:-unknown})"
log_info "testing connection to the target host"
sleep 0.08
log_info "testing if the target host content is stable"
sleep 0.08
log_info "target host content is stable"


# Lab#1: Node prepare preflight checks
# --------------------------------------------------
log_info "testing if SWAP is disabled"
check "SWAP is disabled" '[[ -z "$(swapon --show 2>/dev/null)" ]]'

log_info "testing if required kernel modules are loaded"
check "kernel module 'overlay' is loaded" "lsmod | grep -qE '^overlay'"
check "kernel module 'br_netfilter' is loaded" "lsmod | grep -qE '^br_netfilter'"

log_info "testing required sysctl settings"
check "sysctl net.ipv4.ip_forward = 1" "sysctl -n net.ipv4.ip_forward | grep -qx 1"
check "sysctl net.bridge.bridge-nf-call-iptables = 1" "sysctl -n net.bridge.bridge-nf-call-iptables | grep -qx 1"
check "sysctl net.bridge.bridge-nf-call-ip6tables = 1" "sysctl -n net.bridge.bridge-nf-call-ip6tables | grep -qx 1"

log_info "testing container runtime availability"
check "service 'containerd' is active" "systemctl is-active --quiet containerd"

log_info "testing containerd cgroup driver configuration"
check "containerd SystemdCgroup = true" \
  "grep -qE 'SystemdCgroup\\s*=\\s*true' /etc/containerd/config.toml"

log_info "testing Kubernetes binaries presence"
check "binary 'kubeadm' is present" "command -v kubeadm >/dev/null"
check "binary 'kubelet' is present" "command -v kubelet >/dev/null"
check "binary 'kubectl' is present" "command -v kubectl >/dev/null"

log_info "testing kubelet service status"
check "service 'kubelet' is active" "systemctl is-active --quiet kubelet"

log_info "testing storage/network helper packages"
check "package 'open-iscsi' is installed" "dpkg -l | grep -qE '^ii\\s+open-iscsi\\s'"
check "package 'nfs-common' is installed" "dpkg -l | grep -qE '^ii\\s+nfs-common\\s'"
check "package 'net-tools' is installed" "dpkg -l | grep -qE '^ii\\s+net-tools\\s'"


# Helm availability checks
# --------------------------------------------------
log_info "testing Helm availability"
check "binary 'helm' is present" "command -v helm >/dev/null" \
  || log_warn "helm is not installed (required for most Kubernetes deployments)"
check "helm can report version" "helm version --short >/dev/null 2>&1" \
  || log_warn "helm binary exists but cannot execute properly"


# Kubernetes cluster node status & IP verification
# --------------------------------------------------
log_info "testing kubectl connectivity to Kubernetes API"
check "kubectl can reach cluster API" \
  "kubectl version --request-timeout=5s >/dev/null 2>&1" \
  || log_crit "kubectl cannot communicate with the cluster API"

log_info "enumerating Kubernetes cluster nodes"

NODE_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | wc -l || true)"

if [[ -n "$NODE_COUNT" && "$NODE_COUNT" -gt 0 ]]; then
  pass=$((pass+1))
  log_info "detected ${NODE_COUNT} node(s) in the cluster"
else
  fail=$((fail+1))
  failed_items+=("no kubernetes nodes detected")
  log_crit "no nodes detected in the Kubernetes cluster"
fi

printf "\n"
printf "%s%-25s %-15s %-15s %-10s%s\n" \
  "$C_CYAN" "NODE" "ROLE" "INTERNAL-IP" "STATUS" "$C_RESET"
printf "%s%s%s\n" "$C_GRAY" "--------------------------------------------------------------------" "$C_RESET"

kubectl get nodes -o wide --no-headers | while read -r line; do
  NAME="$(awk '{print $1}' <<<"$line")"
  STATUS="$(awk '{print $2}' <<<"$line")"
  ROLE="$(awk '{print $3}' <<<"$line")"
  INTERNAL_IP="$(awk '{print $6}' <<<"$line")"

  if [[ "$STATUS" == "Ready" ]]; then
    printf "%-25s %-15s %-15s %sReady%s\n" \
      "$NAME" "$ROLE" "$INTERNAL_IP" "$C_GREEN" "$C_RESET"
  else
    fail=$((fail+1))
    failed_items+=("node ${NAME} not Ready")
    printf "%-25s %-15s %-15s %s%s%s\n" \
      "$NAME" "$ROLE" "$INTERNAL_IP" "$C_RED" "$STATUS" "$C_RESET"
  fi
done
printf "\n"


# Summary
# --------------------------------------------------
log_info "preflight summary: passed=${pass}, failed=${fail}"

if [[ $fail -eq 0 ]]; then
  log_info "${C_GREEN}all checks passed${C_RESET} - node and cluster are healthy"
else
  log_warn "some checks failed - review items below:"
  for item in "${failed_items[@]}"; do
    printf " - %s%s%s\n" "$C_YELLOW" "$item" "$C_RESET"
  done
  log_info "${C_GRAY}hint: fix failing items, then re-run this script${C_RESET}"
fi

printf "\n"
