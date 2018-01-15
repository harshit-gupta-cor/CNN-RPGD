function saveComparisonplot(GT,xFBP,xFBPconvnet,xRPGD,SNR,minI,maxI,SNRinput,k)
% plots to compare GT, xFBP, XFBPconvnet, and xRPGD.


fontname = 'Times'; %'Times', 'Helvetica'
set(0,'defaultaxesfontname',fontname);
set(0,'defaulttextfontname',fontname);
set(0,'defaulttextfontsize',15);
set(0,'defaultaxesfontsize',15);
sph=0.005; % space between each figure
spv=0.005;
spv2=0;
mgv=0.005;pdv=0;

figure(1),hold on ,set(gcf,'Color',[1 1 1]);colormap gray
subaxis(1,4,1, 'Spacing', sph, 'Padding', pdv, 'Margin', mgv);
imagesc(GT,[ minI maxI]);title({'Original',''});axis equal tight off
set(gca,'xtick',[],'ytick',[])

subaxis(1,4,2, 'Spacing', sph, 'Padding', pdv, 'Margin', mgv);
n1=num2str(SNR.x(1),6);
n1(end-1:end)=[];
imagesc(xFBP,[minI maxI]);title({'FBP' , ['SNR ',n1]}),axis equal tight off
set(gca,'xtick',[],'ytick',[])

subaxis(1,4,3, 'Spacing', sph, 'Padding', pdv, 'Margin', mgv);
imagesc(xFBPconvnet,[minI maxI]);
n3=num2str(SNR.xFBPconvnet(1),6);
n3(end-1:end)=[];
if SNRinput>60,title({'FBPconv',[ 'SNR ',n3]}); else, title({'FBPconv40',[ 'SNR ',n3]}); end
axis equal tight off
set(gca,'xtick',[],'ytick',[])

subaxis(1,4,4, 'Spacing', sph, 'Padding', pdv, 'Margin', mgv);
n4=num2str(SNR.x(k+1),6);
n4(end-1:end)=[];
imagesc(xRPGD,[ minI maxI]);title({'Proposed',['SNR ',n4]});axis equal tight off
set(gca,'xtick',[],'ytick',[])

set(gcf,'pos',[ 56        1036        560         230])

linkaxes(findall(0, 'type', 'axes'))

saveas(gcf,['Comparison','.fig']);
print('-dpng','-r250','Comparison');


end