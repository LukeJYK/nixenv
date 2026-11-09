#!/usr/bin/env bash
# Build or switch this repo's darwin configs.
# The current mac is picked by login user: each hosts/<host>/default.nix sets
# system.primaryUser, and this script reads that line, so a user is written
# only once.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

declare -a hosts=()
for host_config in hosts/*/default.nix; do
  if [[ -f "$host_config" ]]; then
    hosts+=("$(basename -- "$(dirname -- "$host_config")")")
  fi
done

usage() {
  cat <<EOF
Usage:
  ./build.sh switch               build and switch this mac
  ./build.sh build                build this mac only, then show what would change
  ./build.sh build <host>...      build the given hosts
  ./build.sh build all            build every host
  ./build.sh update [input...]    update all flake inputs, or only the given ones
  ./build.sh help

Hosts: ${hosts[*]:-(none)}
EOF
}

usage_error() {
  printf 'error: %s\n\n' "$1" >&2
  usage >&2
  exit 2
}

# prints the system.primaryUser set in hosts/<host>/default.nix
user_of_host() {
  sed -n 's/^[[:space:]]*system\.primaryUser = "\([^"]*\)";.*$/\1/p' "hosts/$1/default.nix"
}

is_host() {
  local host
  for host in "${hosts[@]}"; do
    if [[ "$1" == "$host" ]]; then
      return 0
    fi
  done
  return 1
}

# prints the host whose primaryUser is the login user
current_host() {
  local me host
  me="$(id -un)"
  for host in "${hosts[@]}"; do
    if [[ "$(user_of_host "$host")" == "$me" ]]; then
      printf '%s\n' "$host"
      return 0
    fi
  done
  return 1
}

require_current_host() {
  if ! current_host; then
    usage_error "no host in hosts/ sets system.primaryUser = \"$(id -un)\"; add one for this mac"
  fi
}

build_hosts() {
  local -a targets=()
  local -a installables=()
  local host me out changes

  if (($# == 0)); then
    targets=("$(require_current_host)")
  elif [[ "$1" == "all" ]]; then
    if (($# != 1)); then
      usage_error "'all' must be the only build selector"
    fi
    targets=("${hosts[@]}")
  else
    for host in "$@"; do
      if ! is_host "$host"; then
        usage_error "unknown host '$host'"
      fi
      targets+=("$host")
    done
  fi

  for host in "${targets[@]}"; do
    installables+=(".#darwinConfigurations.$host.system")
  done
  echo "building: ${targets[*]}"
  nix build --no-link --no-write-lock-file "${installables[@]}"

  # if this mac was built, compare it with the running system
  if ! me="$(current_host)" || [[ ! -e /run/current-system ]]; then
    return 0
  fi
  for host in "${targets[@]}"; do
    if [[ "$host" == "$me" ]]; then
      # already built above, so this only prints the store path
      out="$(nix build --no-link --no-write-lock-file --print-out-paths ".#darwinConfigurations.$me.system")"
      changes="$(nix store diff-closures /run/current-system "$out")"
      echo
      echo "changes on $me compared with the running system:"
      echo "${changes:-  (none, identical to the running system)}"
      return 0
    fi
  done
}

switch_host() {
  local me
  local -a rebuild

  if (($# != 0)); then
    usage_error "switch takes no host; it always switches this mac"
  fi
  me="$(require_current_host)"

  if command -v darwin-rebuild >/dev/null; then
    rebuild=(darwin-rebuild)
  else
    # first install: darwin-rebuild is not on PATH yet
    rebuild=(nix run nix-darwin/nix-darwin-26.05#darwin-rebuild --)
  fi

  echo "switching: $me"
  # -H sets HOME to root's home, which avoids nix's '$HOME is not owned by you' warning
  sudo -H "${rebuild[@]}" switch --no-write-lock-file --flake ".#$me"
}

# the script runs sudo itself, and under sudo the login user would read as root
if (($(id -u) == 0)); then
  printf 'error: run ./build.sh without sudo; it asks for sudo when switching\n' >&2
  exit 2
fi

action="${1:-}"
if (($# > 0)); then
  shift
fi

case "$action" in
  switch)
    switch_host "$@"
    ;;
  build)
    build_hosts "$@"
    ;;
  update)
    nix flake update "$@"
    ;;
  help | -h | --help)
    usage
    ;;
  "")
    usage_error "missing action"
    ;;
  *)
    usage_error "unknown action '$action'"
    ;;
esac
