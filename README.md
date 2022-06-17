# Endoscopic-SL-and-laser-sensors-calibratiion
%--Calibration code for endoscopic laser or a structured light sensor\
Follow the following steps to calibrate the sensor:
1. Camera calibration(CameraCalibrationCode.py) --- Generate .npz file & undestorted figures
2. flatening of the projector data(FaltteningCode...py) -- S1: Cam photos -- npz file; S2: Prof photos -- new undestorted figures
3. SL pattern data generation (DataGeneration.m) with gereate a file tot2.m
4. Pose estimation(PoseEstimation.py) -- Calresults.mat(tot2.mat)
5. Optimmization (ConeFitting)
6. Visualization (VisualEvaluator)


If you are interested in a scientific explanation of the process, you can check section 3.4.1 of my thesis (don't hesitate to shoot me a message if you found any errors or mistakes in the thesis report). A compressed version of the thesis is available from the following link: https://github.com/AlzuhiriMohand/AlzuhiriMohand/blob/main/Multi-Modality_Nondestructive__compressed.pdf

 
To cite this work; use the following bibliography:

@phdthesis{alzuhiri2022multi,
  title={Multi-Modality Nondestructive Evaluation Techniques for Inspection of Plastic and Composite Pipeline Networks},
  author={Alzuhiri, Mohand},
  year={2022},
  school={Michigan State University}
}

