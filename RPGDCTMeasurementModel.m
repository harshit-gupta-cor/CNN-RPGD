% This script implemements Relaxed projected Gradient descent where the
%  projector is replaced with a CNN trained as a projector on the data
%  manifold. The scheme is based on the paper [1]. Given a measyurement y
%  and forward model H, the RPGD solves teh inverse problem by minimizing
%
%  \|H x - y\|^2 s.t. x \in Set S
%
% This is done iteratively by taking a gradient descent w.r.t. the
% data-fidelity term followed by projection
%  step on the set S.

% The code works in two settings:
% measurementModel: In this model GT is generated from a datset whcih contains their richer
% measurements. 
% GTModel: Ground truth is given in the dataset. 
% 
% Input variables: 
%
% Y: Noisy Measurement (Noise + Downsampled (low dose) version of the full dose sinogram)
% SNRinputVector: Noiselevel in the measurement 
% Projector: A CNN or any other operator trained as a projector
% GToperator:An operator which takes full dose sinogram and outputs an image. We will consider this image as the ground truth (GT) in measurementModel.
% Alv: An operator which takes low dose sinogram and gives its preferably FBP/BP image 
% H: Forward operator
% HT: Transpose of the forward operator
% Hpert: Perturbed version of the forward operator
% viewsfv: Views of the Sinogramfv
% GammaVector: Vector containing different step size of the gradient
% descent which is sweeped over to find the best result. 
% CVector: Vector containing different values of C(<1) of the RPGD. Lower C
% results faster convergence. It is sweeped over to find the best result.
% doShift: Enables that the simulated measurements from the GT are obtained
% from the perturbed version of the forward model so as to avoid inverse
% crime in GTModel. Default is 1.
% firstStepGradient: Enables having the Gradient step in the first
% itertion. Default is 0.
% testSet: Indices of the test set in the data
% downSamplingVector: Vector containing the downsamplingFactor from full
% dose to low dose.
% maxIter: Number of maximum iteration for RPGD
% The variables of RPGD are:
% var.alpha= Momentum of RPGD
% var.x(:,:,k)Output of RPGD at a given iteration k
% var.delta: Difference between successive x
% Tolerance= If Delta< Tolerance RPGD stops
% xRPGD is the final output and SNR.x is the final SNR
% [1] H. Gupta, K. H. Jin, H.Q.Nguyen, M.T. McCann, and M. Unser,
% ?CNN-Based Projected Gradient Descent for Consistent Image
%                   Reconstruction,? arXiv:1709.01809 [cs.CV], 2017.
% [2] K.  H.  Jin,  M.  T.  McCann,  E.  Froustey,  and  M.  Unser,  ?Deep
% convolutional neural network for inverse problems in
%                    imaging,?IEEE Trans. Image Process., vol. 26, no. 9,
%                    pp. 4509?4522, 2017.
clear all
warning('off','all')
restoredefaultpath

%% Input data
doShift=1;
firstStepGradient=0;
downSamplingVector=[5];
SNRinputVector=[40 ];
measurementModel=1;GTModel= ~(measurementModel);
maxIter=50 ;
opts.gpuMode=1;
testSet=[76:77];
TestSize=length(testSet);
defaultOperators=1;
N=512;% Size of images
Tolerance=1;
rsnr=@(oracle,rec) computeRegressedSNR(rec,oracle);%b Computes regressed DNR

%% Load data depending on the model
cd ./Data
if measurementModel
    load('Sinogramfv');
else
    load('./BiomedADnet/im476-500.mat','GTstack','viewsfv');
end
cd ../
YSize=[size(Sinogramfv,1) size(Sinogramfv,2)];

addpathsRPGD
clc

