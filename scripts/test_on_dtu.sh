#!/usr/bin/env bash

### parameters ###
OUTPUT_PATH="/media/nate/Data/UCSNet/dtu/testing_results"
SCENE_LIST="./dataloader/datalist/dtu/testing.txt"
DATA_PATH="/media/nate/Data/DTU"
MAX_H=1200
MAX_W=1600

#MAX_H=512
#MAX_W=640

EXE_PATH="/home/nate/dev/research/fusibile/fusibile"
EVAL=/media/nate/Data/Evaluation/dtu/
EVAL_CODE_DIR=${EVAL}dtu_evaluation/python/
PC_DIR_NAME=ucsnet
EVAL_PC_DIR=${EVAL}mvs_data/Points/${PC_DIR_NAME}/
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/
LOG_FILE=/media/nate/Data/UCSNet/dtu/log.txt


### Testing ###
CUDA_VISIBLE_DEVICES=0 python test.py --root_path $DATA_PATH --test_list $SCENE_LIST --save_path $OUTPUT_PATH --max_h $MAX_H --max_w $MAX_W

fusion() {
	echo -e "Running Gipuma Fusion with disp_th=${1} and num_consist=${2}..."

	rm -rf ${OUTPUT_PATH}/point_clouds
	mkdir ${OUTPUT_PATH}/point_clouds

	### Fusion ###
	#SCANS=({1..24} {28..53} {55..72} {74..77} {82..128})
	SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)

	for SCAN_NUM in ${SCANS[@]}
	do
		DENSE_FOLDER="${OUTPUT_PATH}/scan${SCAN_NUM}"
		CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $DENSE_FOLDER --fusibile_exe_path $EXE_PATH --prob_threshold 0.6 --disp_threshold ${1} --num_consistent ${2}
	done

	# move merged point cloud to evaluation path
	# delete previous Points if directory is not empty
	rm -r $EVAL_PC_DIR*

	python utils/collect_pointclouds.py --root_dir $OUTPUT_PATH --target_dir ${OUTPUT_PATH}/point_clouds --dataset "dtu"
	cp ${OUTPUT_PATH}/point_clouds/* ${EVAL_PC_DIR}

	## Evaluate the output point clouds
	EVAL_LIST=$(printf ",%s" "${SCANS[@]}")
	EVAL_LIST=${EVAL_LIST:1}

	# run evaluation on output point clouds
	cd ${EVAL_CODE_DIR}
	python -u base_eval.py --method ${PC_DIR_NAME} --results_path ${EVAL_RESULTS_DIR} --eval_list ${EVAL_LIST}
}

#rm -rf $LOG_FILE
#fusion 0.25 3 | tee -a $LOG_FILE
