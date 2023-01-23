#!/usr/bin/env bash

exe_path="/home/nate/dev/research/Fusion/fusibile/fusibile"
root_path="/media/nate/Drive1/Results/UCSNet/dtu/Output/"
target_path="/media/nate/Drive1/Results/UCSNet/dtu/Points"

EVAL=/media/nate/Data/Evaluation/dtu/
MATLAB_CODE_DIR=${EVAL}matlab_code/
PYTHON_CODE_DIR=${EVAL}dtu_evaluation/python/
METHOD=ucsnet
EVAL_PC_DIR=${EVAL}mvs_data/Points/${METHOD}/
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/

declare -a arr=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)

for i in ${arr[@]}; do
	printf -v padded "%03d" $i
    #	scene_path="$root_path/scan$padded"
    #	CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $scene_path --fusibile_exe_path $exe_path --prob_threshold 0.6 --disp_threshold 0.25 --num_consistent 3
	python utils/collect_pointclouds.py --root_dir $root_path --target_dir $target_path --dataset "dtu" --scene $padded
done



## Evaluate the output point clouds
cp ${target_path}/* ${EVAL_PC_DIR}

# delete previous results if 'Results' directory is not empty
if [ "$(ls -A $EVAL_RESULTS_DIR)" ]; then
	rm -r $EVAL_RESULTS_DIR*
fi

SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)
USED_SETS="[${SCANS[@]}]"

# run matlab evaluation on merged output point cloud
matlab -nodisplay -nosplash -nodesktop -r "clear all; close all; format compact; arg_method='${METHOD}'; UsedSets=${USED_SETS}; run('${MATLAB_CODE_DIR}BaseEvalMain_web.m'); clear all; close all; format compact; arg_method='${METHOD}'; UsedSets=${USED_SETS}; run('${MATLAB_CODE_DIR}ComputeStat_web.m'); exit;" | tail -n +10
