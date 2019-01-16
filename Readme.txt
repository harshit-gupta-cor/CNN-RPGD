CNN-RPGD

[1] H. Gupta, K. H. Jin, H.Q.Nguyen, M.T. McCann, and M. Unser, 'CNN-Based Projected Gradient Descent for Consistent Image Reconstruction', IEEE TMI, 2018. https://ieeexplore.ieee.org/abstract/document/8353870

[2]  K. H. Jin, M.T. McCann, E. Froustey, and M. Unser, 'Deep CNN for Inverse problem in Imaging', IEEE Transactions on Image Processing, 2017. http://ieeexplore.ieee.org/abstract/document/7949028/

Readme

1. Before launching CNN-RPGD, kindly install the MatConvNet (http://www.vlfeat.org/matconvnet/) (For the GPU, it needs a different compilation.)
2. Modify addpathsRPGD and addpathsPT based on the realtive directory paths on your machine. TrainingCTMeasurementModel, RPGDCTMeasurementModel should be edited to change the default parameters of RPGD.
3. The codes TrainingCTMeasurementModel.m is based on GPU computation. Kindly modify it to use it on CPU.
4. Use TrainingCTMeasurementModel for training the projector. After training, run RPGDCTMeasurementModel to get the result on the test data.

*note : these codes successfully ran on Matlab 2016a with GPU TITAN X (architecture : Maxwell)
contact : Harshit Gupta (harshit.gupta@epfl.ch), 

