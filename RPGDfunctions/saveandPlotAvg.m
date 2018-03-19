function saveandPlotAvg(SNR,alphaStack,deltaStack)

avg.SNR.x=mean(SNR.xStack,1);
avg.SNR.z=mean(SNR.zStack,1);
avg.SNR.xsino=mean(SNR.xsinoStack,1);
avg.SNR.zsino=mean(SNR.zsinoStack,1);

avg.SNR.xFBPconvnet=mean(SNR.xFBPconvnetStack,1);
avg.SNR.xsinoFBPconvnet= mean(SNR.xsinoFBPconvnetStack,1);
avg.delta=mean(deltaStack);
avg.alpha=mean(alphaStack);
avgRPGD=avg.SNR.x(end);
avgFBP=avg.SNR.x(1);
avgFBPconvnet=avg.SNR.xFBPconvnet(1);

avgsinoRPGD=avg.SNR.xsino(end);
avgsinoFBP=avg.SNR.xsino(1);
avgsinoFBPconvnet=avg.SNR.xsinoFBPconvnet(1);



save(['Average.mat'],'avg','SNR','deltaStack','alphaStack','avgRPGD','avgFBP','avgFBPconvnet','avgsinoRPGD', 'avgsinoFBP','avgsinoFBPconvnet');

figure(1);grid on;

subplot(2,2,1);hold on;plot(avg.SNR.x,'b-');plot(avg.SNR.xFBPconvnet,'k-');legend(' x','FBPconvnet','Location','southeast');title('Average SNR');hold off;
subplot(2,2,2);hold on; plot(avg.SNR.xsino,'b-');plot(avg.SNR.xsinoFBPconvnet,'k-');legend(' x','FBPconvnet','Location','southeast'),title('Average Sinogram SNR');hold off;
subplot(2,2,3);hold on; semilogy(alphaStack','b-.','linewidth',0.1);title('Alpha ');semilogy(avg.alpha,'k','linewidth',0.3);hold off;
subplot(2,2,4);hold on; semilogy(deltaStack','b:','linewidth',0.1);title('Delta ');semilogy(avg.delta,'k','linewidth',0.9);hold off;
saveas(gcf,['Details','.fig']);
saveas(gcf,['Details','.png']);
figure(2)
hold on; semilogy(avg.delta,'k','linewidth',2);semilogy(deltaStack','b:','linewidth',0.1);title('Delta ');hold off;%
saveas(gcf,['Delta','.fig']);
saveas(gcf,['Delta','.png']);
close all;
