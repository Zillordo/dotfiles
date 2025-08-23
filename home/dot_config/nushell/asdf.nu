let shims_dir = (
  if ( $env | get -o ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  } | path join 'shims'
)

$env.PATH = ( $env.PATH | split row (char esep) | where { |p| $p != $shims_dir } | prepend $shims_dir )

let asdf_data_dir = (
  if ( $env | get -o ASDF_DATA_DIR | is-empty ) {
    $env.HOME | path join '.asdf'
  } else {
    $env.ASDF_DATA_DIR
  }
)

if ($env | get -o ASDF_DATA_DIR | is-empty) {
  # Default asdf location
  if ("~/.asdf/completions/nushell.nu" | path expand | path exists) {
    source "~/.asdf/completions/nushell.nu"
  }
} else {
  let completions_file = ($env.ASDF_DATA_DIR | path join "completions" "nushell.nu")
  if ($completions_file | path exists) {
    nu $completions_file
  }
}
