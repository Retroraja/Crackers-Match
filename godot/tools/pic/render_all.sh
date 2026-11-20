#!/bin/bash
# renders every picture state at 1.5x (1620x3507)
P=/home/claude/pic.sh
W=1620; H=3507
r(){ d=/tmp/pics/$1; mkdir -p $d; shift; $P "$@" --w=$W --h=$H --out=$d > $d.log 2>&1; }
r a1p0 --area=1 --steps=0,1,2,3,4,5,6,7,8,9,10 --p=0,13,62 --l=-0.5,0,33 &
r a1p1 --area=1 --steps=0,1,2,3,4,5,6,7,8,9,10 --p=0,24,42 --l=0,0,12 &
wait
r a1p2 --area=1 --steps=0,1,2,3,4,5,6,7,8,9,10 --p=6,26,18 --l=-1,0,-20 &
r a2p0 --area=2 --steps=0,1,2,3,4,5,6,7,8,9,10,11,12 --p=0.3,3.0,12 --l=0,3.8,0 --fov=50 &
wait
r a2p1 --area=2 --steps=0,1,2,3,4,5,6,7,8,9,10,11,12 --p=0.2,2.6,9 --l=0,3.2,0 --fov=50 &
r title --area=1 --steps=10 --p=3,3.6,53 --l=-3.5,3.4,36 --fov=60 &
wait
r a1end --area=1 --steps=10 --p=6,26,18 --l=-1,0,-20 --night=0.75 &
wait
echo ALLDONE
