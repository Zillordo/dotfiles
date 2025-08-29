#!/usr/bin/env bash

hyprctl dispatch exec [workspace 1 silent] 'uwsm app -- ghostty -e ~/.local/bin/run-tmux.sh'
hyprctl dispatch exec [workspace 2 silent] 'uwsm app -- zen-browser'
uwsm app -- slack -u

disown
