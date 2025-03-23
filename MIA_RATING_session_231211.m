%% SETUP : Basic parameter
% rating the pleasureness and familiarity per music
clear;
close all;
Screen('CloseAll');

global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_vas anchor_middle korean alpnum space special bgcolor white orange red;

test_mode = false;

if test_mode
    show_cursor = true;
    screen_mode = 'small';
    disp('***** TEST mode *****');
else
    show_cursor = false;
    screen_mode = 'full';
    disp('***** EXPERIMENT mode *****');
end


ismacbook = false;
[~, hostname] = system('hostname');
switch strtrim(hostname)
    case 'euijin-macbookpro.local'
        basedir = '/Users/euijin/Dropbox/Project/MIA/MIA_codes_sync';
        ismacbook = true;
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = 'MacBook Pro 스피커'; %'내장 출력'
    case 'adminui-iMac.local' % 행동 실험실 MAC
        basedir = '/Users/admin/Dropbox/Project/MIA/MIA_codes_sync';
        ismac = true;
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
    case 'cocoanlabui-iMac.local' % 행동 실험실 MAC
        basedir = '/Users/cocoanlab/Dropbox/Project/MIA/MIA_codes_sync';
        ismac = true;
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '외장 헤드폰';
end

cd(basedir);
addpath(genpath(basedir));

exp_scale = {'cont_pleasure_vas', 'overall_pleasure', 'overall_music_attention', 'overall_familiarity'};
main_scale = {'cont_pleasure_vas', 'overall_pleasure', 'overall_music_attention', 'overall_familiarity'};


%% SETUP : Check subject info
subjID = upper(input('\nSubject ID (e.g., MIA001_HGD)? ', 's'));
subjnum = str2double(subjID(4:6));
subjrun = input('\nRun number? ');

if isempty(subjID) || isempty(subjnum) || isempty(subjrun)
    error('Wrong number. Break.')
end

% load or make ts file
ts_dir = fullfile(basedir, 'trial_sequence');
while true
    ts_fname = filenames(fullfile(ts_dir, ['trial_sequence*' subjID '*.mat']), 'char');
    if size(ts_fname,1) == 1
        if contains(ts_fname, 'no matches found') % no ts file
            ts_fname_check = filenames(fullfile(ts_dir, ['trial_sequence*' subjID(1:6) '*.mat']), 'char');
            if ~contains(ts_fname_check, 'no matches found') % no ts file
                error('File with the same subject number was found.');
            else
                mia_generate_trial_sequence(basedir, subjID); % make ts
            end
        else
            load(ts_fname); break;
        end
    elseif size(ts_fname,1)>1
        error('There are more than one ts file. Please check and delete the wrong files.')
    elseif size(ts_fname,1) == 0 % 7T MRI Mac
        mia_generate_trial_sequence(basedir, subjID); % make ts
    end
end

my_music_dir = filenames(fullfile(basedir, '/subj_music', ['MIA', num2str(subjnum, '%.3d')]), 'char');
if isempty(my_music_dir)
    error('*** No music directory for this participant! check it out ***')
end

% check if anthem file is in the directory
if isempty(filenames(fullfile(my_music_dir, '07_orig.wav'), 'char')) ...
        || isempty(filenames(fullfile(my_music_dir, '14_scrb.wav'), 'char'))
    anthem_dir = fullfile(basedir, '/subj_music/Anthem');
    anthem_files = filenames(fullfile(anthem_dir, '*'));
    copyfile(anthem_files{1}, my_music_dir); copyfile(anthem_files{2}, my_music_dir);
end


%% SETUP : Load randomized run data and Compare the markers
markerfile = fullfile(basedir, 'MIA_RATING_run_data.mat');
load(markerfile, 'runs', 'durs', 'marker_mat');
runmarker = find(marker_mat(subjnum, :));

if runmarker ~= subjrun
    cont_or_not = input(['\nThe run number is inconsistent with the latest progress. Continue?', ...
        '\n1: Yes.  ,   2: No, break.\n:  ']);
    if cont_or_not == 1
        runmarker = subjrun;
    elseif cont_or_not == 2
        error('Break.')
    else
        error('Wrong number. Break.')
    end
end


