%% Save run order.

addpath(genpath(fileparts(mfilename('fullpath'))));

runs = {'REST2', 'TEST2', 'MUSIC2', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4'};
durs = [12, 5, 12, 8, 12, 12, 12, 12] .* 60; % secs
n_subj = 90;
n_run = numel(runs);


%% make the marker matfile
marker_mat = false(n_subj, n_run);
marker_mat(:, 1) = true;

save('MIA_HEAT_run_data.mat', 'runs', 'durs', 'marker_mat');


