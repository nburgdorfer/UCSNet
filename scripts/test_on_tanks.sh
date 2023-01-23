#!/usr/bin/env bash

### Testing ###
#DATASET=training
#DATASET=intermediate
DATASET=advanced

OUTPUT_PATH="/media/nate/Data/Results/UCSNet/tnt/Output_${DATASET}"
SCENE_LIST="./dataloader/datalist/tanks/${DATASET}.txt"
DATA_PATH="/media/nate/Data/TNT/${DATASET}"

CUDA_VISIBLE_DEVICES=0 python test.py --root_path $DATA_PATH --test_list $SCENE_LIST --save_path $OUTPUT_PATH --dataset tnt --max_h 1080 --max_w 1920


### Fusion ###
#	EXE_PATH="/home/nate/dev/research/fusibile/fusibile"
#	
#	for SCENE in Barn Caterpillar Church Courthouse Ignatius Meetingroom Truck
#	do
#		DENSE_FOLDER="${OUTPUT_PATH}/${SCENE}"
#		DISP=0.25
#		NUM_CONST=5
#		PROB_TH=0.6
#		CUDA_VISIBLE_DEVICES=0 python depthfusion.py --dense_folder $DENSE_FOLDER --fusibile_exe_path $EXE_PATH --prob_threshold $PROB_TH --disp_threshold $DISP --num_consistent $NUM_CONST
#	done
#	
#	python utils/collect_pointclouds.py --root_dir $OUTPUT_PATH --target_dir ${OUTPUT_PATH}/point_clouds --dataset "tanks"
