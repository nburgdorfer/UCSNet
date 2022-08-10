import numpy as np
import os
import sys
import shutil
import cv2
import re
from tqdm import tqdm

def load_pfm(filepath):
    with open(filepath, 'rb') as pfm_file:
        color = None
        width = None
        height = None
        scale = None
        data_type = None
        header = pfm_file.readline().decode('iso8859_15').rstrip()

        if header == 'PF':
            color = True
        elif header == 'Pf':
            color = False
        else:
            raise Exception('Not a PFM file.')
        dim_match = re.match(r'^(\d+)\s(\d+)\s$', pfm_file.readline().decode('iso8859_15'))
        if dim_match:
            width, height = map(int, dim_match.groups())
        else:
            raise Exception('Malformed PFM header.')
        # scale = float(file.readline().rstrip())
        scale = float((pfm_file.readline()).decode('iso8859_15').rstrip())
        if scale < 0: # little-endian
            data_type = '<f'
        else:
            data_type = '>f' # big-endian
        data_string = pfm_file.read()
        data = np.frombuffer(data_string, data_type)
        shape = (height, width, 3) if color else (height, width)
        data = np.reshape(data, shape)
        data = cv2.flip(data, 0)
    return data

def write_pfm(filename, image, scale=1):
    with open(filename, 'wb') as pfm_file:
        color = None

        if image.dtype.name != 'float32':
            raise Exception('Image dtype must be float32.')

        image = np.flipud(image)

        if len(image.shape) == 3 and image.shape[2] == 3: # color image
            color = True
        elif len(image.shape) == 2 or (len(image.shape) == 3 and image.shape[2] == 1): # greyscale
            color = False
        else:
            raise Exception('Image must have H x W x 3, H x W x 1 or H x W dimensions.')

        a = 'PF\n' if color else 'Pf\n'
        b = '%d %d\n' % (image.shape[1], image.shape[0])
        
        pfm_file.write(a.encode('iso8859-15'))
        pfm_file.write(b.encode('iso8859-15'))

        endian = image.dtype.byteorder

        if endian == '<' or endian == '=' and sys.byteorder == 'little':
            scale = -scale

        c = '%f\n' % scale
        pfm_file.write(c.encode('iso8859-15'))

        image_string = image.tobytes()
        pfm_file.write(image_string)

def load_cam(cam_file, crop_w, crop_h, scale):
    """ read camera txt file """
    cam = np.zeros((2, 4, 4))

    with open(cam_file, 'r') as cf:
        words = cf.read().split()

    # read extrinsic
    for i in range(0, 4):
        for j in range(0, 4):
            extrinsic_index = 4 * i + j + 1
            cam[0][i][j] = float(words[extrinsic_index])

    # read intrinsic
    for i in range(0, 3):
        for j in range(0, 3):
            intrinsic_index = 3 * i + j + 18
            cam[1][i][j] = float(words[intrinsic_index])

    if len(words) == 29:
        cam[1][3][0] = float(words[27])
        cam[1][3][1] = float(words[28])
        cam[1][3][2] = 256
        cam[1][3][3] = cam[1][3][0] + cam[1][3][1] * cam[1][3][2]
    elif len(words) == 30:
        cam[1][3][0] = float(words[27])
        cam[1][3][1] = float(words[28])
        cam[1][3][2] = float(words[29])
        cam[1][3][3] = cam[1][3][0] + cam[1][3][1] * cam[1][3][2]
    elif len(words) == 31:
        cam[1][3][0] = words[27]
        cam[1][3][1] = float(words[28])
        cam[1][3][2] = float(words[29])
        cam[1][3][3] = float(words[30])
    else:
        cam[1][3][0] = 0
        cam[1][3][1] = 0
        cam[1][3][2] = 0
        cam[1][3][3] = 0

    # scale cam
    cam[1,0,0] = cam[1,0,0] * scale
    cam[1,1,1] = cam[1,1,1] * scale
    cam[1,0,2] = cam[1,0,2] * scale
    cam[1,1,2] = cam[1,1,2] * scale

    # crop cam
    cam[1,0,2] = cam[1,0,2] - crop_w
    cam[1,1,2] = cam[1,1,2] - crop_h

    return cam

