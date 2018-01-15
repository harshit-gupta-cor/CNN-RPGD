function phase=  Phaseangle(I)
phase=I;
for i=1: size(I, 3)
    phase(:,:,i)=angle(I(:,:,i));
end