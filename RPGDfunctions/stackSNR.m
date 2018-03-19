function SNR=stackSNR(SNR,k,iteration,maxIter)
% Stack the results of each test image
SNR.zsinoStack(iteration,:)=[SNR.zsino(1:k+1) SNR.zsino(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.xsinoStack(iteration,:)=[SNR.xsino(1:k+1) SNR.xsino(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.xStack(iteration,:)=[SNR.x(1:k+1) SNR.x(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.zStack(iteration,:)=[SNR.z(1:k+1) SNR.z(k+1)*ones(1,maxIter+1-(k+1)) ];
SNR.xFBPconvnetStack(iteration,:)= SNR.xFBPconvnet;
SNR.xsinoFBPconvnetStack(iteration,:)= SNR.xsinoFBPconvnet;
