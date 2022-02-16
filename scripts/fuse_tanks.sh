#!/usr/bin/env bash

exe_path="/home/nate/dev/research/fusibile/fusibile"
root_path="/media/nate/Data/UCSNet/tanksandtemples/Output"
target_path="/media/nate/Data/UCSNet/tanksandtemples/Points"


#scene_path="$root_path/Family"
#disp=0.25
#num_const=4
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const
#
#
#scene_path="$root_path/Horse"
#disp=0.25
#num_const=4
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const
#
#
#scene_path="$root_path/Francis"
#disp=0.2
#num_const=7
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const
#
#
#scene_path="$root_path/Lighthouse"
#disp=0.3
#num_const=5
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const
#
#scene_path="$root_path/M60"
#disp=0.25
#num_const=4
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const


scene_path="$root_path/Panther"
disp=0.2
num_const=4
prob=0.6
CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const


#scene_path="$root_path/Playground"
#disp=0.25
#num_const=5
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const
#
#
#scene_path="$root_path/Train"
#disp=0.25
#num_const=5
#prob=0.6
#CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold $prob --disp_threshold $disp --num_consistent $num_const



python utils/collect_pointclouds.py --root_dir $root_path --target_dir $target_path --dataset "tanks"
