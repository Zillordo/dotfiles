# Reuse the current ssh-agent if it is reachable.
# Otherwise start a new agent in Nushell (like `eval $(ssh-agent -s)`).

let agent_ok = (
  if (($env.SSH_AUTH_SOCK? | default "") == "") {
    false
  } else {
    let probe = (ssh-add -l | complete)
    ($probe.exit_code == 0) or ($probe.exit_code == 1)
  }
)

if not $agent_ok {
  let out = (ssh-agent -s | complete)

  if $out.exit_code != 0 {
    error make { msg: $"ssh-agent failed: ($out.stderr)" }
  }

  let sock = ($out.stdout | parse -r 'SSH_AUTH_SOCK=(?P<sock>[^;]+);' | get sock | first)
  let pid = ($out.stdout | parse -r 'SSH_AGENT_PID=(?P<pid>\d+);' | get pid | first)

  $env.SSH_AUTH_SOCK = $sock
  $env.SSH_AGENT_PID = $pid
}
