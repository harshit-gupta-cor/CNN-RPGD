function constant=computeConstant(Ysize, viewslv,N)


im1=rand(N,N);
sino2=rand(Ysize(1),length(viewslv));
sino1=radon(im1,viewslv);
im2=iradon(sino2, viewslv,'linear','none',1,N);
constant=(sino1(:)'*sino2(:))./(im1(:)'*im2(:));