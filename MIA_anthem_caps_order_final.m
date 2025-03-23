%% Notice

% The order below should be determined at the very beginning of the experiment.
% It should not be modified while the experiment is in progress.
% It was created based on a goal of 60 participants for the experiment.
% If additional rounds are needed due to participants dropping out, a separate run order should be created.

%% create the anthem_run_number and caps_run_order
anthem_run_number = [repmat(4, 40, 1); repmat(5, 40, 1)];
anthem_run_number = anthem_run_number(randperm(80));

caps_run_order = [repmat([1, 2], 40, 1); repmat([2, 1], 40, 1)];
caps_run_order = caps_run_order(randperm(80),:);

% save in matfile
save('anthem_run_number_and_caps_order.mat', 'anthem_run_number', 'caps_run_order');

%% Import the matfile to use in the experiment