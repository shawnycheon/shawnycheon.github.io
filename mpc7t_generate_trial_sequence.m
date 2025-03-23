function [ts] = mpc7t_generate_trial_sequence(basedir, subjID)
%% code for music file

% subj_music folder: 01_orig.wav, 02_orig.wav, .. 01-07: orig, 08-14: scrb
% outside subjec folder(Anthem): 07_orig.wav, 14_scrb.wav

% when making ts,
% load file name, save in cell structure


%% SET: directory
[~, hostname] = system('hostname');
switch strtrim(hostname)
    case 'sehwanui-MacBookPro.local'
        basedir = '/Users/shawn/WORK/test/MPC7T_code';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = 'MacBook Pro 내장 스피커';
    case 'Cocoanui-iMac-2.local' % 
        basedir = '/Users/deipp/Dropbox/Project/MIA/MIA_codes_sync';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
    case 'cnirui-Mac-Pro.local'
        basedir = '/Users/cocoan/Dropbox/Project/MIA/MIA_codes_sync';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
end

ts_dir = fullfile(basedir, 'trial_sequence', subjID);
ts.subj_id = subjID;
subjnum = str2double(subjID(6:7));

%% Trial value lists
heat_list = [45.000 45.500 46.000 46.500 47.000 47.500];
sound_list = [1 2 3 4 5 6];
jitter_list = [3 4 5];
prestate_list = [6 5 4];

%% Make Session by Session ramdomization
rng('shuffle');

% Capsaicin deliver timing 
caps_time = [6*ones(1,5), 7*ones(1,5)];
caps_time = caps_time(randperm(length(caps_time)));

% Caps and Quin run random order, Caps:1, Quin:2
caps_quin_order = [ones(1,2), 2*ones(1,2)];
caps_quin_order = caps_quin_order(randperm(length(caps_quin_order)));

%% Loop: To make Session ts
j = 1;
for i = 1:10
    clear ts
    clearvars heat_order_table jitter_index_table run_order hs_trial_order hs_heat_order_table hsH_jitter_index_table sound_order hsS_jitter_index_table skinsite
    
    if i == 1 % Session 1: Structural Day
        % Randomization the Heat trial for Only Heat run (6 runs)
        heat_order = repelem(heat_list, 3);
        for n_runs = 1:6
            heat_order_table(n_runs,:) = heat_order(randperm(length(heat_order)));
        end
        
        % Jitter index for Only Heat run (6 runs)
        jitter_index = repmat([1, 2, 3], 1, 6);
        for n_runs = 1:6
            jitter_index_table(n_runs,:) = jitter_index(randperm(length(jitter_index)));
        end
        
        % Skin site
        first_half = randperm(3);
        second_half = randperm(3);
        while first_half(end) == second_half(1)
            second_half = randperm(3);
        end
        skinsite = [first_half, second_half];
        
        ts.subj_id = subjID;
        ts.heat_run_trial = heat_order_table;
        ts.jitter_index_list = jitter_index_table;
        ts.caps_deliver = caps_time(i);
        ts.skin_site = skinsite;
        
        savename = fullfile(ts_dir, ['trial_sequence_' subjID, sprintf('_Sess%02d',i), '.mat']);
        save(savename, 'ts');
        
    elseif mod(i,2) == 0 % Session 2, 4, 6, 8, 10: Heat&Sound + Resting
        % Randomization the run orders between Only Heat(1), Heat&Sound (2)
        run_order = [ones(1,4), 2*ones(1,2)];
        run_order = run_order(randperm(length(run_order)));
        
        % Randomization the Heat trial for Only Heat run (4 runs)
        heat_order = repelem(heat_list, 3);
        for n_runs = 1:4
            heat_order_table(n_runs,:) = heat_order(randperm(length(heat_order)));
        end
        
        % Jitter index for Only Heat run (4 runs)
        jitter_index = repmat([1, 2, 3], 1, 6);
        for n_runs = 1:4
            jitter_index_table(n_runs,:) = jitter_index(randperm(length(jitter_index)));
        end
        
        % Randomization the trial order for Heat(1) and Sound(2) run
        hs_trial_order = [ones(1,12), 2*ones(1,12)];
        for n_runs = 1:2
            hs_trial_order_table(n_runs,:) = hs_trial_order(randperm(length(hs_trial_order)));
        end
        
        % Randomization the Heat trial for Heat and Sound run (2 runs)
        heat_order = repelem(heat_list, 2);
        for n_runs = 1:2
            hs_heat_order_table(n_runs,:) = heat_order(randperm(length(heat_order)));
        end
        
        % Jitter index for Heat at Heat and Sound run
        jitter_index = repmat([1, 2, 3], 1, 4);
        for n_runs = 1:2
            hsH_jitter_index_table(n_runs,:) = jitter_index(randperm(length(jitter_index)));
        end
        
        % Randomization the Sound trial for Heat and Sound run (2 runs)
        sound_order = repmat([1,2,3,4,5,6], 1, 2);
        for n_runs = 1:2
            sound_order_table(n_runs, :) = sound_order(randperm(length(sound_order)));
        end
        
        % Jitter index for Sound at Heat and Sound run
        jitter_index = repmat([1, 2, 3], 1, 4);
        for n_runs = 1:2
            hsS_jitter_index_table(n_runs,:) = jitter_index(randperm(length(jitter_index)));
        end
        
        first_half = randperm(3);
        second_half = randperm(3);
        while first_half(end) == second_half(1)
            second_half = randperm(3);
        end
        skinsite = [first_half, second_half];
        
        
        ts.subj_id = subjID;
        ts.run_order = run_order;
        ts.heat_run_trial = heat_order_table;
        ts.jitter_index_list = jitter_index_table;
        ts.heat_sound_order = hs_trial_order_table;
        ts.heat_hsrun_trial = hs_heat_order_table;
        ts.heat_jitter_index = hsH_jitter_index_table;
        ts.sound_hsrun_trial = sound_order_table;
        ts.sound_jitter_index = hsS_jitter_index_table;
        ts.caps_deliver = caps_time(i);
        ts.skin_site = skinsite;
        
        savename = fullfile(ts_dir, ['trial_sequence_' subjID, sprintf('_Sess%02d',i), '.mat']);
        save(savename, 'ts');
        
    elseif any(i == [3, 5, 7, 9]) % Session 3, 5, 7, 9: Quinine day
        % Randomization the Heat trial for Only Heat run (6 runs)
        heat_order = repelem(heat_list, 3);
        for n_runs = 1:6
            heat_order_table(n_runs,:) = heat_order(randperm(length(heat_order)));
        end
        
        % Jitter index for Only Heat run (6 runs)
        jitter_index = repmat([1, 2, 3], 1, 6);
        for n_runs = 1:6
            jitter_index_table(n_runs,:) = jitter_index(randperm(length(jitter_index)));
        end
        
        first_half = randperm(3);
        second_half = randperm(3);
        while first_half(end) == second_half(1)
            second_half = randperm(3);
        end
        skinsite = [first_half, second_half];
        
        ts.subj_id = subjID;
        ts.heat_run_trial = heat_order_table;
        ts.jitter_index_list = jitter_index_table;
        ts.caps_deliver = caps_time(i);
        ts.caps_quin_order = caps_quin_order(j);
        ts.skin_site = skinsite;
        
        j = j+1;
        savename = fullfile(ts_dir, ['trial_sequence_' subjID, sprintf('_Sess%02d',i), '.mat']);
        save(savename, 'ts');

    end
end


end