%% SETUP : Save data in first
savedir = fullfile(basedir, 'Data', 'MUSIC');
nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = subjID;
data.datafile = fullfile(savedir, sprintf('%s_%s_run%.2d_%s_MUSIC.mat', subjID, subjtime, runmarker, runs{runmarker}));
data.version = 'MIA_RATING_cocoanlab_20231227';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

save(data.datafile, 'data');


%% SETUP : Paradigm
S.type = runs{runmarker};
S.dur = durs(runmarker);
S.musicdur = 180;
if test_mode; S.dur = S.dur ./ 60; S.musicdur = S.musicdur ./ 60; end

data.dat.type = S.type;
data.dat.duration = S.dur;
data.dat.music_duration = S.musicdur;
data.dat.exp_scale = exp_scale;
data.dat.main_scale = main_scale;

rating_types = call_ratingtypes;

postrun_start_t = 2; % postrun start waiting time.
postrun_end_t = 2; % postrun questionnaire waiting time.


%% SETUP : Display the run order
runs_for_display = runs;
runs_for_display{runmarker} = sprintf('[[%s]]', runs_for_display{runmarker});
fprintf('\n\n');
fprintf('Runs: %s\n\n', string(join(runs_for_display)));
input('To continue, press any key.');


%% SETUP : Screen
PsychDefaultSetup(1);
screens = Screen('Screens');
window_num = screens(end);
if ~show_cursor
    HideCursor;
end

Screen('Preference', 'SkipSyncTests', 1);

[window_width, window_height] = Screen('WindowSize', window_num);
switch screen_mode
    case 'full'
        window_rect = [0 0 window_width window_height]; % full screen
    case 'semifull'
        window_rect = [0 0 window_width-100 window_height-100]; % a little bit distance
    case 'middle'
        window_rect = [0 0 window_width/2 window_height/2];
    case 'small'
        window_rect = [0 0 400 300]; % in the test mode, use a little smaller screen
end

% size
W = window_rect(3); % width
H = window_rect(4); % height

lb1 = W/4; % rating scale left bounds 1/4
rb1 = (3*W)/4; % rating scale right bounds 3/4

lb2 = W/3; % new bound for or not
rb2 = (W*2)/3;

scale_W = (rb1-lb1).*0.1; % Height of the scale (10% of the width)

anchor_lms = [0.061 0.172 0.354 0.533 0.8].*(rb1-lb1)+lb1;
anchor_vas = [0.25 0.5 0.75].*(rb1-lb1)+lb1;
anchor_middle = [0.2 0.5].*(rb1-lb1)+lb1;

% font
fontsize = 40;
Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');

% color
bgcolor = 50;
white = 255;
red = [158 1 66];
orange = [255 164 0];

% open window
theWindow = Screen('OpenWindow', window_num, bgcolor); % start the screen
Screen('Textfont', theWindow, '-:lang=ko');
Screen('TextSize', theWindow, fontsize);

% get font parameter
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('코'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('p '), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect4, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
[korean.x, korean.y, alpnum.x, alpnum.y, space.x, space.y, special.x, special.y] = deal(...
    wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), ... % x = 36, y = 50
    wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ... % x = 25, y = 50
    wordrect3(3)-wordrect3(1) - (wordrect2(3)-wordrect2(1)), wordrect3(4)-wordrect3(2), ... % x = 12, y = 50
    wordrect4(3)-wordrect4(1), wordrect4(4)-wordrect4(2)); % x = 19, y = 50

Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
Screen('Flip', theWindow);


%% SETUP: Input setting
% SETUP: Keyboard
devices = PsychHID('Devices');
devices_keyboard = [];
for i = 1:numel(devices)
    if strcmp(devices(i).usageName, 'Keyboard')
        devices_keyboard = [devices_keyboard, devices(i)];
    end
end
Exp_key = devices_keyboard(1).index; % MODIFY if you need

% SETUP: Audio
InitializePsychSound;
padev = PsychPortAudio('GetDevices');
padev_output = padev([padev.NrOutputChannels] > 0);
padev_output = padev_output(strcmp({padev_output.DeviceName}, outputdev.DeviceName) & strcmp({padev_output.HostAudioAPIName}, outputdev.HostAudioAPIName));


