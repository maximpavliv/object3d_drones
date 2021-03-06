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
savepath = 'result_drones_GT_5000_1e-4/';
mkdir(savepath);
annotfile = sprintf('%s/valid.mat',datapath);
load(annotfile);

cad = load('drones_files/cad.mat');
dict = load('drones_files/dict.mat');


yaw=0; pitch=-0.3; roll=-0.01;
T_offset = [0; 0; 0];


Rz=[cos(yaw), sin(yaw), 0; -sin(yaw), cos(yaw), 0; 0, 0, 1];
Ry=[cos(pitch), 0, sin(pitch); 0, 1, 0; -sin(pitch), 0, cos(pitch)];
Rx=[1, 0, 0; 0, cos(roll), -sin(roll); 0, sin(roll), cos(roll)];
R_offset = (Rz*Ry*Rx);
R_inv = [0, -1, 0; 0, 0, -1; 1, 0, 0];
%R_inv = [0, 0, 1; 0, -1, 0; 1, 0, 0];

R_cg = R_inv*R_offset;

% visualization flag
vis = 0;

for ID = 1:size(annot.imgname)

    % input
    imgname = annot.imgname{ID};
    center = annot.center(ID,:);
    scale = annot.scale(ID);    
    K = annot.K{ID};
    
    gt.rotation_gd = squeeze(annot.rotation(ID,:,:));
    gt.rotation_cd = R_cg*gt.rotation_gd';
    gt.translation_gd = reshape(annot.translation(ID,:),3,1);
    gt.translation_cd = R_cg*gt.translation_gd;

    savefile = sprintf('%s/valid_%d.mat',savepath,ID);

    % read heatmaps and detect maximum responses
    heatmap = h5read(sprintf('%s/valid_%d.h5',predpath,ID),'/heatmaps');
    heatmap = permute(heatmap,[2,1,3]); % transpose each heatmap (x and y axes)
    [W_hp,score] = findWmax(heatmap);
    W_im = transformHG(W_hp,center,scale,size(heatmap(:,:,1)),true);
    W_ho = K\[W_im;ones(1,size(W_im,2))];


    % pose optimization - weak perspective
    output_wp = PoseFromKpts_WP_its(W_hp,dict,'weight',score,'verb',false,'lam',1);
%    output_wp = PoseFromKpts_WP(W_hp,dict,'weight',score,'verb',false);
%    (as it is in demoFP)

    output_fp = PoseFromKpts_FP_its(W_ho,dict,'R0',output_wp.R,'weight',score,'verb',false);
    %copied from demoFP
    
    % update translation given object metric size
    S_fp = bsxfun(@plus,output_fp.R*output_fp.S,output_fp.T);
    [model_fp,w,~,T_fp] = fullShape(S_fp,cad);
    output_fp.T_metric = T_fp/w;   
    %copied from demoFP

%    display('GT:')
    %gt.translation
%    display('rot gd:')
%    gt.rotation_gd
%    display('rot rotated gt:')
%    gt.rotation
%    display('ESTIMATED:')
%    output_fp.T_metric
%    display('rot estimated')
%    output_fp.R
    %display('rotated:')
    %diag([1,-1,-1])*output_fp.R
    %error: 
    
    R_gt = gt.rotation_cd;
%    R = (diag([1,-1,-1])*output_fp.R)';
    R = output_fp.R;
    err_R = 180/pi*norm(logm(R_gt'*R),'fro')/sqrt(2);
    if isnan(err_R)
        err_R = 90;
    end
    %err_R
    %display('translation error raw:')
    err_T = gt.translation_cd - output_fp.T_metric;
    err_T_norm = norm(err_T);
    %err_T_norm
    r = gt.translation_cd(3)/output_fp.T_metric(3);
    estimated_planar_rescaled = [output_fp.T_metric(1)*r; output_fp.T_metric(2)*r];
    err_planar_scaled = estimated_planar_rescaled-gt.translation_cd(1:2);
    %display('planar error when on same plane:')
    err_planar_scaled_norm = norm(err_planar_scaled);
    %err_planar_scaled_norm
    
    wp_iter = output_wp.iter;
    fp_iter = output_fp.iter;
    wp_time = output_wp.timeAlt - output_wp.timeInit;
    fp_time = output_fp.time;
    
    
    % visualization
    if vis
        img = imread(sprintf('%s/../images/%s.jpg',datapath,imgname));
        %imshow(img);
        vis_fp_gt(img,output_fp,output_wp,heatmap,center,scale,K,cad,gt);
        pause
        close all
    end

    % save output
    save(savefile,'output_fp','err_R','err_T','err_planar_scaled', 'wp_iter', 'fp_iter', 'wp_time', 'fp_time');
        
end

% results
%pascal3d_res(datapath, savepath);