%% Sweep over all given Downsamplingfactors, Noiselevels, C, Gamma and images
for downSamplingfactor=downSamplingVector
    clear views Y YGT
    viewslv = viewsfv(1:downSamplingfactor:end); % Downsampled views
    
    s = rng;
    rng(1);
    viewsDownShift = viewslv +doShift* randn(size(viewslv)) * 0.05;% Perturbed views for GTModel
    rng(s);
    
    %% Deafult operators
    if defaultOperators
        normalizingConstant=computeConstant(YSize, downSamplingfactor,N);
        GToperator=@(x)iradon(x, viewsfv, 'linear', 'Ram-Lak', 1, N);
        Alv=@(x)iradon(x,viewslv,'linear', 'Ram-Lak', 1, N);
        H=@(x)radon(x,viewslv);
        Hpert=@(x)radon(x,viewsDownShift);
        HT=@(x)normalizingConstant*iradon(x,viewslv,'linear', 'Ram-Lak', 1, N);
    end
    %%
    
    for SNRinput=SNRinputVector
        % Load CVector and GammaVector for a specified downsamplinfactor
        % and noiselevel
        [GammaVector,CVector]=loadCandStep(SNRinput,downSamplingfactor);
        
        noise=logical(1/SNRinput);
        [Addresses,Projector,FBPconvnet]=loadNettesting(downSamplingfactor,SNRinput);
        
        net_gpu = eye(N);%Should be changed to vl_simplenn_move(Projector, 'gpu') ;
        FBPconvnet_gpu = eye(N);% Should be changed tovl_simplenn_move(FBPconvnet, 'gpu') ;
        
        for C=CVector
            for Gamma=GammaVector
               rho=1./Gamma;
               clear var
               cd('/Users/Harshit/C/cnn-pgd')
               for iteration=1:TestSize
                   
                    var.x=zeros(N,N,maxIter+1);
                    var.z=var.x;
                    if measurementModel 
                        % Creating ground truth 
                        GT=GToperator(Sinogramfv(:,:,1,testSet(iteration)));
                        % Creating masurement by downsampling the full dose
                        % sinograms
                        YGT=Sinogramfv(:,[1:downSamplingfactor:YSize(2)],1,testSet(iteration));  
                    else
                        GT(:,:)=GTstack(:,:,testSet(iteration));
                        % Creating Measurements from the GT
                        YGT=Hpert(GT);
                    end
                    sigma=1/sqrt(10^(SNRinput/10)/(sum(sum(YGT.^2))/(size(YGT,1)*size(YGT,2))));
                    % Noisy Measurements
                    Y=YGT+sigma*randn(size(YGT));
                    minI=min(GT(:));
                    maxI=max(GT(:));
                    ImageEnergy=norm(GT,'fro');
                    
                    %% FBPConvnet
                    var.x(:,:,1)= Alv(YGT);
                    %res=vl_simplenn_recursive(FBPconvnet_gpu,gpuArray(single(var.x(:,:,1) )));
                    xFBPconvnet=var.x(:,:,1);%+gather(res(end-1).x)+;
                    SNR.xFBPconvnet=rsnr(GT,xFBPconvnet)*ones(1,maxIter+1);
                    SNR.xsinoFBPconvnet=rsnr(YGT,H(xFBPconvnet))*ones(1,maxIter+1);
                    %% 
                    
                    Gradient=@(x) Gamma*HT(H(x)-Y);
                    var.alpha=0;
                    var.delta=Inf;
                    
                    clear SNR.zsino  SNR.xsino SNR.x SNR.z
                    %% RPGD
                    for k=1:maxIter
                       
                        v=var.x(:,:,k)-(k==1 && firstStepGradient)*Gradient(var.x(:,:,k));
                        %res=vl_simplenn_recursive(net_gpu,gpuArray(single(v )));
                        var.z(:,:,k)=v;%+gather(res(end-1).x);
                       
                        var.r(:,:,k)=var.z(:,:,k)-var.x(:,:,k);
                        var.alpha(k)=(k==1)*1+(k>1)*var.alpha(k-(k>1)*1)*min(1,(C*norm(var.r(:,:,k-(k>1)*1),'fro')./norm(var.r(:,:,k),'fro')));
                        var.x(:,:,k+1)=var.x(:,:,k)+var.alpha(k)*var.r(:,:,k);
                        var.delta(k)=norm(var.x(:,:,k+1)-var.x(:,:,k),'fro') ;
                        % Calculate SNRs
                        SNR= GroupSNR(var.x(:,:,k),var.z(:,:,k),k,GT,YGT,H,rsnr,SNR);
                        plotfigure(var.alpha,var.delta,k,SNR,var.x(:,:,k),minI,maxI)
                       
                        if ((var.delta(k)<Tolerance)&& (k>3))%Change here,
                            break % Stop RPGD when tolerance is reached
                        end
                        
                        
                    end
                    %% Collect the data and save it
                    var.alphaStack(iteration,:)=[var.alpha(1:k) var.alpha(end)*ones(1,maxIter+1-k)];
                        var.deltaStack(iteration,:)=[var.delta(1:k) var.delta(end)*ones(1,maxIter+1-k)];
                        
                        
                        xRPGD=var.x(:,:,k+1);
                        xFBP=var.x(:,:,1);
                        SNR= GroupSNR(var.x(:,:,k+1),var.z(:,:,k+1),k+1,GT,YGT,H,regsnr,SNR);
                        
                        cd('/Users/Harshit/DeepProject/cnn-pgd-poisson');
                        address=Addresses.export;
                        if doShift==1,address=[address,'Shift'],end; if firstStepGradient==1, address=[address,'firstG'],end;
                        pathSave=fullfile(address, ['rho_',num2str((rho>1)*fix(rho)+ (rho<1)*rho),'_Iter_',num2str(maxIter),'_C_',num2str(C)],...
                            ['im',num2str(testSet(iteration),'%0.3d')]);
                        mkdir(pathSave);cd(pathSave)
                        
                        saveComparisonplot(GT,xFBP,xFBPconvnet,xRPGD,SNR,minI,maxI,SNRinput,k);
                        close all
                        alpha=var.alpha;
                        delta=var.delta;
                        SnrRPGD=SNR.x(end);
                        SnrSinoRPGD=SNR.xsino(end);
                        SnrFBP=SNR.x(1);
                        SnrFBPConv=SNR.xFBPconvnet(1);
                        
                        ssimRPGD = ssim(double(xRPGD), (GT)) ;
                        ssimFBP = ssim(double(xFBP), (GT)) ;
                        ssimFBPconv = ssim(double(xFBPconvnet), (GT)) ;
                        StackSSIMRPGD(1,iteration)=ssimRPGD;
                        StackSSIMFBP(1,iteration)=ssimFBP;
                        StackSSIMFBPconv(1,iteration)=ssimFBPconv;
                        save('Result.mat','GT','Y','YGT','alpha','delta','xRPGD','xFBPconvnet','xFBP','SNR','viewslv', 'maxIter','SnrRPGD','SnrSinoRPGD','SnrFBP','SnrFBPConv','ssimRPGD','ssimFBP','ssimFBPconv');
                        
                        %Stack the results of each test image
                        SNR=stackSNR(SNR,k,iteration,maxIter);
                    
               end
               cd ../
                    %Save and plot the average of the whole test set
                    saveandPlotAvg(SNR,var.alphaStack,var.deltaStack)
                    
                    close all
                
                
            end
        end
    end
end
