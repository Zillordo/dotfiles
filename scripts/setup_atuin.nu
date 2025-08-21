#!/usr/bin/env nu

let atuin_dir = $"($env.HOME)/.local/share/atuin"

# ensure the directory exists
mkdir $atuin_dir

# check if directory is empty
if (ls $atuin_dir | length) == 0 {
    print "Initializing Atuin..."
    atuin init nu | save --force $"($atuin_dir)/init.nu"
} else {
    print "Atuin already initialized, skipping."
}
