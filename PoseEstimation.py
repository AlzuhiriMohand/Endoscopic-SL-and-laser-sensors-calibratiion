#-----Code for pose estimation  
import cv2
import os
import numpy as np
import glob
import scipy.io as sio
from AuxFunctions import intersectCirclesRaysToBoard
#%%
dictionary = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)
markerLength = 3.62143/2.54  # Here, our measurement unit is inches.
markerSeparation = markerLength/5   # Here, our measurement unit is inches.
board = cv2.aruco.GridBoard_create(4, 6, markerLength, markerSeparation, dictionary)
img = board.draw((200*4,200*6))
cv2.imshow('o',img)
#%%
save_path='OutputFiles\\CamCalPara.npz'
with np.load(save_path) as X:
    K, D= [X[i] for i in ('K','D')]
n=0
org_list=[]
dist=np.array([[0,0,0,0]],dtype=np.float32)

Knew=K.copy() 
Knew[0,0]=0.8*Knew[1,1]
Knew[0,1]=0
Knew[1,1]=Knew[0,0]
Knew[0,2]=831.5
Knew[1,2]=615.5
'''
#images = glob.glob('camt*.jpg')
dist=np.array([[0,0,0,0]],dtype=np.float32)
#images = glob.glob('camt*.jpg')
rvec=np.array([[0,0,0]],dtype=np.float32)
#images = glob.glob('camt*.jpg')
tvec=np.array([[0,0,0 ]],dtype=np.float32)
'''
#%%
img_dir = ".\\Undestorted images\\"
data_path = os.path.join(img_dir,'cam*.png')

deb=0
rvecs=[] 
tvecs=[]
images = sorted(glob.glob(data_path))
Count=len(images)
for fname in images:
    img = cv2.imread(fname)
    #print(fname)
    #img = cv2.fisheye.undistortImage(img, K, D=D, Knew=Knew)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    #gray=cv2.flip(gray,0) 
    corners, ids, rejectedImgPoints = cv2.aruco.detectMarkers(gray,dictionary)
    cv2.aruco.refineDetectedMarkers(gray, board, corners, ids, rejectedImgPoints)
    if ids is not None: # if there is at least one marker detected
        retval, rvec, tvec = cv2.aruco.estimatePoseBoard(corners, ids, board,Knew,dist)
        #retval, rvec, tvec = cv2.aruco.estimatePoseBoard(corners, ids, board,Knew,dist, rvec, tvec)
        rvecs.append(rvec)
        tvecs.append(tvec)
        if retval != 0:
            #rint(fname)
            im_with_aruco_board = cv2.aruco.drawAxis(img, Knew, dist, rvec, tvec, 5)  # axis length 100 can be changed according to your requirement
    else:
        print(fname)
        im_with_aruco_board=gray 
    if deb:
        cv2.imwrite('ImageX.png',im_with_aruco_board)
        imS = cv2.resize(im_with_aruco_board, (640, 480))
        cv2.imshow('img', imS)
        cv2.waitKey(0)             
cv2.destroyAllWindows()
#%%
Wp=[]
Ip=[]
objectPoints=[]
mat_contents = sio.loadmat('OutputFiles\\CameraPoints.mat')
Ip1=mat_contents['Ip']
#Wp1=mat_contents['Wp']

circles=[]
projCirclePoints=[]
objectPointsAccum=[]
circles3D=[]
cameraCirclePoints=[]
data_path = os.path.join(img_dir,'proj*.png')

imagesp = sorted(glob.glob(data_path))
circles3D_reprojected1=[]
deb=0
n=0
for fname in imagesp:
    img=cv2.imread(fname)
    #img=cv2.flip(img,1) 

    #circles3D=into(Ip1[0,n].astype(np.float32), rvecs[n], tvecs[n], Knew)
    circles3D=intersectCirclesRaysToBoard(Ip1[0,n].astype(np.float32), rvecs[n], tvecs[n], Knew,dist)

    #circles3D[:,2]=0
    print(fname )
    objectPointsAccum.append(circles3D)
    circles3D_reprojected, _ = cv2.projectPoints(circles3D,(0,0,0),(0,0,0), Knew, dist)
    for c in circles3D_reprojected:
    # for c in Ip1[0,n]:
        cv2.circle(img, tuple(c.astype(np.int32)[0]), 1, (255,255,255), cv2.FILLED)
    if deb:
        #show3d(circles3D)
        imS = cv2.resize(img, (640, 480))
        cv2.imshow('img', imS)
        #cv2.imshow('frame',img)
        cv2.waitKey(0)  
    n=n+1
cv2.destroyAllWindows()
 
imsize = gray.shape
#for i in range(Count):
#    objectPointsAccum[i]=objectPointsAccum[i].astype(np.float32)
#for i in range(Count):
#   Wp.append((Wp1[0,i].astype(np.float32)).reshape(-1,2))
for i in range(Count):
    Ip.append((Ip1[0,i].astype(np.float32)).reshape(-1,2)) 

#%%
#K_proj = cv2.initCameraMatrix2D(objectPointsAccum,Wp, imsize)  
dist_coef_proj=np.array([0,0,0,0],dtype=np.float32)
K_proj=np.zeros([3,3])
K_proj[0,0]=800
K_proj[1,1]=800
K_proj[0,2]=831.5
K_proj[1,2]=615.5


#%%
 
sio.savemat('OutputFiles\\Calresults.mat',{'K':K,'D':D,'Kp':K_proj,'Dp':dist_coef_proj,'Knew':Knew})
sio.savemat('OutputFiles\\WorldPoints.mat',{'World_p':objectPointsAccum })