%% MAIN : Explain scale
if strcmp(S.type, 'EXE')
    msgtxt = ['안녕하세요, 참가자님. 실험에 참여해주셔서 감사합니다.\n\n', ...
        '본 실험은 한 번의 연습 세션과 네 번의 메인 세션으로 구성되어 있으며, 약 1시간 소요됩니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = ['참가자님께서는 음악을 듣는 동안 느끼는 1) 음악적 쾌감과 음악적 전율을 지속적으로 평가하고,\n\n', ...
        '음악이 끝나면 2) 전반적으로 얼마나 음악적 쾌감을 느꼈는지\n\n', ...
        '3) 전반적으로 곡에 얼마나 집중했는지\n\n', ...
        '4) 전반적으로 곡이 얼마나 친숙한지를 평가합니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    % explaining the rating scales
    % 음악적 쾌감 평가
    cont_pleasure_scale = imread(fullfile(basedir, 'Pictures', 'cont_pleasure.png'));
    cont_pleasure_scale_WH = size(cont_pleasure_scale);
    cont_pleasure_scale_rect = [W/2 - cont_pleasure_scale_WH(2)/2, H*1/2 - cont_pleasure_scale_WH(1)/2, W/2 + cont_pleasure_scale_WH(2)/2, H*1/2 + cont_pleasure_scale_WH(1)/2];
    Screen('PutImage', theWindow, cont_pleasure_scale, cont_pleasure_scale_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    % 음악적 집중도 평가
    overall_attention_scale = imread(fullfile(basedir, 'Pictures', 'cont_attention.png'));
    overall_attention_scale_WH = size(overall_attention_scale);
    overall_attention_scale_rect = [W/2 - overall_attention_scale_WH(2)/2, H*1/2 - overall_attention_scale_WH(1)/2, W/2 + overall_attention_scale_WH(2)/2, H*1/2 + overall_attention_scale_WH(1)/2];
    Screen('PutImage', theWindow, overall_attention_scale, overall_attention_scale_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    % 음악적 친숙도 평가
    overall_familiarity_scale = imread(fullfile(basedir, 'Pictures', 'cont_familiarity.png'));
    overall_familiarity_scale_WH = size(overall_familiarity_scale);
    overall_familiarity_rect = [W/2 - overall_familiarity_scale_WH(2)/2, H*1/2 - overall_familiarity_scale_WH(1)/2, W/2 + overall_familiarity_scale_WH(2)/2, H*1/2 + overall_familiarity_scale_WH(1)/2];
    Screen('PutImage', theWindow, overall_familiarity_scale, overall_familiarity_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    % Explain scale with visualization
    msgtxt = ['실제 실험 화면을 보며 연습합니다.\n\n', ...
        '준비가 완료되면 SPACE 키를 눌러 주시기 바랍니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    temp_samp_file = fullfile(basedir,'subj_music/Practice/pleasant_orig.wav');
    [temp_samp_data, temp_samp_freq] = psychwavread(temp_samp_file);
    if size(temp_samp_data,2) == 1 && padev_output.NrOutputChannels == 2
        temp_samp_data = repmat(temp_samp_data, 1, 2);
    end
    pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
    PsychPortAudio('FillBuffer', pahandle, temp_samp_data.');
    data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
    PsychPortAudio('Stop', pahandle);

    ratetype = strcmp(rating_types.alltypes, exp_scale{1});

    [lb, rb, start_center] = draw_scale(exp_scale{1}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    % Get ratings
    start_t = GetSecs;
    data.dat.trial.time_fromstart = NaN(11000,1); % ~3 min given 60Hz flip freq
    data.dat.trial.cont_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
    data.dat.trial.rating_starttime = start_t;
    data.dat.trial.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

    rec_i = 0;
    % Rate continuous music pleasure
    while true
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{1});

        % Musical Chills: press the space bar

        [x,~,~] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        Cur_Key = KbName(keyCode_E);

        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        rec_i = rec_i + 1;
        cur_t = GetSecs;
        time_fromstart(rec_i) = cur_t-start_t;
        cont_rating(rec_i) = (x-lb)./(rb-lb);
        chills_rating(rec_i) = 0;

        if cur_t - data.dat.trial.rating_starttime >= S.musicdur
            break
        end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        if iscell(Cur_Key)
            wh_ottf = contains(Cur_Key,'space');
            if any(wh_ottf)
                Cur_Key = Cur_Key(wh_ottf);
                Cur_Key = Cur_Key{1};
                Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                chills_rating(rec_i) = 2;
            end
        else
            wh_ottf = strcmp(Cur_Key,'space');
            if any(wh_ottf)
                Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                chills_rating(rec_i) = 2;
            end
        end

        [x,~,button] = GetMouse(theWindow);
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        Screen('Flip', theWindow);

    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    PsychPortAudio('Stop', pahandle);
    data.dat.trial.playing_endtime = GetSecs;
    PsychPortAudio('Close', pahandle);

    data.dat.trial.time_fromstart = time_fromstart(1:rec_i);
    data.dat.trial.cont_rating = cont_rating(1:rec_i);
    data.dat.trial.chills_rating = chills_rating(1:rec_i);

    DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);

    % 전반적인 음악적 쾌감 평가
    [lb, rb, start_center] = draw_scale(exp_scale{2}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{2});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{2});

        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    % 음악적 집중도 평가
    [lb, rb, start_center] = draw_scale(exp_scale{3}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{3});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
        
        [lb, rb, start_center] = draw_scale(exp_scale{3});
        
        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end
    
    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);
    
    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    % 음악적 친숙도 평가
    [lb, rb, start_center] = draw_scale(exp_scale{4}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{4});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
        
        [lb, rb, start_center] = draw_scale(exp_scale{4});
        
        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end
    
    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);
    
    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    %% EXERCISE2: scrambled music
    temp_samp_file = fullfile(basedir,'subj_music/Practice/pleasant_scrb.wav');
    [temp_samp_data, temp_samp_freq] = psychwavread(temp_samp_file);
    if size(temp_samp_data,2) == 1 && padev_output.NrOutputChannels == 2
        temp_samp_data = repmat(temp_samp_data, 1, 2);
    end
    pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
    PsychPortAudio('FillBuffer', pahandle, temp_samp_data.');
    data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
    PsychPortAudio('Stop', pahandle);

    ratetype = strcmp(rating_types.alltypes, exp_scale{1});

    [lb, rb, start_center] = draw_scale(exp_scale{1}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    % Get ratings
    start_t = GetSecs;
    data.dat.trial.time_fromstart = NaN(11000,1); % ~3 min given 60Hz flip freq
    data.dat.trial.cont_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
    data.dat.trial.rating_starttime = start_t;
    data.dat.trial.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

    rec_i = 0;
    % Rate continuous music pleasure
    while true
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{1});

        % Musical Chills: press the space bar

        [x,~,~] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        Cur_Key = KbName(keyCode_E);

        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        rec_i = rec_i + 1;
        cur_t = GetSecs;
        time_fromstart(rec_i) = cur_t-start_t;
        cont_rating(rec_i) = (x-lb)./(rb-lb);
        chills_rating(rec_i) = 0;

        if cur_t - data.dat.trial.rating_starttime >= S.musicdur
            break
        end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        if iscell(Cur_Key)
            wh_ottf = contains(Cur_Key,'space');
            if any(wh_ottf)
                Cur_Key = Cur_Key(wh_ottf);
                Cur_Key = Cur_Key{1};
                Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                chills_rating(rec_i) = 2;
            end
        else
            wh_ottf = strcmp(Cur_Key,'space');
            if any(wh_ottf)
                Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                chills_rating(rec_i) = 2;
            end
        end

        [x,~,button] = GetMouse(theWindow);
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        Screen('Flip', theWindow);

    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    PsychPortAudio('Stop', pahandle);
    data.dat.trial.playing_endtime = GetSecs;
    PsychPortAudio('Close', pahandle);

    data.dat.trial.time_fromstart = time_fromstart(1:rec_i);
    data.dat.trial.cont_rating = cont_rating(1:rec_i);
    data.dat.trial.chills_rating = chills_rating(1:rec_i);

    DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);

    % 전반적인 음악적 쾌감 평가
    [lb, rb, start_center] = draw_scale(exp_scale{2}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{2});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{2});

        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    % 음악적 집중도 평가
    [lb, rb, start_center] = draw_scale(exp_scale{3}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{3});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{3});

        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    % 음악적 친숙도 평가
    [lb, rb, start_center] = draw_scale(exp_scale{4}); % Getting information
    Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end

    while true % Space
        ratetype = strcmp(rating_types.alltypes, exp_scale{4});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(exp_scale{4});

        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end

    % Freeze the screen 0.5 second with red line
    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);

    freeze_t = GetSecs;
    while true
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
    end

    %% End of the exercise run
    msgtxt = ['연습 평가를 종료합니다.\n\n', ...
        'SPACE 키를 눌러 연습을 종료해주세요.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

elseif ismember(S.type, {'RATE1', 'RATE2', 'RATE3', 'RATE4'})
    msgtxt = sprintf(['본 실험의 %d 번째 ''음악 평가'' 입니다.\n\n', ...
        '음악이 나오는 동안 느껴지는 ''음악적 쾌감''을 지속적으로 평가해 주세요.\n\n', ...
        '음악이 종료된 이후에는 전반적으로 느꼈던 ''음악적 쾌감, 집중도, 친숙도''를 평가해 주세요.'], runmarker-1);
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    % explaining the rating scales
    % 음악적 쾌감 평가
    cont_pleasure_scale = imread(fullfile(basedir, 'Pictures', 'cont_pleasure.png'));
    cont_pleasure_scale_WH = size(cont_pleasure_scale);
    cont_pleasure_scale_rect = [W/2 - cont_pleasure_scale_WH(2)/2, H*1/2 - cont_pleasure_scale_WH(1)/2, W/2 + cont_pleasure_scale_WH(2)/2, H*1/2 + cont_pleasure_scale_WH(1)/2];
    Screen('PutImage', theWindow, cont_pleasure_scale, cont_pleasure_scale_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    % 음악적 집중도 평가
    overall_attention_scale = imread(fullfile(basedir, 'Pictures', 'cont_attention.png'));
    overall_attention_scale_WH = size(overall_attention_scale);
    overall_attention_scale_rect = [W/2 - overall_attention_scale_WH(2)/2, H*1/2 - overall_attention_scale_WH(1)/2, W/2 + overall_attention_scale_WH(2)/2, H*1/2 + overall_attention_scale_WH(1)/2];
    Screen('PutImage', theWindow, overall_attention_scale, overall_attention_scale_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    % 음악적 친숙도 평가
    overall_familiarity_scale = imread(fullfile(basedir, 'Pictures', 'cont_familiarity.png'));
    overall_familiarity_scale_WH = size(overall_familiarity_scale);
    overall_familiarity_rect = [W/2 - overall_familiarity_scale_WH(2)/2, H*1/2 - overall_familiarity_scale_WH(1)/2, W/2 + overall_familiarity_scale_WH(2)/2, H*1/2 + overall_familiarity_scale_WH(1)/2];
    Screen('PutImage', theWindow, overall_familiarity_scale, overall_familiarity_rect);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
end


%% SETUP: Sound Setting
% read the subject's music list files
my_music_list = filenames(fullfile(my_music_dir, '*'), 'char');

if ismember(S.type, {'RATE1', 'RATE2', 'RATE3'})

    data.my_ts = ts;
    data.run_music_order = ts.run_music_order(runmarker-1,:);
    temp_music_file = cell(1, 4);  % 각 trial에 해당하는 파일 저장
    temp_samp_data = cell(1, 4);  % 각 trial에 해당하는 데이터 저장
    temp_samp_freq = zeros(1, 4);  % 각 trial에 해당하는 샘플 주파수 저장

    for trial_num = 1:4
        temp_music_file{trial_num} = deblank(my_music_list(data.run_music_order(trial_num),:));
        [temp_samp_data{trial_num}, temp_samp_freq(trial_num)] = psychwavread(temp_music_file{trial_num});
    end

    if size(temp_samp_data{1}, 2) == 1 && padev_output.NrOutputChannels == 2
        for trial_num = 1:4
            temp_samp_data{trial_num} = repmat(temp_samp_data{trial_num}, 1, 2);
        end
    end

elseif ismember(S.type, {'RATE4'})
    % RATE4 music did not use in HEAT runs
    data.my_ts = ts;
    data.run_music_order = ts.run_music_order(6,1:2);
    temp_music_file = cell(1, 2);  % 각 trial에 해당하는 파일 저장
    temp_samp_data = cell(1, 2);  % 각 trial에 해당하는 데이터 저장
    temp_samp_freq = zeros(1, 2);  % 각 trial에 해당하는 샘플 주파수 저장

    for trial_num = 1:2
        temp_music_file{trial_num} = deblank(my_music_list(data.run_music_order(trial_num),:));
        [temp_samp_data{trial_num}, temp_samp_freq(trial_num)] = psychwavread(temp_music_file{trial_num});
    end

    if size(temp_samp_data{1}, 2) == 1 && padev_output.NrOutputChannels == 2
        for trial_num = 1:2
            temp_samp_data{trial_num} = repmat(temp_samp_data{trial_num}, 1, 2);
        end
    end
end


%% Main : Ready for experiment
if ismember(S.type, {'RATE1', 'RATE2', 'RATE3', 'RATE4'})
    
    msgtxt = ['지금부터 본 실험이 시작됩니다.\n\n', ...
        '참가자님께서는 모든 준비를 완료하신 후 SPACE 키를 눌러주시기 바랍니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    
    % MAIN : Disdaq (4 + 4 = 8 secs)
    % 4 secs : ready for start
    start_t = GetSecs;
    data.dat.runexp_starttime = start_t;
    
    msgtxt = '시작하는 중...';
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    while true
        cur_t = GetSecs;
        if cur_t - start_t >= 4
            break
        end
    end
end


%% MAIN: Experiment
% RATE1_trial1 (music 1)
exp_start = GetSecs;
data.dat.experiment_starttime = exp_start;

if ismember(S.type, {'RATE1', 'RATE2', 'RATE3'})

    for trial_num = 1:4

        pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq(trial_num), padev_output.NrOutputChannels);
        PsychPortAudio('FillBuffer', pahandle, temp_samp_data{trial_num}.');
        data.dat.playing_preptime(trial_num) = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
        PsychPortAudio('Stop', pahandle);

        ratetype = strcmp(rating_types.alltypes, main_scale{1});

        [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Get ratings
        start_t = GetSecs;
        data.dat.trial{trial_num}.music_type = data.run_music_order(trial_num);
        data.dat.trial{trial_num}.cont_pleasure_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
        data.dat.trial{trial_num}.cont_chills_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
        data.dat.trial{trial_num}.rating_starttime = start_t;
        data.dat.trial{trial_num}.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

        rec_i = 0;
        % Rate continuous music pleasure
        while true
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});

            % Musical Chills: press the space bar

            [x,~,~] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            Cur_Key = KbName(keyCode_E);

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart(rec_i) = cur_t-start_t;
            cont_rating(rec_i) = (x-lb)./(rb-lb);
            chills_rating(rec_i) = 0;

            if cur_t - data.dat.trial{trial_num}.rating_starttime >= S.musicdur
                break
            end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            if iscell(Cur_Key)
                wh_ottf = contains(Cur_Key,'space');
                if any(wh_ottf)
                    Cur_Key = Cur_Key(wh_ottf);
                    Cur_Key = Cur_Key{1};
                    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                    chills_rating(rec_i) = 2;
                end
            else
                wh_ottf = strcmp(Cur_Key,'space');
                if any(wh_ottf)
                    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                    chills_rating(rec_i) = 2;
                end
            end
            Screen('Flip', theWindow);
            
        end

        PsychPortAudio('Stop', pahandle);
        data.dat.trial{trial_num}.playing_endtime = GetSecs;
        PsychPortAudio('Close', pahandle);

        data.dat.trial{trial_num}.pleasure_play_time = time_fromstart(1:rec_i);
        data.dat.trial{trial_num}.cont_pleasure_rating = cont_rating(1:rec_i);
        data.dat.trial{trial_num}.cont_chills_rating = chills_rating(1:rec_i);


        DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);

        %% Rate overall music pleasure
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{2}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 전반적인 음악적 쾌락 정도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{2});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_pleasure_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_pleasure_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_pleasure_end >= 1.5
                break
            end
        end

        %% RATE: Overall Music Attention
        % 음악적 집중도 평가
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{3}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 전반적인 집중도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{3});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_attention_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_attention_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_attention_end >= 1.5
                break
            end
        end

        %% RATE: Overall Music Familiarity
        % 음악적 친숙도 평가
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{4}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 친숙함 정도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{4});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_familiar_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_familiar_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_familiar_end >= 3
                break
            end
        end

        cur_t = GetSecs;
        data.dat.experiment_endtime = cur_t;
        data.dat.experiment_total_dur = cur_t - exp_start;

        save(data.datafile, '-append', 'data');

        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('Flip', theWindow); % clear screen
    end

