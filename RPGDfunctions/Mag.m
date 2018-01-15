function MagnitudeImage= Mag(I)
sum(:,:)=zeros(size(I,1),size(I,2));
for i=1: size(I,3)

    sum=abs(I(:,:,i)).^2+sum;
    
    
    
end
MagnitudeImage=sqrt(sum);