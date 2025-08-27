#!/usr/bin/env nu

# Universal brightness control for Hyprland
# Usage: brightness.nu raise|lower

def main [action:string] {
    let step = 10
    let focused_monitor = (hyprctl monitors -j | from json | where focused == true | get name.0)

    # Laptop internal backlight?
    if (ls /sys/class/backlight/ | length) > 0 {
        let change = if $action == "raise" { $"+($step)" } else { $"-($step)" }
        run-external swayosd-client "--monitor" $focused_monitor "--brightness" $change
    } else {
        # Desktop: external monitors via DDC/CI

        # Map monitor names to DDC bus numbers
        let monitor_to_bus = {
            "DP-1": 2,
            "HDMI-A-1": 3
        }

        # Get bus number for focused monitor (handle unknown monitors gracefully)
        let bus = ($monitor_to_bus | get $focused_monitor)

        if $bus != null {
            let brightness_code = 10

            let output = (^ddcutil getvcp $brightness_code $"--bus=($bus)")
            let current = ($output | parse --regex 'current value =\s*(\d+)' | get capture0.0 | into int)
            let max_brightness = ($output | parse --regex 'max value =\s*(\d+)' | get capture0.0 | into int)

            let new = if $action == "raise" { $current + $step } else { $current - $step }
            let new = if $new > $max_brightness { $max_brightness } else { if $new < 0 { 0 } else { $new } }

            ddcutil setvcp $brightness_code $new $"--bus=($bus)"

            # Show OSD on focused monitor
            run-external swayosd-client "--monitor" $focused_monitor "--brightness" $new
        } else {
            print $"Error: Monitor ($focused_monitor) not supported for brightness control"
        }
    }
}