% for RATE4
elseif ismember(S.type, {'RATE4'})

    for trial_num = 1:2

        pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq(trial_num), padev_output.NrOutputChannels);
        PsychPortAudio('FillBuffer', pahandle, temp_samp_data{trial_num}.');
        data.dat.playing_preptime(trial_num) = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
        PsychPortAudio('Stop', pahandle);

        ratetype = strcmp(rating_types.alltypes, main_scale{1});

        [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Get ratings
        start_t = GetSecs;
        data.dat.trial{trial_num}.music_type = data.run_music_order(trial_num);
        data.dat.trial{trial_num}.cont_pleasure_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
        data.dat.trial{trial_num}.cont_chills_rating = NaN(11000,1); % ~3 min given 60Hz flip freq
        data.dat.trial{trial_num}.rating_starttime = start_t;
        data.dat.trial{trial_num}.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

        rec_i = 0;
        % Rate continuous music pleasure
        while true
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, orange, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});

            % Musical Chills: press the space bar

            [x,~,~] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            Cur_Key = KbName(keyCode_E);

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart(rec_i) = cur_t-start_t;
            cont_rating(rec_i) = (x-lb)./(rb-lb);
            chills_rating(rec_i) = 0;

            if cur_t - data.dat.trial{trial_num}.rating_starttime >= S.musicdur
                break
            end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            if iscell(Cur_Key)
                wh_ottf = contains(Cur_Key,'space');
                if any(wh_ottf)
                    Cur_Key = Cur_Key(wh_ottf);
                    Cur_Key = Cur_Key{1};
                    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                    chills_rating(rec_i) = 2;
                end
            else
                wh_ottf = strcmp(Cur_Key,'space');
                if any(wh_ottf)
                    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                    chills_rating(rec_i) = 2;
                end
            end
            Screen('Flip', theWindow);

        end

        PsychPortAudio('Stop', pahandle);
        data.dat.trial{trial_num}.playing_endtime = GetSecs;
        PsychPortAudio('Close', pahandle);

        data.dat.trial{trial_num}.pleasure_play_time = time_fromstart(1:rec_i);
        data.dat.trial{trial_num}.cont_pleasure_rating = cont_rating(1:rec_i);
        data.dat.trial{trial_num}.cont_chills_rating = chills_rating(1:rec_i);

        DrawFormattedText(theWindow, double(' '), 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);

        %% Rate overall music pleasure
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{2}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 전반적인 음악적 쾌락 정도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{2});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_pleasure_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_pleasure_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_pleasure_end >= 1.5
                break
            end
        end

        %% Music Attention
        % 음악적 집중도 평가
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{3}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 전반적인 집중도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{3});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_attention_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_attention_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_attention_end >= 1.5
                break
            end
        end

        %% Rate music familiarity
        % Initial position
        [lb, rb, start_center] = draw_scale(main_scale{4}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Rating start
        while true
            msgtxt = '방금 들으신 곡의 친숙함 정도를 평가해주세요.';
            DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{4});

            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            data.dat.trial{trial_num}.overall_familiar_rating = (x-lb)./(rb-lb);
            data.dat.trial{trial_num}.overall_familiar_end = GetSecs;

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        % Freeze the screen 0.5 second with red line
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);

        freeze_t = GetSecs;
        while true
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end

        DrawFormattedText(theWindow, double(' '), 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);

        while true
            if GetSecs - data.dat.trial{trial_num}.overall_familiar_end >= 3
                break
            end
        end

        cur_t = GetSecs;
        data.dat.experiment_endtime = cur_t;
        data.dat.experiment_total_dur = cur_t - exp_start;

        save(data.datafile, '-append', 'data');

        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('Flip', theWindow); % clear screen
    end
end


%% Closing screen
if ismember(S.type, {'RATE1', 'RATE2', 'RATE3', 'RATE4'})

    msgtxt = '세션이 끝났습니다.\n\n참가자님은 실험자를 불러주세요.\n\n세션을 마치려면, 실험자는 SPACE 키를 눌러주세요.';
    DrawFormattedText(theWindow, double(msgtxt), 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    ShowCursor;
    sca;
    Screen('CloseAll');

else
    ShowCursor;
    sca;
    Screen('CloseAll');

end
