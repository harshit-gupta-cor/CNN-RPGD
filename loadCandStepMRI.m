function [StepVector,Cvector]=loadCandStepMRI(SNRinput,downSamplingfactor)
Cstruct.HV.vector{1}=[0.95 ];%40
Stepstruct.HV.vector{1}= [ 100 ];

Cstruct.HV.vector{2}=[0.95 ];%40
Stepstruct.HV.vector{1}= [ 100 ];

Cstruct.HV.vector{3}=[0.95 ];%40
Stepstruct.HV.vector{3}= [ 100  ];

Cstruct.HV.vector{4}=[0.95 ];%40
Stepstruct.HV.vector{4}=[ 100 ];%35 %%% optimum 500

Cstruct.HV.vector{5}=[0.95];%40
Stepstruct.HV.vector{5}= [ 100  ];%45 optimum 1000-try increasing




        if     SNRinput==Inf,
            count=1,
        elseif SNRinput==70, 
            count=2,
        elseif SNRinput==40,
            count=3,
        elseif SNRinput==35,
            count=4,
        elseif SNRinput==45, 
            count=5,
        else, 
            count=5
        end
       
        
            Cvector=Cstruct.HV.vector{count};
            StepVector=Stepstruct.HV.vector{count};
       
