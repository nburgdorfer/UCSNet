#!/usr/bin/env bash


save_path="/media/nate/Data/UCSNet/dtu/dtu_training_results"
test_list="./dataloader/datalist/dtu/test.txt"
root_path="/media/nate/Data/UCSNet/dtu/dmfnet_training/"



CUDA_VISIBLE_DEVICES=0 python test.py --root_path $root_path --test_list $test_list --save_path $save_path --max_h 1200 --max_w 1600
