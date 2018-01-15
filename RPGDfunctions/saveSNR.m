function StackSNR(SNR,k,iterShift)
SNRzsinoStack(iterShift,1:k)=[SNR.zsino(1:k+1) SNR.zsino(k+1)*ones(1,maxIter+1-(k+1)) ];
SNRxsinoStack(iterShift,1:k)=SNR.xsino(1:k);
SNRxStack(iterShift,1:k)=SNR.x(1:k);
SNRzStack(iterShift,1:k)=SNR.z(1:k);
SNRzsinoStack_end(iterShift)=SNR.zsino(k);
SNRxsinoStack_end(iterShift)=SNR.xsino(k);
SNRxStack_end(iterShift)=SNR.x(k);
SNRzStack_end(iterShift)=SNR.z(k);
SNRzFBPconvnetStack(iterShift,:)= SNR.zFBPconvnet;
SNRzsinoFBPconvnetStack(iterShift,:)= SNR.zsinoFBPconvnet;
