import os, sys
import argparse
import glob
import errno
import os.path as osp
import shutil


parser = argparse.ArgumentParser()

parser.add_argument('--root_dir', help='path to prediction', type=str,)
parser.add_argument('--target_dir', type=str)
parser.add_argument('--dataset', type=str, )
parser.add_argument('--scene', type=str, )

args = parser.parse_args()

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def collect_dtu(args):
    mkdir_p(args.target_dir)
    all_scenes = sorted(glob.glob(args.root_dir+'/*'))
    all_scenes = list(filter(os.path.isdir, all_scenes))
    for scene in all_scenes:
        if (scene[-3:] != args.scene):
            continue
        scene_id = int(scene.strip().split('/')[-1][len('scan'):])
        all_plys = sorted(glob.glob('{}/points_ucsnet/consistencyCheck*'.format(scene)))
        print('Found points: ', all_plys)

        shutil.copyfile(all_plys[-1]+'/final3d_model.ply', '{}/ucsnet{:03d}_l3.ply'.format(args.target_dir, scene_id))

def collect_tanks(args):
    mkdir_p(args.target_dir)
    all_scenes = sorted(glob.glob(args.root_dir + '/*'))
    all_scenes = list(filter(os.path.isdir, all_scenes))
    for scene in all_scenes:
        if (scene[-12:] != "point_clouds"):
            all_plys = sorted(glob.glob('{}/points_ucsnet/consistencyCheck*'.format(scene)))
            print('Found points: ', all_plys)
            scene_name = scene.strip().split('/')[-1]
            shutil.copyfile(all_plys[-1]+'/final3d_model.ply', '{}/{}.ply'.format(args.target_dir, scene_name))
            shutil.copyfile('./dataloader/datalist/tanks/logs/{}.log'.format(scene_name), '{}/{}.log'.format(args.target_dir, scene_name))

if __name__ == '__main__':
    if args.dataset == 'dtu':
        collect_dtu(args)
    elif args.dataset == 'tanks':
        collect_tanks(args)
    else:
        print('Unknown dataset.')
