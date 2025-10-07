# hm: a lightweight Home Manager helper

A tiny, shell-agnostic command for Home Manager users.

`hm switch`
`hm config`
`hm flake`

Why not just alias `hm="home-manager"`?

An alias only renames home-manager.
hm adds quality-of-life behavior that makes daily use smoother:

### Quick editing

	•	`hm config` opens your home.nix in `$EDITOR` (respects $VISUAL / $EDITOR)
	•	`hm flake` opens your flake.nix
	•	`hm -C path/to/file.nix` edits any other file you want

### Auto-reload environment

After `hm switch` or `hm apply`, it automatically re-executes your login shell so new environment variables, PATH changes, and aliases take effect immediately—no manual `exec $SHELL -l`.

Use `--no-new-shell` to skip that when you don’t want it.

Simple defaults, no assumptions
	•	Pure POSIX sh: works in bash, zsh, fish, or whatever you use.
	•	Respects `$HM_DIR`, `$VISUAL`, `$EDITOR`, and `$SHELL`.
	•	Creates missing config directories automatically.

Usage summary

`hm switch`            # Apply config, reload shell
`hm apply`             # Apply without generation switch
`hm config [-C FILE]`  # Edit home.nix (or FILE)
`hm flake  [-C FILE]`  # Edit flake.nix (or FILE)
`hm --no-new-shell …`  # Run without re-execing shell

