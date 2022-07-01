#!/usr/bin/env bash

### parameters ###
OUTPUT_PATH="/media/nate/Data/UCSNet/dtu/testing_results"
SCENE_LIST="./dataloader/datalist/dtu/testing.txt"
DATA_PATH="/media/nate/Data/UCSNet/dtu/testing/"
EXE_PATH="/home/nate/dev/research/fusibile/fusibile"
EVAL=/media/nate/Data/Evaluation/dtu/
EVAL_CODE_DIR=${EVAL}dtu_evaluation/python/
PC_DIR_NAME=ucsnet
EVAL_RESULTS_DIR=${EVAL}mvs_data/Results/


### Testing ###
#CUDA_VISIBLE_DEVICES=0 python test.py --root_path $DATA_PATH --test_list $SCENE_LIST --save_path $OUTPUT_PATH --max_h 1200 --max_w 1600

fusion() {
	echo -e "Running Gipuma Fusion with disp_th=${1} and num_consist=${2}..."

	### Fusion ###
	#SCANS=({1..24} {28..53} {55..72} {74..77} {82..128})
	SCANS=(1 4 9 10 11 12 13 15 23 24 29 32 33 34 48 49 62 75 77 110 114 118)

	for SCAN_NUM in ${SCANS[@]}
	do
		DENSE_FOLDER="${OUTPUT_PATH}/scan${SCAN_NUM}"
		CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $DENSE_FOLDER --fusibile_exe_path $EXE_PATH --prob_threshold 0.6 --disp_threshold ${1} --num_consistent ${2}
	done

	# move merged point cloud to evaluation path
	python utils/collect_pointclouds.py --root_dir $OUTPUT_PATH --target_dir ${OUTPUT_PATH}/point_clouds --dataset "dtu"
	cp ${OUTPUT_PATH}/point_clouds/* ${EVAL_PC_DIR}


	## Evaluate the output point clouds
	# delete previous results if 'Results' directory is not empty
	if [ "$(ls -A $EVAL_RESULTS_DIR)" ]; then
		rm -r $EVAL_RESULTS_DIR*
	fi

	EVAL_LIST=$(printf ",%s" "${SCANS[@]}")
	EVAL_LIST=${EVAL_LIST:1}

	# run evaluation on output point clouds
	cd ${EVAL_CODE_DIR}
	python -u base_eval.py --method ${PC_DIR_NAME} --results_path ${EVAL_RESULTS_DIR} --eval_list ${EVAL_LIST}
}



### TEST 1 ###
#fusion 1.0 3 | tee -a "/media/nate/Data/UCSNet/dtu/test1.txt"

### TEST 2 ###
fusion 2.0 3 | tee -a "/media/nate/Data/UCSNet/dtu/test2.txt"

### TEST 3 ###
fusion 4.0 3 | tee -a "/media/nate/Data/UCSNet/dtu/test3.txt"

### TEST 4 ###
fusion 8.0 3 | tee -a "/media/nate/Data/UCSNet/dtu/test4.txt"

### TEST 5 ###
fusion 16.0 3 | tee -a "/media/nate/Data/UCSNet/dtu/test5.txt"

### TEST 6 ###
fusion 0.25 10 | tee -a "/media/nate/Data/UCSNet/dtu/test6.txt"

### TEST 7 ###
fusion 0.25 15 | tee -a "/media/nate/Data/UCSNet/dtu/test7.txt"

### TEST 8 ###
fusion 0.25 20 | tee -a "/media/nate/Data/UCSNet/dtu/test8.txt"

### TEST 9 ###
fusion 0.25 30 | tee -a "/media/nate/Data/UCSNet/dtu/test9.txt"
