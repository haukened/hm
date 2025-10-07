# fish completion for hm
complete -c hm -s h -l help -d "show help"
complete -c hm -l no-new-shell -d "do not re-exec login shell"
complete -c hm -n "not __fish_seen_subcommand_from config flake" -a "config flake"
complete -c hm -n "__fish_seen_subcommand_from config flake" -s C -d "config file" -r -f -a "(__fish_complete_directories)"
