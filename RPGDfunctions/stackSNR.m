function SNR=stackSNR(SNR,k,iteration,maxIter)
% Stack the results of each test image
SNR.zsinoStack(iteration,:)=[SNR.zsino(1:k+1) SNR.zsino(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.xsinoStack(iteration,:)=[SNR.xsino(1:k+1) SNR.xsino(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.xStack(iteration,:)=[SNR.x(1:k+1) SNR.x(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.zStack(iteration,:)=[SNR.z(1:k+1) SNR.z(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.zsinoStack_end(iteration,1)=SNR.zsino(end);
SNR.xsinoStack_end(iteration,1)=SNR.xsino(end);
SNR.xStack_end(iteration,1)=SNR.x(end);
SNR.zStack_end(iteration,1)=SNR.z(end);
SNR.xFBPconvnetStack(iteration,:)= SNR.xFBPconvnet;
SNR.xsinoFBPconvnetStack(iteration,:)= SNR.xsinoFBPconvnet;
