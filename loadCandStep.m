function [StepVector,Cvector]=loadCandStep(SNRinput,downSamplingfactor)
if SNRinput==Inf
    Cvector=0.8;
else
    Cvector=0.95;
end
StepVector=logspace(-5,-2,20);

