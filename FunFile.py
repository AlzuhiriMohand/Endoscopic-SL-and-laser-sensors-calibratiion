# -*- coding: utf-8 -*-
"""
Created on Tue Dec 21 00:29:58 2021

@author: mohan
"""
import cv2
import numpy as np
from numpy.linalg import inv
import matplotlib.pyplot as pyplot
from mpl_toolkits.mplot3d import Axes3D


def intersectCirclesRaysToBoard(circles, rvec, t, K, dist_coef):
    imk=cv2.undistortPoints(circles, K, dist_coef)
    circles_normalized = cv2.convertPointsToHomogeneous(imk)
    #circles_normalized = cv2.convertPointsToHomogeneous(circles)
    if not rvec.size:
        return None
 
    R, _ = cv2.Rodrigues(rvec)
 
    # https://stackoverflow.com/questions/5666222/3d-line-plane-intersection
 
    plane_normal = R[:,2] # last row of plane rotation matrix is normal to plane
    plane_point = t.T     # t is a point on the plane
 
    epsilon = 1e-06
 
    circles_3d = np.zeros((0,3), dtype=np.float32)
 
    for p in circles_normalized:
        ray_direction = p / np.linalg.norm(p)
        ray_point = p
 
        ndotu = plane_normal.dot(ray_direction.T)
 
        if abs(ndotu) < epsilon:
            print ("no intersection or line is within plane") 
 
        w = ray_point - plane_point
        si = -plane_normal.dot(w.T) / ndotu
        Psi = w + si * ray_direction + plane_point
 
        circles_3d = np.append(circles_3d, Psi, axis = 0)
 
    return circles_3d
#%%
def into(circles_c,rvec, tvec, K):
    #imk=cv2.undistortPoints(circles, K, dist_coef)
    circles_normalized = cv2.convertPointsToHomogeneous(circles_c)
    circles_normalized=np.squeeze(circles_normalized)
    #circles_normalized = cv2.convertPointsToHomogeneous(circles)
    #if not rvec.size:
        #return None
    R, _ = cv2.Rodrigues(rvec)
    RT=R.copy()
    RT[:,2]=np.squeeze(tvec)
    tform=RT.copy()
    tform=K.dot(tform)
    circles_3d=np.matmul(inv(tform),circles_normalized.T)
    circles_3d=circles_3d.T
    circles_3d[:,0]=np.divide(circles_3d[:,0],circles_3d[:,2])
    circles_3d[:,1]=np.divide(circles_3d[:,1],circles_3d[:,2])
    circles_3d[:,2]=0
    return circles_3d
#%%
    

def draw(img, corners, imgpts):
    corner = tuple(corners[0].ravel())
    img = cv2.line(img, corner, tuple(imgpts[0].ravel()), (255,0,0), 5)
    img = cv2.line(img, corner, tuple(imgpts[1].ravel()), (0,255,0), 5)
    img = cv2.line(img, corner, tuple(imgpts[2].ravel()), (0,0,255), 5)
    return img
#%%
def show3d(circles3D):
    fig = pyplot.figure()
    ax = Axes3D(fig)
    #RT=Ip1[0,n].astype(np.float32)
    sequence_containing_x_vals = circles3D[:,0]
    sequence_containing_y_vals = circles3D[:,1]
    sequence_containing_z_vals = circles3D[:,2]
    ax.scatter(sequence_containing_x_vals, sequence_containing_y_vals, sequence_containing_z_vals)
    ax.set_xlabel('X-axis')
    ax.set_ylabel('Y-axis')
    ax.set_zlabel('Z-axis')
    '''
    ax.set_xlim([-5,5])
    ax.set_ylim([-5,5])
    '''
    #ax.set_zlim([3,7])
    pyplot.show() 