function [Addresses,net,FBPconvnet]=loadNettesting(downSamplingfactor,SNRinput,NoisePoisson)
% Load the address to save RPGD result, the address of the projector net and
% FBPConvnet
if NoisePoisson
    Addresses.export = fullfile('./testing_Poisson_result',['x' num2str(downSamplingfactor),'_',num2str(SNRinput),'dB']);  
else
Addresses.export = fullfile('./testing_Poisson_result',['x' num2str(downSamplingfactor),'_',num2str(SNRinput),'dB']);  
end

 netstruct=load('/Users/Harshit/DeepProject/cnn-pgd/training_result-Realdata/x5_InfdB_Stage3/21-Nov-2017/net-epoch-10.mat');
 FBPconvnetStruct=load('/Users/Harshit/DeepProject/cnn-pgd/training_result-Realdata/x5_InfdB_Stage1/20-Nov-2017/net-epoch-80.mat');
% 
 net=netstruct.net;
vl_simplenn_move(net, 'cpu') ; 
FBPconvnet=FBPconvnetStruct.net;   
% 
%    