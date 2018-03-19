function [net, info] = InitializeCNN(varargin)


%Deafult opts
opts.expDir='./training_result';
std_noise = 30;
opts.weightInitMethod = 'gaussian' ;
opts.networkType = 'simplenn' ;
opts.batchNormalization = true ;
opts.whitenData = false ;
opts.lite = false ;
opts.contrastNormalization = false ;
opts.train = struct() ;
opts.useGpu = true;
opts.gpus = 1 ;
opts.patchSize = 50;
opts.batchSize = 10 ;
opts.numEpochs = 1000 ;
opts.std_noise = std_noise ;
opts.lambda = 1e-4;
opts.imdb = [];
opts.waveLevel = 6;
opts.waveName = 'vk';
opts.gradMax = 1e-2;
opts.channel_out=1;
opts.channel_in=1;
opts.weight='none';
opts.plotStatistics=0;
% if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;

% Initalize with specified net
S1=varargin{1,1};S=S1;
if isfield(S1,'net')==1
S=rmfield(S,'net');
end
opts.momentum = 0.9 ;
opts = vl_argparse(opts, S) ;


% -------------------------------------------------------------------------
%                                                             Prepare model
% -------------------------------------------------------------------------
if isfield(S1,'net')==1
net=varargin{1,1}.net;
else 
    % initalize with fresh residual unet
net = cnn_unet_init( 'batchNormalization', opts.batchNormalization, ...
    'weightInitMethod', opts.weightInitMethod,'patchSize',opts.patchSize,'waveLevel',opts.waveLevel,...
    'channel_in',opts.channel_in,'channel_out',opts.channel_out);

end


% -------------------------------------------------------------------------
%                                                              Prepare data
% -------------------------------------------------------------------------
if isempty(opts.imdb) 
    imdb = load(opts.imdbPath) ;
else 
    imdb = opts.imdb;
end 
% -------------------------------------------------------------------------
%                                                                     Learn
% -------------------------------------------------------------------------

switch opts.networkType
    case 'simplenn', trainFn = @TrainingCNN;
    case 'dagnn', trainFn = @cnn_train_dag ;
end

[net, info] = trainFn(net, imdb, getBatch(opts), ...
    'expDir', opts.expDir, ...
    net.meta.trainOpts, ...
    opts.train, ...
    'val', find(imdb.images.set == 2),...
     'batchSize', opts.batchSize,...
     'numEpochs',opts.numEpochs,...
     'batchSize',opts.batchSize,...
     'gpus',opts.gpus,...
     'lambda',opts.lambda,...
     'waveLevel',opts.waveLevel,...
     'waveName',opts.waveName,...
     'weight',opts.weight,...
     'gradMax', opts.gradMax,'momentum',opts.momentum) ;

% -------------------------------------------------------------------------
function fn = getBatch(opts)
if opts.imdb.noiseCase==0
% -------------------------------------------------------------------------
fn = @(x,y) getSimpleNNBatch(x,y,opts.patchSize) ;% Access the batch for no noise case
else 
    fn = @(x,y) getSimpleNNBatch_Noisy(x,y,opts.patchSize) ;% Access the batch for no noise case
end


% -------------------------------------------------------------------------
function [images, labels, lowRes] = getSimpleNNBatch_Noisy(imdb, batch, patchSize)
% -------------------------------------------------------------------------
Ny = size(imdb.images.noisy,1);
Nx = size(imdb.images.noisy,2);
views=imdb.views;
sigma=imdb.sigma;

% Access the batch
for i=1:numel(batch)
    if batch(i)<=imdb.Ntrue
        v=imdb.images.noisy(:,:,:,batch(i));
<<<<<<< HEAD:cnn_fbpconvnet_noisy.m
        if rand>imdb.modelPerturbationProb
=======
        % Adding model perturbation with a probability
        if rand>imdb.modelPerturbationProb
            % X2 from noisy measurements
>>>>>>> 8fe5c2fb1cbd72a1535299381ed04439ef1334f9:ProjectorTrainingFunctions/InitializeCNN.m
            images(:,:,1,i)=single(v)+ imdb.Afl(sigma(batch(i))*randn(imdb.images.Ysize)) ;
        else
            % X2 from noisy and perturbed view measurements
            viewsShift = views + randn(size(views)) * 0.05;% Training with purturbations
            images(:,:,1,i)=single( imdb.Alv(imdb.H(v,viewsShift ))+  sigma(batch(i))*randn(imdb.images.Ysize)) ;
        end
    else
        images(:,:,1,i)=single(v);
    end

end
    
labels = single(imdb.images.orig(:,:,:,batch)) ;
% Flip for data augmentation
if rand > 0.5
    labels=fliplr(labels);
    images=fliplr(images);
end
if rand > 0.5
    labels=flipud(labels);
    images=flipud(images);
end
lowRes = images(:,:,1,:);
labels(:,:,1,:) = labels(:,:,1,:) - lowRes;


function [images, labels, lowRes] = getSimpleNNBatch(imdb, batch, patchSize)
% -------------------------------------------------------------------------
Ny = size(imdb.images.noisy,1);
Nx = size(imdb.images.noisy,2);
images=single(imdb.images.noisy(:,:,:,batch ));
labels = single(imdb.images.orig(:,:,:,batch)) ;


%%% Comment the following if recursive
if rand > 0.5
    labels=fliplr(labels);
    images=fliplr(images);
end
if rand > 0.5
    labels=flipud(labels);
    images=flipud(images);
end
lowRes = images(:,:,1,:);
labels(:,:,1,:) = labels(:,:,1,:) - lowRes;


