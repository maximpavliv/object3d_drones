results_path = 'result_drones_GT/';
files_names = dir(strcat(results_path,'*.mat'));
%first = files_names(1).name;

n = size(files_names,1);

err_T_norms = [];
err_R_norms = [];
err_planar_scaled_norms = [];
for i = 1:n
    load(strcat(results_path,files_names(i).name));
    err_T_norms = [err_T_norms norm(err_T)];
    err_R_norms = [err_R_norms norm(err_R)];
    err_planar_scaled_norms = [err_planar_scaled_norms norm(err_planar_scaled)];
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
err_planar_scaled_mean = mean(err_planar_scaled_norms);
err_planar_scaled_mean
err_planar_scaled_std = std(err_planar_scaled_norms);
err_planar_scaled_std
