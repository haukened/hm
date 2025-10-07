#!/usr/bin/env sh
set -eu

HM_DIR="${HM_DIR:-$HOME/.config/home-manager}"
DEFAULT_CFG="$HM_DIR/home.nix"
DEFAULT_FLAKE="$HM_DIR/flake.nix"
EDITOR_CMD="${VISUAL:-${EDITOR:-vi}}"
SHELL_PATH="${SHELL:-/bin/sh}"

usage() {
  cat <<EOF
hm – portable wrapper for Home Manager

Usage:
  hm [home-manager args...]            # run home-manager (default: switch)
  hm config [-C FILE]                  # edit home.nix (or FILE)
  hm flake  [-C FILE]                  # edit flake.nix (or FILE)
  hm --no-new-shell ...                # skip re-execing shell after command

Environment:
  HM_DIR       defaults to ~/.config/home-manager
  VISUAL/EDITOR   editor for config files
  SHELL        login shell to re-exec
EOF
}

open_file() {
  file=$1
  dir=$(dirname "$file")
  [ -d "$dir" ] || mkdir -p "$dir"
  exec $EDITOR_CMD "$file"
}

# Parse global flag
NO_NEW_SHELL=0
for arg in "$@"; do
  [ "$arg" = "--no-new-shell" ] && NO_NEW_SHELL=1
done

# Strip --no-new-shell from args
set -- $(printf '%s\n' "$@" | grep -v '^--no-new-shell$' || true)

[ $# -eq 0 ] && set -- switch

case "$1" in
  -h|--help)
    usage; exit 0 ;;
  config)
    shift
    cfg="$DEFAULT_CFG"
    [ "${1:-}" = "-C" ] && { shift; cfg="$1"; shift || true; }
    open_file "$cfg" ;;
  flake)
    shift
    flk="$DEFAULT_FLAKE"
    [ "${1:-}" = "-C" ] && { shift; flk="$1"; shift || true; }
    open_file "$flk" ;;
  *)
    command -v home-manager >/dev/null 2>&1 || {
      echo "hm: home-manager not found in PATH" >&2; exit 127; }
    home-manager "$@"
    if [ "$NO_NEW_SHELL" -eq 0 ]; then
      echo "Re-executing $SHELL_PATH ..."
      exec "$SHELL_PATH" -l
    fi
    ;;
esac
