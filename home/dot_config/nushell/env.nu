# env.nu
#
# Installed by:
# version = "0.106.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

zoxide init nushell --cmd cd | save -f ~/.zoxide.nu

# Add ~/.local/bin to PATH
$env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME | path join .local bin))

mkdir ~/.cache/mise ; (^env -i (which 'mise' | first | get 'path') activate nu) | save --force ~/.cache/mise/init.nu
