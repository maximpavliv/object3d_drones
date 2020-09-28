%results_path = 'result_drones_GT_2500_1e-3/';
results_path = 'result_drones_GT_5000_1e-4/';
files_names = dir(strcat(results_path,'*.mat'));
%first = files_names(1).name;

n = size(files_names,1);

err_T_norms = [];
err_R_norms = [];
%err_planar_scaled_norms = [];
wp_iters = [];
fp_iters = [];
wp_times = [];
fp_times = [];
for i = 1:n
    load(strcat(results_path,files_names(i).name));
    err_T_norms = [err_T_norms norm(err_T)];
    err_R_norms = [err_R_norms norm(err_R)];
    wp_iters = [wp_iters wp_iter];
    fp_iters = [fp_iters fp_iter];
    wp_times = [wp_times wp_time];
    fp_times = [fp_times fp_time];
%    err_planar_scaled_norms = [err_planar_scaled_norms norm(err_planar_scaled)];
    clear err_R err_T output_fp err_planar_scaled
end

err_R_mean = mean(err_R_norms);
err_R_mean
err_R_std = std(err_R_norms);
err_R_std
err_T_mean = mean(err_T_norms);
err_T_mean
err_T_std = std(err_T_norms);
err_T_std
%err_planar_scaled_mean = mean(err_planar_scaled_norms);
%err_planar_scaled_mean
%err_planar_scaled_std = std(err_planar_scaled_norms);
%err_planar_scaled_std
wp_iters_mean = mean(wp_iters);
fp_iters_mean = mean(fp_iters);
wp_times_mean = mean(wp_times);
fp_times_mean = mean(fp_times);
wp_iters_mean
fp_iters_mean
wp_times_mean
fp_times_mean