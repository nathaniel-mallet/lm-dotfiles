#!/bin/zsh

ggpull() { git pull origin $(git branch --show-current) }
ggpush() { git push origin $(git branch --show-current) }
