#!/usr/bin/env bash
# Run before every commit: format, catch .nix files the flake cannot see,
# and check that every mac still builds.
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# the flake only sees files git tracks; an untracked .nix file is left out
# of the build even though it is on disk
untracked="$(git ls-files --others --exclude-standard -- '*.nix')"
if [[ -n "$untracked" ]]; then
  printf 'error: these .nix files are untracked, so the flake cannot see them:\n%s\n' "$untracked" >&2
  printf 'git add them (or delete them) and run this again\n' >&2
  exit 1
fi

treefmt
./build.sh build all

echo
echo "all hosts build. treefmt may have changed files; review and stage them:"
git status --short
