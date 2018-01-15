function  SNR= GroupSNR(x,z,k,GT,YGT,H,regsnr,SNR)
% Updates SNR 
if isreal(GT)
    SNR.x(k)=regsnr(GT,x);
    SNR.z(k)=regsnr(GT,z);
    SNR.zsino(k)=regsnr(YGT,H(z));
    SNR.xsino(k)=regsnr(YGT,H(x));
else
    
    
    SNR.x(k)=regsnr(Mag(GT),Mag(x));
    SNR.z(k)=regsnr(Mag(GT),Mag(z));
    SNR.zsino(k)=regsnr(Mag(YGT),Mag(H(z)));
    SNR.xsino(k)=regsnr(Mag(YGT),Mag(H(x)));
end