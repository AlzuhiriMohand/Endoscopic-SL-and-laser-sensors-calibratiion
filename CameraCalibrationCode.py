# -*- coding: utf-8 -*-
"""
Fishheye calibration code march 20 2018
@author: mohan
"""

import cv2
import numpy as np
import threading
import time



import numpy as np
import os
import glob

CHECKERBOARD = (6,9)
subpix_criteria = (cv2.TERM_CRITERIA_EPS+cv2.TERM_CRITERIA_MAX_ITER, 30, 0.1)
calibration_flags = cv2.fisheye.CALIB_RECOMPUTE_EXTRINSIC + cv2.fisheye.CALIB_CHECK_COND 
objp = np.zeros((1, CHECKERBOARD[0]*CHECKERBOARD[1], 3), np.float32)
objp[0,:,:2] = np.mgrid[0:CHECKERBOARD[0], 0:CHECKERBOARD[1]].T.reshape(-1, 2)
_img_shape = None
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.





#DIM=(480,480)
n=0
org_list=[]
tend=0
#select the path
img_dir = "./CamCal//"
data_path = os.path.join(img_dir,'*.png')

for file in glob.glob(data_path):
    #print(file)
    #ret,frame = cam.read()
    frame=cv2.imread(file)
    (h, w) = frame.shape[:2
                    ]
    # calculate the center of the image
    center = (w / 2, h / 2)
    angle180 = 180
    scale = 1.0
    # 180 degrees
    M = cv2.getRotationMatrix2D(center, angle180, scale)
    #frame = cv2.warpAffine(frame, M, (w, h))

    gray = cv2.cvtColor(frame,cv2.COLOR_RGB2GRAY)
    ret, corners = cv2.findChessboardCorners(gray, CHECKERBOARD, cv2.CALIB_CB_ADAPTIVE_THRESH+cv2.CALIB_CB_FAST_CHECK+cv2.CALIB_CB_NORMALIZE_IMAGE)
    # If found, add object points, image points (after refining them)
    if ret == True:
        objpoints.append(objp)
        cv2.cornerSubPix(gray,corners,(3,3),(-1,-1),subpix_criteria)
        imgpoints.append(corners)
        # Draw and display the corners  
        cv2.drawChessboardCorners(frame, (6,9), corners, ret)
        #cv2.imshow('img', frame)
        #cv2.waitKey(200)
    imS = cv2.resize(frame, (640, 480))
    cv2.imshow('img', imS)
    if (cv2.waitKey(100) & 0xFF == ord('q')):
        break

cv2.destroyAllWindows()

N_OK = len(objpoints)
K = np.zeros((3, 3))
D = np.zeros((4, 1))
rvecs = [np.zeros((1, 1, 3), dtype=np.float64) for i in range(N_OK)]
tvecs = [np.zeros((1, 1, 3), dtype=np.float64) for i in range(N_OK)]
rms, _, _, _, _ = \
    cv2.fisheye.calibrate(
        objpoints,
        imgpoints,
        gray.shape[::-1],
        K,
        D,
        rvecs,
        tvecs,
        calibration_flags,
        (cv2.TERM_CRITERIA_EPS+cv2.TERM_CRITERIA_MAX_ITER, 30, 1e-6)
    )
print("Found " + str(N_OK) + " valid images for calibration")
print("K=np.array(" + str(K.tolist()) + ")")
print("D=np.array(" + str(D.tolist()) + ")")
print(rms)
#save_path = os.path.join(img_dir,'fisheycal_Demo.npz')

np.savez('fisheycal_Demo.npz', D=D, K=K)

    