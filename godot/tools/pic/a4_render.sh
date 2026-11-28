#!/bin/bash
# 25 Nov: every Area 4 picture for the game (home view after 0..9 builds, the home view without the van, and each
# delivery place without the van / with the van / with the van and 5 parcels). Then: python3 tools/pic/a4_pics.py
# usage (from godot/): bash tools/pic/a4_render.sh /tmp/a4r
O=${1:-/tmp/a4r}; mkdir -p $O
HUB="--mode=hub --sunset=1 --bstand=1 --bscale=1.4 --board=-0.6,1.75,3.2 --brot=0.9 --table=1.6,0.19,2.9 --bike1=-0.1,0,5.3 --bike2=0.9,0,5.4 --bks=1.35 --q0=3.0,0.19,1.6 --p=8.5,5,10.5 --l=-1.5,1.2,0.5 --fov=52"
PL="--mode=street --sunset=1 --p=-22,2.6,11 --l=-33,3.6,20 --van=-28.5,0.3,16 --vr=3.74 --bx=-30.6,0.18,14.0"
R(){ timeout 600 xvfb-run -a godot --path . --resolution 540x1170 res://tools/pic/a4_mock.tscn -- --w=1080 --h=2338 "$@" > /dev/null 2>&1; }
J=()
run(){ R "$@" & J+=($!); if [ ${#J[@]} -ge 3 ]; then wait ${J[0]}; J=("${J[@]:1}"); fi; }
for n in 0 1 2 3 4 5 6 7 8 9; do run $HUB --built=$n --shot=$O/hub$n.png; done
run $HUB --built=9 --novan=1 --shot=$O/hubnv.png
for pl in temple wedding school apts marina; do
  run $PL --place=$pl --novan=1 --shot=$O/${pl}_nv.png
  run $PL --place=$pl --shot=$O/${pl}_v0.png
  run $PL --place=$pl --boxes=5 --shot=$O/${pl}_v5.png
done
wait
ls $O
