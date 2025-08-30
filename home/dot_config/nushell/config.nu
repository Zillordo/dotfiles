# config.nu
#
# Installed by:
# version = "0.106.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.edit_mode = 'vi'
$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

$env.config.show_banner = false
$env.config.buffer_editor = '/usr/bin/nvim'

$env.config.completions.algorithm = "fuzzy"
$env.config.completions.case_sensitive = false

$env.config.table.mode = "light"


source ~/.local/share/atuin/init.nu
source ~/.config/omarchy/current/theme/nushell.theme.nu
source ./aliases.nu
source ~/.zoxide.nu
source ./starship.nu
source ./ssh-agent.nu
source ./setup-plugins.nu

use ($nu.default-config-dir | path join mise.nu)

