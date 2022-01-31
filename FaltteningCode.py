# -*- coding: utf-8 -*-
"""
Created on Fri Jan 28 11:04:45 2022

@author: Mohand
"""
#%%
#img_dir = "C:\\Users\\mohand\OneDrive - Michigan State University\\GTI\Calibration\\Experimental cal\\calfree\\Roboticcal after damage - final - Jan26\\camcal\\"
#img_dir = ".\\CamCal\\"
#save_path = os.path.join(img_dir,'fisheycal_Demo.npz')


import cv2
import numpy as np
import threading
import time



import numpy as np
import os
import glob

distort=1
if distort:


    with np.load('fisheycal_Demo.npz') as X:
        K, D= [X[i] for i in ('K','D')]
        
    #os.chdir('CamCal\\')
    os.chdir('ProjCal\\')
    
    n=0
    org_list=[]
    Knew=K.copy() 
    Knew[0,0]=470
    Knew[1,1]=470
    Knew[0,1]=0
    Knew[0,2]=831.5
    Knew[1,2]=615.5
    img_dir = ".\\Undestorted images\\"
    #save_path = os.path.join(img_dir,'*.png')
    for file in glob.glob('*.png'):
        print(file)
        frame=cv2.imread(file)
        #frame = cv2.warpAffine(frame, M, (w, h))
        frame = cv2.fisheye.undistortImage(frame, K, D=D, Knew=Knew)
        u_path = os.path.join(img_dir,file)
        os.chdir('..')
        cv2.imwrite(u_path, frame)
        os.chdir('ProjCal\\')
        imS = cv2.resize(frame, (640, 480))
        cv2.imshow('img', imS)
        if (cv2.waitKey(200) & 0xFF == ord('q')):
            break
    
    cv2.destroyAllWindows()