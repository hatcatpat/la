#!/bin/bash

editor='nvim'
session='la'

tmux new-session -s $session -d
tmux select-window -t $session
tmux split-window -t $session -h -l 40
tmux select-pane -t 0
tmux send-keys -t $session 'cd ../sketches && ' $editor ' test.lua' Enter
tmux select-pane -t 1
tmux send-keys -t $session 'cd .. && ./la' Enter
tmux attach -t $session