def write_cam(cam_file, cam):
    with open(cam_file, "w") as f:

        f.write('extrinsic\n')
        for i in range(0, 4):
            for j in range(0, 4):
                f.write(str(cam[0][i][j]) + ' ')
            f.write('\n')
        f.write('\n')

        f.write('intrinsic\n')
        for i in range(0, 3):
            for j in range(0, 3):
                f.write(str(cam[1][i][j]) + ' ')
            f.write('\n')

        f.write('\n' + str(cam[1][3][0]) + ' ' + str(cam[1][3][1]) + ' ' + str(cam[1][3][2]) + ' ' + str(cam[1][3][3]) + '\n')

def main():
    dtu_path = sys.argv[1]
    ucsnet_path = sys.argv[2]
    crop_w = int(sys.argv[3])
    crop_h = int(sys.argv[4])
    scale = float(sys.argv[5])

    if (not os.path.exists(ucsnet_path)):
        os.mkdir(ucsnet_path)

    scans = list(range(1,25)) + list(range(28,54)) + list(range(55,73)) + list(range(74,78)) + list(range(82,129))

    dtu_cam_path = os.path.join(dtu_path, "Cameras")
    dtu_img_path = os.path.join(dtu_path, "Images")
    dtu_gt_path = os.path.join(dtu_path, "GT_Depths")

    with tqdm(scans, unit="scan") as scan:
        for s in scan:
            scan_str = "scan{:03d}".format(s)

            dtu_img_scan = os.path.join(dtu_img_path, scan_str)
            dtu_gt_scan = os.path.join(dtu_gt_path, scan_str)

            scan_dir = os.path.join(ucsnet_path, scan_str)
            cam_dir = os.path.join(scan_dir, "cams")
            img_dir = os.path.join(scan_dir, "images")
            gt_dir = os.path.join(scan_dir, "gt_depths")

            if (os.path.exists(scan_dir)):
                shutil.rmtree(scan_dir)

            os.mkdir(scan_dir)
            os.mkdir(cam_dir)
            os.mkdir(img_dir)
            os.mkdir(gt_dir)

            # migrate cameras
            cams = os.listdir(dtu_cam_path)
            cams.sort()

            for cam in cams:
                old_dir = os.path.join(dtu_cam_path, cam)
                if (cam == "pair.txt"):
                    new_dir = os.path.join(scan_dir, cam)
                    shutil.copy(old_dir, new_dir)
                else:
                    new_dir = os.path.join(cam_dir, cam)
                    cam = load_cam(old_dir, crop_w, crop_h, scale)
                    write_cam(new_dir, cam)

            # migrate images
            imgs = os.listdir(dtu_img_scan)
            imgs.sort()

            for img in imgs:
                if (img[-3:] == "png"):
                    old_dir = os.path.join(dtu_img_scan, img)
                    new_dir = os.path.join(img_dir, img)

                    im = cv2.imread(old_dir)

                    # resize
                    im = cv2.resize(im, None, fx=scale, fy=scale, interpolation=cv2.INTER_NEAREST)
                    (h,w, _) = im.shape

                    #crop
                    im = im[crop_h:h-crop_h, crop_w:w-crop_w]
                    cv2.imwrite(new_dir, im)

            # migrate gt depths
            gts = os.listdir(dtu_gt_scan)
            gts.sort()

            for gt in gts:
                if (gt[-3:] == "pfm"):
                    old_dir = os.path.join(dtu_gt_scan, gt)
                    new_dir = os.path.join(gt_dir, gt)

                    depth = load_pfm(old_dir)

                    # resize
                    depth = cv2.resize(depth, None, fx=scale, fy=scale, interpolation=cv2.INTER_NEAREST)
                    (h,w) = depth.shape

                    # crop
                    depth = depth[crop_h:h-crop_h, crop_w:w-crop_w]
                    write_pfm(new_dir, depth)

if __name__ == "__main__":
    main()
