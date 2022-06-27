#!/usr/bin/env bash

### parameters ###
OUTPUT_PATH="/media/nate/Data/UCSNet/dtu/testing_all_results"
SCENE_LIST="./dataloader/datalist/dtu/testing_all.txt"
DATA_PATH="/media/nate/Data/UCSNet/dtu/testing_all/"
EXE_PATH="/home/nate/dev/research/fusibile/fusibile"
EVAL=/media/nate/Data/Evaluation/dtu/
EVAL_CODE_DIR=${EVAL}matlab_code/
PC_DIR_NAME=ucsnet
EVAL_PC_DIR=${EVAL}mvs_data/Points/${PC_DIR_NAME}/
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/


### Testing ###
CUDA_VISIBLE_DEVICES=0 python test.py --root_path $DATA_PATH --test_list $SCENE_LIST --save_path $OUTPUT_PATH --max_h 1200 --max_w 1600


### Fusion ###
#	#SCANS=({1..24} {28..53} {55..72} {74..77} {82..128})
#	SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)
#	
#	for SCAN_NUM in ${SCANS[@]}
#	do
#	    DENSE_FOLDER="${OUTPUT_PATH}/scan${SCAN_NUM}"
#	    CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $DENSE_FOLDER --fusibile_exe_path $EXE_PATH --prob_threshold 0.6 --disp_threshold 0.25 --num_consistent 3
#	done
#	
#	# move merged point cloud to evaluation path
#	python utils/collect_pointclouds.py --root_dir $OUTPUT_PATH --target_dir ${OUTPUT_PATH}/point_clouds --dataset "dtu"
#	cp ${OUTPUT_PATH}/point_clouds/* ${EVAL_PC_DIR}
#	
#	
#	## Evaluate the output point clouds
#	# delete previous results if 'Results' directory is not empty
#	if [ "$(ls -A $EVAL_RESULTS_DIR)" ]; then
#		rm -r $EVAL_RESULTS_DIR*
#	fi
#	
#	USED_SETS="[${SCANS[@]}]"
#	
#	# run matlab evaluation on merged output point cloud
#	matlab -nodisplay -nosplash -nodesktop -r "clear all; close all; format compact; arg_method='${PC_DIR_NAME}'; UsedSets=${USED_SETS}; run('${EVAL_CODE_DIR}BaseEvalMain_web.m'); clear all; close all; format compact; arg_method='${PC_DIR_NAME}'; UsedSets=${USED_SETS}; run('${EVAL_CODE_DIR}ComputeStat_web.m'); exit;" | tail -n +10
