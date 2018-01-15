function plotfigureMRI(alpha,delta,k,SNR,x,minI,maxI)

figure(1), grid on;subplot(2,2,1);semilogy(1:k,alpha);title(['z :SNR ',' '' ',num2str(SNR.z(k)),',  alpha : ', num2str(alpha(k))]);%imagesc(x(:,:,k),[minI maxI]);%colorbar;title(['x :SNR ',' '' ',num2str(SNRx(k))]);axis tight; drawnow;
subplot(2,2,2);imshow(x,[ minI maxI]);colorbar;title(['x : SNR ',' '' ',num2str(SNR.x(k))]);axis tight;
subplot(2,2,3);semilogy(1:k,delta);title(['delta : ', num2str(delta(k))]);grid on;drawnow;
if k>1
subplot(2,2,4);hold on;plot(SNR.x(1:k),'b-');plot(SNR.xFBPconvnet(1:k),'k-');hold off;
end
end