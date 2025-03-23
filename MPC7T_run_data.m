%% Import the Session info
basedir = '/Users/shawn/WORK/test/MPC7T_code'
ts_dir = fullfile(basedir, 'trial_sequence', subjID);

subjID = 'MPC7T01_SHC'

tslist = struct(); 

for i = 1:10
    filename = sprintf('trial_sequence_%s_Sess%02d.mat', subjID, i);
    file_path = fullfile(ts_dir, filename);
    
    if exist(file_path, 'file')
        tslist.(['Session' num2str(i)]) = load(file_path);
    else
        warning('File not found: %s', filename);
    end
end

%% Save run order.

addpath(genpath(fileparts(mfilename('fullpath'))));

%% Session 1

runs = {'T1', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6', 'T2', 'CAPS1'};
durs = [360, 540, 540, 540, 540, 540, 540, 300, 1200]; % secs
n_subj = 15;
n_run = numel(runs);

% make the marker matfile
marker_mat = false(n_subj, n_run);
marker_mat(:, 1) = true;

save('MPC7T_Sess01_run_data.mat', 'runs', 'durs', 'marker_mat');

%% Session 2, 4, 6, 8, 10

for i = 2:2:10
    runs = {'REST1', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HS1', 'HS2', 'CAPS1'};
    durs = [600, 540, 540, 540, 540, 648, 648, 1200]; % secs
    n_subj = 15;
    n_run = numel(runs);
% make the marker matfile
    marker_mat = false(n_subj, n_run);
    marker_mat(:, 1) = true;

    save(sprintf('MPC7T_Sess%02d_run_data.mat', i), 'runs', 'durs', 'marker_mat');
end

%% Session 3, 5, 7, 9

for i = 3:2:9
    runs = {'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6', 'CAPS1', 'QUIN1'};
    durs = [540, 540, 540, 540, 540, 540, 1200, 720]; % secs
    n_subj = 15;
    n_run = numel(runs);
% make the marker matfile
    marker_mat = false(n_subj, n_run);
    marker_mat(:, 1) = true;

    save(sprintf('MPC7T_Sess%02d_run_data.mat', i), 'runs', 'durs', 'marker_mat');
end


%% From NOW


for i = 1:10
    filename = sprintf('trial_sequence_%s_Sess%02d.mat', subjID, i);
    file_path = fullfile(ts_dir, filename);
    if i == 1
        runs{i} = {'T1', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6', 'T2', 'CAPS1'};
        durs{i} = {360, 540, 540, 540, 540, 540, 540, 300, 1200}; % secs
    elseif mod(i,2) == 0
        runslist = {'REST1', 'TEST1', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HS1', 'HS2', 'CAPS1'};
        durslist = {600, 300, 540, 540, 540, 540, 648, 648, 1200}; % secs
        load(file_path);
        heatlist = {'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4'}; heatid = 1;
        hslist = {'HS1', 'HS2'}; hsid = 1;
        rand_order = cell(2, numel(ts.run_order));
        
        for j = 1:numel(ts.run_order)
            if ts.run_order(j) == 1
                rand_order{1, j} = heatlist{heatid};
                rand_order{2, j} = 540;
                heatid = heatid + 1;
            elseif ts.run_order(j) == 2
                rand_order{1, j} = hslist{hsid};
                rand_order{2, j} = 648;
                hsid = hsid + 1;
            else
                error("Error: Wrong run_order")
            end
        end
        
        runslist(3:8) = rand_order(1,:);
        durslist(3:8) = [rand_order(2,:)];
        runs{i} = runslist;
        durs{i} = durslist;
        
    elseif any(i == [3, 5, 7, 9])
        load(file_path);
        if ts.caps_quin_order == 1
            runs{i} = {'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6', 'CAPS1', 'QUIN1'};
            durs{i} = {540, 540, 540, 540, 540, 540, 1200, 720};
        elseif ts.caps_quin_order == 2
            runs{i} = {'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6', 'QUIN1', 'CAPS1'};
            durs{i} = {540, 540, 540, 540, 540, 540, 720, 1200};
        else
            error("Error: Wrong caps_quin_order")
        end
    end
    
end

n_session = 20; 
n_run = 9;
% make the marker matfile
marker_mat = false(n_session, n_run);
marker_mat(:, 1) = true;
save(sprintf('MPC7T_%s_run_data.mat', subjID), 'runs', 'durs', 'marker_mat');
