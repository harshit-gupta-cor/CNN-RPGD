function []=getBatch_test(x,y,batch)

images = single(x(:,:,:,batch)) ;
labels = single(y(:,:,:,batch)) ;

lowRes = images(:,:,1,:);
labels(:,:,1,:) = labels(:,:,1,:) - lowRes;
