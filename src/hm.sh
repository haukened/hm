#!/usr/bin/env bash
set -euo pipefail

HM_DIR="${HM_DIR:-$HOME/.config/home-manager}"
DEFAULT_CFG="$HM_DIR/home.nix"
DEFAULT_FLAKE="$HM_DIR/flake.nix"
SHELL_PATH="${SHELL:-/bin/sh}"

usage() {
  cat <<'EOF'
hm – portable wrapper for Home Manager

Usage:
  hm [home-manager args...]            # run home-manager (default: switch)
  hm config [-C FILE]                  # edit home.nix (or FILE)
  hm flake  [-C FILE]                  # edit flake.nix (or FILE)
  hm --no-new-shell ...                # skip re-execing shell after command

Environment:
  HM_DIR         defaults to ~/.config/home-manager
  VISUAL/EDITOR  editor for config files
  SHELL          login shell to re-exec
EOF
}

open_file() {
  local file="$1"
  local dir
  dir="$(dirname "$file")"
  [[ -d "$dir" ]] || mkdir -p "$dir"
  # Call the editor directly so EDITOR="code -w" etc. works
  "${VISUAL:-${EDITOR:-vi}}" "$file"
  exit 0
}

# Global flag: --no-new-shell
NO_NEW_SHELL=0
for arg in "$@"; do
  [[ "$arg" == "--no-new-shell" ]] && NO_NEW_SHELL=1
done

# Strip --no-new-shell without breaking quoting
filtered=()
for arg in "$@"; do
  [[ "$arg" == "--no-new-shell" ]] || filtered+=("$arg")
done
set -- "${filtered[@]}"

# Default to `switch` when no args
[[ $# -eq 0 ]] && set -- switch

case "$1" in
  -h|--help)
    usage ;;

  config)
    shift
    cfg="$DEFAULT_CFG"
    if [[ "${1:-}" == "-C" ]]; then
      shift
      [[ $# -ge 1 ]] || { echo "hm: -C requires a path" >&2; exit 2; }
      cfg="$1"; shift
    fi
    open_file "$cfg" ;;

  flake)
    shift
    flk="$DEFAULT_FLAKE"
    if [[ "${1:-}" == "-C" ]]; then
      shift
      [[ $# -ge 1 ]] || { echo "hm: -C requires a path" >&2; exit 2; }
      flk="$1"; shift
    fi
    open_file "$flk" ;;

  --)
    shift
    ;&  # fall through to default with remaining args

  *)
    if ! command -v home-manager >/dev/null 2>&1; then
      echo "hm: home-manager not found in PATH" >&2
      exit 127
    fi

    home-manager "$@"

    if [[ $NO_NEW_SHELL -eq 0 ]]; then
      echo "Re-executing $SHELL_PATH ..."
      exec "$SHELL_PATH" -l
    fi
    ;;
esac
