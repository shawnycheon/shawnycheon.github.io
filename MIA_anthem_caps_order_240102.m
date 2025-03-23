%% Notice

% The order below should be determined at the very beginning of the experiment.
% It should not be modified while the experiment is in progress.
% It was created based on a goal of 60 participants for the experiment.
% If additional rounds are needed due to participants dropping out, a separate run order should be created.

%% create the anthem_run_number and caps_run_order
anthem_run_number_1 = [repmat(4, 10, 1); repmat(5, 10, 1); repmat(6, 10, 1)];
anthem_run_number_1 = anthem_run_number_1(randperm(30));

anthem_run_number_2 = [repmat(4, 10, 1); repmat(5, 10, 1); repmat(6, 10, 1)];
anthem_run_number_2 = anthem_run_number_2(randperm(30));

anthem_run_number_3 = [repmat(4, 10, 1); repmat(5, 10, 1); repmat(6, 10, 1)];
anthem_run_number_3 = anthem_run_number_3(randperm(30));

anthem_run_number = [anthem_run_number_1; anthem_run_number_2; anthem_run_number_3];

caps_run_order_1 = [repmat([1, 2], 15, 1); repmat([2, 1], 15, 1)];
caps_run_order_1 = caps_run_order_1(randperm(30),:);

caps_run_order_2 = [repmat([1, 2], 15, 1); repmat([2, 1], 15, 1)];
caps_run_order_2 = caps_run_order_2(randperm(30),:);

caps_run_order_3 = [repmat([1, 2], 15, 1); repmat([2, 1], 15, 1)];
caps_run_order_3 = caps_run_order_3(randperm(30),:);

caps_run_order = [caps_run_order_1; caps_run_order_2; caps_run_order_3];

% save in matfile
save('anthem_run_number_and_caps_order.mat', 'anthem_run_number', 'caps_run_order');

%% Import the matfile to use in the experiment