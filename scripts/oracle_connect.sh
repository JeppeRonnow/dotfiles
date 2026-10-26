#!/bin/bash

IP="152.70.42.141"
KEY="/home/jeppe/keys/ssh-key-2026-03-12.key"
USER="ubuntu"

TERM=xterm-256color ssh -i "$KEY" "$USER@$IP"
