#!/usr/bin/env bash

exe_path="/home/nate/dev/research/Fusion/fusibile/fusibile"
root_path="/media/nate/Data/Results/UCSNet/dtu/Output_testing/"
target_path="/media/nate/Data/UCSNet/dtu/dtu_points"



#declare -a arr=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)
declare -a arr=(1)

for i in ${arr[@]}; do
	printf -v padded "%03d" $i
    scene_path="$root_path/scan$padded"
    CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold 0.6 --disp_threshold 0.25 --num_consistent 3
done

python utils/collect_pointclouds.py --root_dir $root_path --target_dir $target_path --dataset "dtu"
