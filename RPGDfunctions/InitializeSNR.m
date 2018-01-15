function SNR=InitializeSNR(SNR,TestSize,maxIter)
SNR.zsinoStack=zeros(TestSize,maxIter); SNR.xsinoStack=zeros(TestSize,maxIter);
SNR.xStack=zeros(TestSize,maxIter);SNR.zStack=zeros(TestSize,maxIter);
SNR.zsinoStack_end=zeros(TestSize,1);SNR.xsinoStack_end=zeros(TestSize,1);
SNR.xStack_end=zeros(TestSize,1);SNR.zStack_end=zeros(TestSize,1);
