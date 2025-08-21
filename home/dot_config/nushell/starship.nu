$env.STARSHIP_CONFIG = ($nu.home-path | path join ".config/starship/starship.toml")

mkdir ($nu.data-dir | path join "vendor/autoload")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
