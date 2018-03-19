% This script trains a projector on a manifold of the data using the
% sequential training procedure described in [1]. Given Groundtruth images
% X it trains a CNN by minimizing the following loss functions
%
% \sum_{q=1}^{3}\sum^{Ntraining}_{i=1}|| X(:,:,1,i)-CNN(X_q(:,:,1,i))||^2 (1)
%
% where X_q(:,:,1,i) is the qth perturabtion of X(:,:,1,i) and Ntraining is
% the number of training images. The CNN is exactly the same as in [2]
% which is based on residual Unet architecture with skip connections. The
% training is divided in 3 stages as discussed below. It is helpful to read
% the documentation of matconvnet (http://www.vlfeat.org/matconvnet/)
% before using this code.
%  
% The input variables are following: 
% Sinogramfv= H1*W1*1*Ntrue
% GToperator:An operator which takes full dose sinogram and outputs an image. 
%            
% We will consider this image as the ground truth (GT).
% Alv: An operator which takes low dose sinogram and gives its preferably FBP/BP image 
%      
% H: Forward operator viewsfv: Views of the Sinogramfv
% param.downsamplingFactor: the factor by which the views of the Sinogramfv
% are downsampled 
% 
%                           
% param.Noiselevel: Noise level in the measurement 
% epochTi: Total number of epochs for ith Stage testSet=Indexes of the test images
% Ntrue= Training + Testing images The data and the perturbations are as
% follows X(:,:,1,i) = Afv(Sinogramfv(:,:,1,Ntrue)): H*W*1*1. This is
% considered as the groundtruth Y(:,:,1,i) = Measurement which is the
% Downsampled versions of the full view sinogram X1(:,:,1,i)= X(:,:,1,i) :
% First type of perturbation X2(:,:,1,i)= Alv(Y(:,:,1,i)): Second type of
% perturbation X3(:,:,1,i)= CNN_t(X2(:,:,1,i)): Third type of perturabtion
% Stage 1 uses X1 as the only perturbation. Stage 2 uses X2 and X3 as the
% perturbation Stage 3 uses all the three perturbations train_opts is the
% structure used by matconvnet to train the CNN train.imdb is the structre
% we use to pass inforamtion about the image
%               dataset to the internal training routines
%[1] H. Gupta, K. H. Jin, H.Q.Nguyen, M.T. McCann, and M. Unser, 'CNN-Based
%Projected Gradient Descent for Consistent Image
%                   Reconstruction', arXiv:1709.01809 [cs.CV], 2017.
%[2] K.  H.  Jin,  M.  T.  McCann,  E.  Froustey,  and  M.  Unser,  ?Deep
% convolutional neural network for inverse problems in
%                    imaging,?IEEE Trans. Image Process., vol. 26, no. 9,
%                    pp. 4509?4522, 2017.

clear all
warning('off','all')
restoredefaultpath
%home

useGPU = false;


addpathsPT% Setup matconvnet path (edit according to the relative address of Matconvnet on your machine)



 %% Inputs
testSet=[76:100];
epochT1=10;
epochT2=5;
epochT3=6;

param.NoiseLevel=Inf;
param.DownsamplingFactor=5;
N=512; %
%% Loading Measurement data
cd ./Data
numProj = 720;
viewsfv = linspace(0,180,numProj+1);
viewsfv(end) = [];
viewslv=viewsfv(1:param.DownsamplingFactor:end);
lowviews=numProj/param.DownsamplingFactor;
load ('Sinogramfv.mat')

%% Default operators
imdb.Ntrue=size(Sinogramfv,4);
imdb.GToperator=@(x)iradon(x, viewsfv, 'linear', 'Ram-Lak', 1, N);%FBP
imdb.Alv=@(x)iradon(x,viewslv,'linear', 'Ram-Lak', 1, N);%FBP
imdb.H=@(x,views)radon(x,views); %Radon transform


%% Creating Ground truths (Images obtained from full dose) and measurements 
  
if ~(exist('X'))
    X=zeros(N,N,1,imdb.Ntrue);
     for i=1:size(Sinogramfv,4)
      % Image from full view sinogram. Considered as the ground truth (GT).
      X(:,:,1,i)=imdb.Afv(Sinogramfv(:,:,1,i));
     end
     %saving them for future use
     save('Sinogramfv.mat','X','-append');
end
Data_xF=['Data','_x',num2str(param.DownsamplingFactor),'.mat'];


if isempty(dir(Data_xF))
    Y=0.*zeros(size(Sinogramfv,1),length(viewslv),1,size(Sinogramfv,4));
    X2=0.*X;    
    for i=1:imdb.Ntrue
        Y(:,:,1,i)=Sinogramfv(:,[1:param.DownsamplingFactor:end],1,i);
        YNorm(i,1)=norm(Y(:,:,1,i),'fro');
        X2(:,:,1,i)=imdb.Alv(Y(:,:,1,i));
    end
    save(Data_xF,'Y','YNorm','X2');
else
    load(Data_xF);
end
Yheight=size(Y,1);
Ywidth=size(Y,2);
clear Sinogramfv
cd ../

%%


imdb.noiseCase=logical(1/param.NoiseLevel);

%% Stage wise training 
for Stage=1:3

param.Stage=Stage;
recursion=(Stage>1);

train_opts.channel_in = 1;
train_opts.channel_out=1;

% Address to save the trained net and to load trained net from previous
% stages to initialize the current stage
Addresses=loadNettraining(param);

if ~isempty(Addresses.loadnet)
load(Addresses.loadnet)
% moving it to the CPU version
net = vl_simplenn_move(net, 'cpu') ;
train_opts.net=net;
end

% The input output pair of the first satge.
A=X2;
B=X;
id_tmp  = ones(imdb.Ntrue,1);% Training data tag =1
id_tmp(testSet,1)=2; % Validation data tag= 2

if Stage==2
   % Concatanating input-output pair for stage 2
    A=cat(4, A, A(:,:,1,id_tmp(id_tmp-1==0)));
    B=cat(4, B, B(:,:,1,id_tmp(id_tmp-1==0)));
end
if Stage==3
    % Concatanating input-output pair for stage 2
    A=cat(4, A, B(:,:,1,id_tmp(id_tmp-1==0)));
    B=cat(4, B, B(:,:,1,id_tmp(id_tmp-1==0)));
end  

id_tmp  = ones(size(A,4),1);% Final tag
id_tmp(testSet,1)=2;% Final tag

if imdb.noiseCase==1   
    for i=1:Ntrue
        % Precompute the variance of noise for each image for a given noise
        % level
    sigma(i)=1/sqrt(10^(NoiseLevel/10)./(Ynorm(i,1).^2./(Yheight*Ywidth)));
    end    
else 
    sigma=0*YNorm;
end
imdb.sigma=sigma;
 
imdb.views=viewslv;

imdb.images.Yheight=Yheight;
imdb.images.Ywidth=Ywidth;
imdb.images.Ysize=[Yheight Ywidth];
imdb.Ynorm=YNorm;

imdb.recursion=recursion;
imdb.modelPerturbation=0;% Perturbation in he forward nodel. By default 0 for the measurement data
imdb.modelPerturbationProb=imdb.modelPerturbation*0.2;%default

imdb.images.set=id_tmp;           % train set : 1 , test set : 2
imdb.images.noisy=single(A);   
imdb.images.orig=single(B); 

train_opts.numEpochs =eval(['epochT',num2str(Stage)]) ;
%Learning rate
net.meta.trainOpts.learningRate = logspace(-1*(Stage==1)-3*(Stage>3),-3,train_opts.numEpochs) ;
opt='none';
% To use gpu
if useGPU
	train_opts.useGpu = 'true'; 
	train_opts.gpus = 0 ;
else
	train_opts.useGpu = 'false';
	train_opts.gpus = [] ;
end
train_opts.patchSize = N;
% Batchsize for SGD. 
train_opts.batchSize = 1;
train_opts.gradMax = 1e-2;

train_opts.momentum = 0.99 ;
train_opts.imdb=imdb;
train_opts.weight='none';

% Export directory
train_opts.expDir=Addresses.export;

[net, info] = InitializeCNN(train_opts);
end
