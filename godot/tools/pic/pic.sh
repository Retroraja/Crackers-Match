#!/bin/bash
# usage: pic.sh args...
cd /home/claude/crackers-match/godot
timeout 600 xvfb-run -a -s "-screen 0 640x480x24" /home/claude/gd/godot --path . --resolution 64x64 res://tools/pic/pic_tool.tscn -- "$@" 2>&1 | grep -v "ALSA\|^$" | grep -i "PIC\|error" | head -20
