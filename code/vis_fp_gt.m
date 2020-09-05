function vis_fp_gt(img, opt_fp, opt_wp, heatmap, center, scale, K, cad, gt)

    img_crop = cropImage(img,center,scale);
    
    % weak perspective
    % estimated
    S_wp = bsxfun(@plus,opt_wp.R*opt_wp.S,[opt_wp.T;0]);
    model_wp = fullShape(S_wp,cad);
    mesh2d_wp = model_wp.vertices(:,1:2)'*200/size(heatmap,2);
    % gt
    % glasses perspective
    %S_wp_cd = bsxfun(@plus,gt.rotation_cd*opt_wp.S,[opt_wp.T;0]);
    %model_wp_cd = fullShape(S_wp_cd,cad);
    %mesh2d_wp_cd = model_wp_cd.vertices(:,1:2)'*200/size(heatmap,2);    

    
    % full perspective
    % estimated
    S_fp = bsxfun(@plus,opt_fp.R*opt_fp.S,opt_fp.T);
    model_fp = fullShape(S_fp,cad);
    mesh2d_fp = K*model_fp.vertices';
    mesh2d_fp = bsxfun(@rdivide,mesh2d_fp(1:2,:),mesh2d_fp(3,:));
    mesh2d_fp = transformHG(mesh2d_fp,center,scale,size(heatmap(:,:,1)),false)*200/size(heatmap,2);
    % ground truth
    S_gt_fp = bsxfun(@plus,gt.rotation_cd*opt_fp.S,opt_fp.T);
    model_gt_fp = fullShape(S_gt_fp,cad);
    mesh2d_gt_fp = K*model_gt_fp.vertices';
    mesh2d_gt_fp = bsxfun(@rdivide,mesh2d_gt_fp(1:2,:),mesh2d_gt_fp(3,:));
    mesh2d_gt_fp = transformHG(mesh2d_gt_fp,center,scale,size(heatmap(:,:,1)),false)*200/size(heatmap,2);
    
    % visualization
    nplot = 5;
    h = figure('position',[100,100,nplot*300,300]);
    % cropped image
    subplot('position',[0 0 1/nplot 1]);
    imshow(img_crop); hold on;
    % heatmap
    subplot('position',[1/nplot 0 1/nplot 1]);
    response = sum(heatmap,3);
    max_value = max(max(response));
    mapIm = imresize(mat2im(response, jet(100), [0 max_value]),[200,200],'nearest');
    imToShow = mapIm*0.5 + (single(img_crop)/255)*0.5;
    imagesc(imToShow); axis equal off
    % project cad model on image (weak perspective)
    subplot('position',[2/nplot 0 1/nplot 1]);
    imshow(img_crop); hold on;
    patch('vertices',mesh2d_wp','faces',model_wp.faces,'FaceColor','blue','FaceAlpha',0.3,'EdgeColor','none');
    % project cad model on image (full perspective), estimation
    subplot('position',[3/nplot 0 1/nplot 1]);
    imshow(img_crop); hold on;
    patch('vertices',mesh2d_fp','faces',model_fp.faces,'FaceColor','blue','FaceAlpha',0.3,'EdgeColor','none');

    % gt wp
%    subplot('position',[4/nplot 0 1/nplot 1]);
%    imshow(img_crop); hold on;
%    patch('vertices',mesh2d_wp_gt','faces',model_wp_gt.faces,'FaceColor','red','FaceAlpha',0.3,'EdgeColor','none');    
    subplot('position',[4/nplot 0 1/nplot 1]);
    h2_cd = subplot('position',[4/nplot 0 1/nplot 1]);
    trisurf(model_gt_fp.faces,model_gt_fp.vertices(:,1),model_gt_fp.vertices(:,2),model_gt_fp.vertices(:,3),'EdgeColor','none');axis equal;
    view(0,-90);
    set(h2_cd,'XTick',[],'YTick',[]);
    set(h2_cd,'visible','off')

end
