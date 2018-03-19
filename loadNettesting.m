function [Addresses,net,FBPconvnet]=loadNettesting(downSamplingfactor,SNRinput)
% Load the address to save RPGD result, the address of the projector net and
% FBPConvnet
Addresses.export = fullfile('./testing_result',['x' num2str(downSamplingfactor),'_',num2str(SNRinput),'dB']);  


% netstruct=load('');
% FBPconvnetStruct=load('');
% 
% net=netstruct.net;
 net=0;% vl_simplenn_move(net, 'cpu') ; 
 FBPconvnet=0;%FBPconvnetStruct.net;   
% 
%    