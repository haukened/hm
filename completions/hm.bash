# bash completion for hm
_hm_complete() {
  local cur prev
  if declare -F _init_completion >/dev/null; then
    _init_completion || return
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi
  case "$prev" in
    -C) COMPREPLY=( $(compgen -f -- "$cur") ); return ;;
    config|flake) COMPREPLY=( $(compgen -W "-C" -- "$cur") ); return ;;
  esac
  COMPREPLY=( $(compgen -W "config flake --no-new-shell -h --help" -- "$cur") )
}
complete -F _hm_complete hm
