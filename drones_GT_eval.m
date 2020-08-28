%% DRONES evaluation
% This script runs evaluation on Drones GT.
% We assume that the heatmaps (keypoint localizations) 
% are already computed and located in the folder 'predpath'.

clear
startup

% path for annotations
datapath = 'pose-hg/pose-hg-demo/data/drones_GT/annot/';
% path for network output
predpath = 'pose-hg/pose-hg-demo/exp/drones_GT/';
% path where the results are stored
savepath = 'result_poses/drones_GT/';
mkdir(savepath);
annotfile = sprintf('%s/valid.mat',datapath);
load(annotfile);

cad = load('drones_files/cad.mat');
dict = load('drones_files/dict.mat');

yaw=0; pitch=-0.3; roll=-0.01;
R_offset=

% visualization flag
vis = 1;

for ID = 1:size(annot.imgname)

    % input
    imgname = annot.imgname{ID};
    center = annot.center(ID,:);
    scale = annot.scale(ID);    
    K = annot.K{ID};
    
    
    
    gt.rotation = squeeze(annot.rotation(ID,:,:));
    gt.translation = reshape(annot.translation(ID,:),3,1);
    


    savefile = sprintf('%s/valid_%d.mat',savepath,ID);

    % read heatmaps and detect maximum responses
    heatmap = h5read(sprintf('%s/valid_%d.h5',predpath,ID),'/heatmaps');
    heatmap = permute(heatmap,[2,1,3]); % transpose each heatmap (x and y axes)
    [W_hp,score] = findWmax(heatmap)
    W_im = transformHG(W_hp,center,scale,size(heatmap(:,:,1)),true);
    W_ho = K\[W_im;ones(1,size(W_im,2))];


    % pose optimization - weak perspective
    output_wp = PoseFromKpts_WP(W_hp,dict,'weight',score,'verb',false,'lam',1);
%    output_wp = PoseFromKpts_WP(W_hp,dict,'weight',score,'verb',false);
%    (as it is in demoFP)

    output_fp = PoseFromKpts_FP(W_ho,dict,'R0',output_wp.R,'weight',score,'verb',false);
    %copied from demoFP
    
    % update translation given object metric size
    S_fp = bsxfun(@plus,output_fp.R*output_fp.S,output_fp.T);
    [model_fp,w,~,T_fp] = fullShape(S_fp,cad);
    output_fp.T_metric = T_fp/w;   
    %copied from demoFP

    display('gt:')
    gt.translation
    gt.rotation
    display('estimated:')
    output_fp.T_metric
    output_fp.R

    % visualization
    if vis
        img = imread(sprintf('%s/../images/%s.jpg',datapath,imgname));
        vis_fp(img,output_fp,output_wp,heatmap,center,scale,K,cad);
        pause
        close all
    end

    % save output
    save(savefile,'output_fp');
        
end

% results
%pascal3d_res(datapath, savepath);