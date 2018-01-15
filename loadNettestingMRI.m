function [Addresses,net,FBPconvnet]=loadNettestingMRI(downSamplingfactor,SNRinput)
% Load the address to save RPGD result, the address of the projector net and
% FBPConvnet

    Addresses.export = fullfile('./testing_MRI',['x' num2str(downSamplingfactor),'_',num2str(SNRinput),'dB']);  



 netstruct=load('/Users/Harshit/DeepProject/cnn-pgd/training_result/x6_InfdB_Stage1/13-Dec-2017/net-epoch-71.mat');
 FBPconvnetStruct=load('/Users/Harshit/DeepProject/cnn-pgd/training_result/x6_InfdB_Stage1/13-Dec-2017/net-epoch-71.mat');
% 
 net=netstruct.net;
vl_simplenn_move(net, 'cpu') ; 
FBPconvnet=FBPconvnetStruct.net;   
% 
%    