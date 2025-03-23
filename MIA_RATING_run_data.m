%% Save run order.

addpath(genpath(fileparts(mfilename('fullpath'))));

runs = {'EXE', 'RATE1', 'RATE2', 'RATE3', 'RATE4'};
durs = [5, 12, 12, 12, 6] .* 60; % secs
n_subj = 100;
n_run = numel(runs);


%% make the marker matfile
marker_mat = false(n_subj, n_run);
marker_mat(:, 1) = true;

save('MIA_RATING_run_data.mat', 'runs', 'durs', 'marker_mat');


