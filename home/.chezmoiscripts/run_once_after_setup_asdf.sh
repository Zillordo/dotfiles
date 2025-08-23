#!/usr/bin/env nu

mkdir $"($env.HOME)/.asdf/completions"
asdf completion nushell | save $"($env.HOME)/.asdf/completions/nushell.nu"
