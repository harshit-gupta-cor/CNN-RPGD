function [StepVector,Cvector]=loadCandStep(SNRinput,downSamplingfactor)
Cstruct.HV.vector{1}=[0.99];%40
Stepstruct.HV.vector{1}=1./[100 500 1000 ];

Cstruct.HV.vector{2}=[0.99];%40
Stepstruct.HV.vector{2}=1./[100 500 1000 ];

Cstruct.HV.vector{3}=[0.8];%40
Stepstruct.HV.vector{3}=1./[12000];%40 %%% optimum 2100-try increasing

Cstruct.HV.vector{4}=[0.8];%35
Stepstruct.HV.vector{4}=1./[100 200 600 500 800 1000 5000];%35 %%% optimum 500

Cstruct.HV.vector{5}=[0.8 ];%45
Stepstruct.HV.vector{5}=1./[100 200 600 500 800 1000 5000  1e4 1e5 1e6 1e9];%45 optimum 1000-try increasing


Cstruct.LV.vector{1}=[0.99];%40
Stepstruct.LV.vector{1}=1./[500 300 100 700];

Cstruct.LV.vector{2}=[0.99];%40
Stepstruct.LV.vector{2}=1./[500 700 100 1000 ];

Cstruct.LV.vector{3}=[0.8];%40
Stepstruct.LV.vector{3}=1./[100 800 10000 40000];%40 optimum 1000

Cstruct.LV.vector{4}=[0.8];%35
Stepstruct.LV.vector{4}=1./[500 ];%35 optimum 500

Cstruct.LV.vector{5}=[0.8 ];%45
Stepstruct.LV.vector{5}=1./[100 800 10000 40000];%45 optimum 800



        if     SNRinput==Inf,count=1,
        elseif SNRinput==70, count=2,
        elseif SNRinput==40, count=3,
        elseif SNRinput==35, count=4,
        elseif SNRinput==45, count=5,
        else, count=5
        end
       count=5;
        if downSamplingfactor==5
            Cvector=Cstruct.HV.vector{count};
            StepVector=Stepstruct.HV.vector{count};
        else
            Cvector=Cstruct.LV.vector{count};
            StepVector=Stepstruct.LV.vector{count};
        end


