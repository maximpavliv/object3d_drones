%% PASCAL3D evaluation
% This script runs evaluation on PASCAL3D.
% We assume that the heatmaps (keypoint localizations) 
% are already computed and located in the folder 'predpath'.

clear
startup

% path for annotations
datapath = 'pose-hg/pose-hg-demo/data/pascal3d/annot/';
% path for network output
predpath = 'pose-hg/pose-hg-demo/exp/pascal3d/';
% path where the results are stored
savepath = 'result/cad/';
mkdir(savepath);
%annotfile = sprintf('%s/valid.mat',datapath);
annotfile = sprintf('%s/valid_light.mat',datapath);
load(annotfile);

% determines shape model used for pose optimization
% if set to 1 then we use the particular cad model instance
% if set to 0 then we use the deformable shape model
cadSpecific = 1;

% visualization flag
vis = 1;

% evaluate only on the clean set
testlist = find(~annot.occluded & ~annot.truncated);

for ID = testlist'

    ID
    % input
    imgname = annot.imgname{ID};
    center = annot.center(ID,:);
    scale = annot.scale(ID);    
    class = annot.class{ID};
    indices = annot.indices{ID};
    cadID = annot.cad_index(ID);

    cad = load(sprintf('cad/%s.mat',class));
    cad = cad.(class);
    cad = cad(cadID);

    savefile = sprintf('%s/valid_%d.mat',savepath,ID);

    if cadSpecific
        dict = getPascalTemplate(cad);
    else
        dict = load(sprintf('dict/pca-%s.mat',class));
    end
    % read heatmaps and detect maximum responses
    heatmap = h5read(sprintf('%s/valid_%d.h5',predpath,ID),'/heatmaps');
    heatmap = permute(heatmap(:,:,indices(dict.kpt_id)),[2,1,3]);
    [W_hp,score] = findWmax(heatmap);
    %WHAT IS THE DIFFERENCE BETWEEN W_HP, W_IM, W_HO??

    % pose optimization - weak perspective
    output_wp = PoseFromKpts_WP(W_hp,dict,'weight',score,'verb',false,'lam',1);

    R_gt = annot.rot{ID};
    R = (diag([1,-1,-1])*output_wp.R)';
    err_R = 180/pi*norm(logm(R_gt'*R),'fro')/sqrt(2);
    if isnan(err_R)
        err_R = 90;
    end
    err_R

    R_gt_aligned = diag([1,-1,-1])*R_gt';

    % visualization
    if vis
        img = imread(sprintf('%s/../images/%s.jpg',datapath,imgname));
        vis_wp_gt(img,output_wp,heatmap,center,scale,cad,dict,R_gt_aligned);
        pause
        close all
    end

    % save output
    save(savefile,'output_wp');
end

% results
%pascal3d_res(datapath, savepath);