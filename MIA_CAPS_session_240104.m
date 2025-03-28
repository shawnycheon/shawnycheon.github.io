%% SETUP : Basic parameter
clear;
close all;
Screen('CloseAll');

rng('shuffle');

global basedir subjID subjnum runtype theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_middle anchor_lms korean alpnum space special bgcolor white orange red;

test_mode = false;
% test_mode = true;

if test_mode
    USE_BIOPAC = false;
    show_cursor = false;
    screen_mode = 'full';
    disp('***** TEST mode *****');
else
    USE_BIOPAC = true;
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
        outputdev.DeviceName = 'Genie의 AirPods Max'; %'내장 출력'
        %         outputdev.DeviceName = 'MacBook Pro 스피커'; %'내장 출력'
    case 'Cocoanui-iMac-2.local' % 행동 실험실 MAC
        basedir = '/Users/deipp/Dropbox/Project/MIA/MIA_codes';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
    case 'cnirui-Mac-Pro.local'
        basedir = '/Users/cocoan/Dropbox/Project/MIA/MIA_codes_sync';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '내장 출력';
end

cd(basedir);
addpath(genpath(basedir));

exp_scale = {'cont_int_vas', 'overall_alertness', 'cont_threat_vas', 'cont_pleasure_vas', 'lms', 'overall_sound'}; % 수정 필요
main_scale = {'cont_int_vas_exp', 'line', 'cont_sound_volume'}; % 수정 필요


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
            mia_generate_trial_sequence(basedir, subjID); % make ts
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
markerfile = fullfile(basedir, 'MIA_CAPS_run_data.mat');
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
savedir = fullfile(basedir, 'Data', 'CAPS');

nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = subjID;
data.datafile = fullfile(savedir, sprintf('%s_%s_run%.2d_%s_CAPS.mat', subjID, subjtime, runmarker, runs{runmarker}));
data.version = 'MIA_cocoanlab_20240104';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

caps_wait_stim = 30;
caps_stim_deliver = caps_wait_stim + 20;
caps_stim_remove = caps_stim_deliver + 20;

save(data.datafile, 'data');


%% SETUP : Paradigm
S.type = runs{runmarker};
S.dur = durs(runmarker);
if test_mode; S.dur = S.dur ./ 60; end

runtype = S.type;
data.dat.type = S.type;
data.dat.duration = S.dur;
data.dat.exp_scale = exp_scale;
data.dat.main_scale = main_scale;

% add the music order number

rating_types = call_ratingtypes_caps;

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

anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;
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
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
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


%% SETUP: Input setting (for Mac and test)

if test_mode
    devices = PsychHID('Devices');
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(1).index; % MODIFY if you need
    Par_key = devices_keyboard(1).index;
    Scan_key = devices_keyboard(1).index; % should modify for the scanner
elseif ~test_mode
    devices = PsychHID('Devices');
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(1).index; % MODIFY if you need
    Par_key = devices_keyboard(1).index;
    Scan_key = devices_keyboard(2).index; % should modify for the scanner
end

if ismember(S.type, {'TEST1', 'MUSIC1', 'CAPS1', 'CAPS2'})
    InitializePsychSound;
    padev = PsychPortAudio('GetDevices');
    padev_output = padev([padev.NrOutputChannels] > 0);
    padev_output = padev_output(strcmp({padev_output.DeviceName}, outputdev.DeviceName) & strcmp({padev_output.HostAudioAPIName}, outputdev.HostAudioAPIName));
end


%% Biopack Python setting
PATH = getenv('PATH');
if isempty(strfind(PATH,':/Library/Frameworks/Python.framework/Versions/3.7/bin'))
    setenv('PATH', [PATH ':/Library/Frameworks/Python.framework/Versions/3.7/bin']);
end


%% MAIN : Task Explaining

switch S.type

    case 'REST1'
        msgtxt = ['안녕하세요, 참가자님. 연구에 참여해 주셔서 감사합니다.\n', ...
            '본 촬영은 다음과 같은 총 5개의 과제로 구성되어 있으며, 약 1시간 소요됩니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        inst_img = imread(fullfile(basedir, 'Pictures', 'Instruction_002.png'));
        inst_img_WH = size(inst_img);
        inst_img_WH_resized = inst_img_WH .* (W*3/4 / inst_img_WH(2));
        inst_img_rect = [W/2 - inst_img_WH_resized(2)/2, H*3/4 - inst_img_WH_resized(1)/2, W/2 + inst_img_WH_resized(2)/2, H*3/4 + inst_img_WH_resized(1)/2];
        Screen('PutImage', theWindow, inst_img, inst_img_rect);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['참가자님은 촬영에 앞서 최대한 편한 자세를 취하신 후 실험이 끝날 때까지 유지해 주세요.\n' ...
            '또한, 머리를 움직이거나 잠에 들지 않도록 각별히 유의해주시기 바랍니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['먼저, 참가자님의 머리 위치 파악을 위한 예비 촬영을 진행하겠습니다.\n', ...
            '참가자님은 화면의 + 표시를 응시하면서 편안히 계시면 됩니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = '주의: 스캐너 소음이 발생합니다!!!';
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = '+';
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Finish testing
        msgtxt = '예비 촬영이 완료되었습니다.';
        Screen('TextSize', theWindow, fontsize);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/4), white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['본 촬영은 ''휴지기 촬영'' 입니다.\n', ...
            '해당 촬영 동안 참가자님은 척도 위에 현재 느껴지는 통증의 세기를 지속적으로 평가해주시면 됩니다.\n', ...
            '촬영 세션이 끝나면 간단한 질문 및 평가가 이루어집니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(1/4), white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Check the pain rating scale
        overall_rate_scale = imread(fullfile(basedir, 'Pictures', 'gLMS_unidirectional_rating_scale.jpg'));
        [s1, s2, s3] = size(overall_rate_scale);
        overall_rate_scale_texture = Screen('MakeTexture', theWindow, overall_rate_scale);
        Screen('DrawTexture', theWindow, overall_rate_scale_texture, [0 0 s2 s1],[0 0 W H]);
        Screen('PutImage', theWindow, overall_rate_scale); %show the overall rating scale
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        % Explain scale with visualization
        msgtxt = '참가자님은 충분히 평가 방법을 연습하신 후, 연습이 끝나면 버튼을 눌러 주시기 바랍니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', 150, orange, [], [], [], 2);
        ratetype = strcmp(rating_types.alltypes, exp_scale{1});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
        [lb, rb, start_center] = draw_scale(exp_scale{1});
        Screen('Flip', theWindow);
        
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        [lb, rb, start_center] = draw_scale(exp_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Get ratings
        while true % Button
            ratetype = strcmp(rating_types.alltypes, main_scale{1});
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});
            
            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
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

    case 'TEST1'

        msgtxt = ['본 촬영은 ''음향 테스트 촬영'' 입니다.\n', ...
            '해당 촬영 동안, 참가자님은 트랙볼을 굴려 음향 크기를 적절히 조절해 주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['만약 촬영이 진행되는 도중 음악이 들리지 않는 경우,\n', ...
            '참가자님께서 구두로 말씀해주시면 촬영을 중단하고 음향 테스트를 한번 더 진행하겠습니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end


    case 'MUSIC1'

        msgtxt = ['본 촬영은 ''음악 감상 촬영'' 입니다.\n', ...
            '해당 촬영 동안, 참가자님은 + 표시를 바라보며 최대한 음악에 집중해주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['만약 촬영이 진행되는 도중 음악이 들리지 않는 경우,\n', ...
            '참가자님께서 구두로 말씀해주시면 촬영을 중단하고 음향 테스트를 한번 더 진행하겠습니다.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end
        

    case 'CAPS1'
        msgtxt = ['본 촬영은 ''매운맛 자극 및 음악 감상 촬영'' 입니다.\n', ...
            '참가자님께서는 전달 받으신 매운맛에 대한 통증 세기를 지속적으로 평가해주세요.\n', ...
            '단, 최대한 음악에 집중할 수 있도록 노력해주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['본 촬영에 앞서 자극 종이 전달을 연습해 보겠습니다.\n', ...
            '참가자님 오른손에 쥐어진 빈 종이를 입 안에 전달해주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Check the pain rating scale
        overall_rate_scale = imread(fullfile(basedir, 'Pictures', 'gLMS_unidirectional_rating_scale.jpg'));
        [s1, s2, s3] = size(overall_rate_scale);
        overall_rate_scale_texture = Screen('MakeTexture', theWindow, overall_rate_scale);
        Screen('DrawTexture', theWindow, overall_rate_scale_texture, [0 0 s2 s1],[0 0 W H]);
        Screen('PutImage', theWindow, overall_rate_scale); %show the overall rating scale
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        % Explain scale with visualization
        msgtxt = '참가자님은 충분히 평가 방법을 연습하신 후, 연습이 끝나면 버튼을 눌러 주시기 바랍니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
        ratetype = strcmp(rating_types.alltypes, exp_scale{1});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
        [lb, rb, start_center] = draw_scale(exp_scale{1});
        Screen('Flip', theWindow);
        
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        [lb, rb, start_center] = draw_scale(exp_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Get ratings
        while true % Button
            ratetype = strcmp(rating_types.alltypes, main_scale{1});
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});
            
            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
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

        Screen('TextSize', theWindow, fontsize);
        msgtxt = ['참가자님 오른손에 매운맛 자극 종이를 전달 드리겠습니다.\n', ...
            '해당 촬영 동안, 참가자님은 사전에 안내 받은 내용을 바탕으로 화면의 지시사항을 따라주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

    case 'CAPS2'
        msgtxt = ['본 촬영은 ''매운맛 자극 및 음악 감상 촬영'' 입니다.\n', ...
            '참가자님께서는 전달 받으신 매운맛에 대한 통증 세기를 지속적으로 평가해주세요.\n', ...
            '단, 최대한 음악에 집중할 수 있도록 노력해주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Check the pain rating scale
        overall_rate_scale = imread(fullfile(basedir, 'Pictures', 'gLMS_unidirectional_rating_scale.jpg'));
        [s1, s2, s3] = size(overall_rate_scale);
        overall_rate_scale_texture = Screen('MakeTexture', theWindow, overall_rate_scale);
        Screen('DrawTexture', theWindow, overall_rate_scale_texture, [0 0 s2 s1],[0 0 W H]);
        Screen('PutImage', theWindow, overall_rate_scale); %show the overall rating scale
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        % Explain scale with visualization
        msgtxt = '참가자님은 충분히 평가 방법을 연습하신 후, 연습이 끝나면 버튼을 눌러 주시기 바랍니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
        ratetype = strcmp(rating_types.alltypes, exp_scale{1});
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
        [lb, rb, start_center] = draw_scale(exp_scale{1});
        Screen('Flip', theWindow);
        
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            [x,~,button] = GetMouse(theWindow);
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        end

        [lb, rb, start_center] = draw_scale(exp_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        % Get ratings
        while true % Button
            ratetype = strcmp(rating_types.alltypes, main_scale{1});
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});
            
            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
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

        Screen('TextSize', theWindow, fontsize);
        msgtxt = ['참가자님 오른손에 매운맛 자극 종이를 전달 드리겠습니다.\n', ...
            '해당 촬영 동안, 참가자님은 사전에 안내 받은 내용을 바탕으로 화면의 지시사항을 따라주세요.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

end


%% SETUP: Sound Setting (for, MUSIC1 & CAPS1,2)
% Listening Audio Setting 및 음원 불러오는 세팅

my_music_list = filenames(fullfile(my_music_dir, '*'), 'char');

if ismember(S.type, {'MUSIC1', 'CAPS1', 'CAPS2'})

    switch S.type
        case 'MUSIC1'
            data.music_order = ts.run_music_order(4,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
        case 'CAPS1'
            data.music_order = ts.caps_music_order(1,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
        case 'CAPS2'
            data.music_order = ts.caps_music_order(2,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
    end
    
    temp_samp_data = cat_all;
    if size(temp_samp_data,2) == 1 && padev_output.NrOutputChannels == 2
        temp_samp_data = repmat(temp_samp_data, 1, 2);
    end
    pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
    PsychPortAudio('FillBuffer', pahandle, temp_samp_data.');
    data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
    PsychPortAudio('Stop', pahandle);
end


%% Main : Ready for scan
if ismember(S.type, {'REST1', 'TEST1', 'MUSIC1', 'CAPS1', 'CAPS2'})
    Screen('TextSize', theWindow, fontsize);

    msgtxt = ['실험자는 모든 세팅 및 참가자님의 준비가 완료되었는지 확인하기 바랍니다.\n', ...
        '준비가 완료되면 실험자는 SPACE 키를 눌러 주시기 바랍니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = ['지금부터 본 실험이 시작됩니다.\n', ...
        '주의: 촬영 중 머리를 움직이거나 잠에 들지 않도록 유의해주시기 바랍니다!!!'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    %% MAIN : Sync (S key)

    msgtxt = '스캔을 시작합니다. (S 키)';
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true
        [~,~,keyCode_S] = KbCheck(Scan_key);
        if keyCode_S(KbName('s')); break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

     %% MAIN : Disdaq (2 + 8 + 5 = 15 secs)

    % 2 secs : scanning...
    start_t = GetSecs;
    data.dat.runscan_starttime = start_t;

    msgtxt = '시작하는 중...';
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
    Screen('Flip', theWindow);

    while true
        cur_t = GetSecs;
        if cur_t - start_t >= 2
            break
        end
    end

   % 8 secs : BIOPAC
    if USE_BIOPAC
        bio_trigger_range = num2str(runmarker * 0.2 + 4);
        command = 'python3 labjack.py ';
        full_command = [command bio_trigger_range];
        data.dat.biopac_start_trigger_s = GetSecs;
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);

        unix(full_command)
        data.dat.biopac_start_trigger_e = GetSecs;
        data.dat.biopac_start_trigger_dur = data.dat.biopac_start_trigger_e - data.dat.biopac_start_trigger_s;
    end

    while true
        cur_t = GetSecs;
        if cur_t - start_t >= 10
            break
        end
    end

    % 5 sec : previous '+'
    msgtxt = '+';
    Screen('TextSize', theWindow, 60);
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
    Screen('Flip', theWindow);

    while true
        cur_t = GetSecs;
        if cur_t - start_t >= 15
            break
        end
    end

end


%% MAIN : Experiment
start_t = GetSecs;
data.dat.run_starttime = start_t;

switch S.type

    case 'REST1'
        % Basic setting
        rec_i = 0;
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
        time_fromstart = NaN(46800,1); % ~11 min given 60Hz flip freq
        cont_rating = NaN(46800,1); % ~11 min given 60Hz flip freq
        data.dat.rating_starttime = GetSecs;
        while true
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{1});

            [x,~,~] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart(rec_i) = cur_t-start_t;
            cont_rating(rec_i) = (x-lb)./(rb-lb);

            if cur_t - start_t >= S.dur
                break
            end
            Screen('TextSize', theWindow, fontsize);
            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end
        data.dat.time_fromstart = time_fromstart(1:rec_i);
        data.dat.cont_rating = cont_rating(1:rec_i);
        Screen('TextSize', theWindow, fontsize);


    case 'TEST1'
        Screen('TextSize', theWindow, fontsize);

        %% test: Both Sides
        msgtxt = '음원 테스트를 진행합니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), orange, [], [], [], 2);
        Screen('Flip', theWindow);

        temp_samp_file = fullfile(basedir,'subj_music/Practice/pleasant_orig.wav');
        [temp_samp_data, temp_samp_freq] = psychwavread(temp_samp_file);
        if size(temp_samp_data,2) == 1 && padev_output.NrOutputChannels == 2
            temp_samp_data = repmat(temp_samp_data, 1, 2);
        end
        pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
        PsychPortAudio('FillBuffer', pahandle, temp_samp_data.');
        data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
        PsychPortAudio('Stop', pahandle);

        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Basic setting
        rec_i = 0;
        ratetype = strcmp(rating_types.alltypes, main_scale{3});

        [lb, rb, start_center] = draw_scale(main_scale{3}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        data.dat.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

        % Get ratings
        time_fromstart = NaN(7200,1); % ~2 min given 60Hz flip freq
        cont_volume_rating = NaN(7200,1); % ~2 min given 60Hz flip freq
        continuous_rating_start= GetSecs;
        data.dat.rating_starttime = continuous_rating_start;
        while true
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

            [lb, rb, start_center] = draw_scale(main_scale{3});

            [x,~,~] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart(rec_i) = cur_t-start_t;
            cont_volume_rating(rec_i) = (x-lb)./(rb-lb);

            if cur_t - start_t >= 60
                break
            end
            Screen('TextSize', theWindow, fontsize);
            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end
        data.dat.time_fromstart = time_fromstart(1:rec_i);
        data.dat.cont_volume_rating = cont_volume_rating(1:rec_i);
        Screen('TextSize', theWindow, fontsize);

        PsychPortAudio('Stop', pahandle);
        data.dat.playing_endtime = GetSecs;
        continuous_rating_end = GetSecs;
        continuous_rating_duration = continuous_rating_end - continuous_rating_start;
        PsychPortAudio('Close');

        data.dat.continuous_rating_end = continuous_rating_end;
        data.dat.continuous_rating_duration = continuous_rating_duration;

        save(data.datafile, '-append', 'data');
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen


        %% test: Left only
        Screen('TextSize', theWindow, fontsize);
        msgtxt = '다음은 왼쪽 이어폰에서만 음악이 나옵니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), orange, [], [], [], 2);
        Screen('Flip', theWindow);

        temp_samp_file = fullfile(basedir,'subj_music/Practice/pleasant_orig.wav');
        [temp_samp_data, temp_samp_freq] = psychwavread(temp_samp_file);

        if padev_output.NrOutputChannels == 2
            soundLeft = temp_samp_data(:, 1)';
            soundRight = zeros(size(soundLeft));
        end

        pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
        PsychPortAudio('FillBuffer', pahandle, [soundLeft; soundRight]);
        data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
        PsychPortAudio('Stop', pahandle);

        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = '왼쪽 이어폰에서만 음악이 나오는 중입니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);

        % Music start
        rec_i = 0;
        time_fromstart2 = NaN(3600,1); % ~13 min given 60Hz flip freq
        data.dat.playing_starttime2 = PsychPortAudio('Start', pahandle, 1, 0, 1);
        while true
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart2(rec_i) = cur_t-data.dat.playing_starttime2;

            if cur_t - data.dat.playing_starttime2 >= 20
                break
            end
        end
        data.dat.time_fromstart2 = time_fromstart2(1:rec_i);

        PsychPortAudio('Stop', pahandle);
        data.dat.playing_endtime = GetSecs;
        Screen('TextSize', theWindow, fontsize);

        
        %% test: Right only
        msgtxt = '다음은 오른쪽 이어폰에서만 음악이 나옵니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), orange, [], [], [], 2);
        Screen('Flip', theWindow);

        temp_samp_file = fullfile(basedir,'subj_music/Practice/pleasant_orig.wav');
        [temp_samp_data, temp_samp_freq] = psychwavread(temp_samp_file);

        if padev_output.NrOutputChannels == 2
            soundRight = temp_samp_data(:, 1)';
            soundLeft = zeros(size(soundRight));
        end
        pahandle = PsychPortAudio('Open', padev_output.DeviceIndex, 1, 0, temp_samp_freq, padev_output.NrOutputChannels);
        PsychPortAudio('FillBuffer', pahandle, [soundLeft; soundRight]);
        data.dat.playing_preptime = PsychPortAudio('Start', pahandle, 1, 0, 1, GetSecs);
        PsychPortAudio('Stop', pahandle);

        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = '오른쪽 이어폰에서만 음악이 나오는 중입니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);

        % Music start
        rec_i = 0;
        time_fromstart3 = NaN(3600,1); % ~1 min given 60Hz flip freq
        data.dat.playing_starttime3 = PsychPortAudio('Start', pahandle, 1, 0, 1);
        while true
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart3(rec_i) = cur_t-data.dat.playing_starttime3;

            if cur_t - data.dat.playing_starttime3 >= 20
                break
            end
        end
        data.dat.time_fromstart3 = time_fromstart3(1:rec_i);

        PsychPortAudio('Stop', pahandle);
        data.dat.playing_endtime3 = GetSecs;
        PsychPortAudio('Close');
        Screen('TextSize', theWindow, fontsize);

        msgtxt = '음향 테스트 촬영을 종료합니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end


    case 'MUSIC1'

        msgtxt = '+';
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);

        % Music start
        rec_i = 0;
        time_fromstart = NaN(46800,1); % ~13 min given 60Hz flip freq
        data.dat.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);
        while true
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

            rec_i = rec_i + 1;
            cur_t = GetSecs;
            time_fromstart(rec_i) = cur_t-data.dat.playing_starttime;

            if cur_t - data.dat.playing_starttime >= S.dur
                break
            end
        end
        data.dat.time_fromstart = time_fromstart(1:rec_i);

        PsychPortAudio('Stop', pahandle);
        data.dat.playing_endtime = GetSecs;
        PsychPortAudio('Close');
        Screen('TextSize', theWindow, fontsize);

        save(data.datafile, '-append', 'data');


    case {'CAPS1', 'CAPS2'}
        rec_i = 0;

        ratetype = strcmp(rating_types.alltypes, main_scale{1});

        [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        continuous_rating_start = GetSecs;
        data.dat.continuous_rating_start = continuous_rating_start;
        while true
            if GetSecs - continuous_rating_start < caps__stim
                msgtxt = '잠시만 기다려주세요';
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.caps_stim_deliver_start = GetSecs;

            elseif GetSecs - continuous_rating_start < caps_stim_deliver
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('자극을 전달하세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.caps_stim_deliver_end = GetSecs;

            elseif GetSecs - continuous_rating_start < caps_stim_deliver + 2
                Screen('TextSize', theWindow, 45);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.caps_stim_remove_start = GetSecs;

            elseif GetSecs - continuous_rating_start < caps_stim_remove
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('자극을 제거하고, 입을 벌린 상태를 유지해주세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.caps_stim_remove_end = GetSecs;

            elseif GetSecs - continuous_rating_start < caps_stim_remove + 5
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('입을 닫고 혀를 입 천장 위에 고정해주세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.caps_stim_remove_final = GetSecs;

            else
                % music play + pain continuous rating
                ratetype = strcmp(rating_types.alltypes, main_scale{1});

                [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
                Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen
                Screen('TextSize', theWindow, 60);

                % Initial position
                if start_center
                    SetMouse((rb+lb)/2,H/2); % set mouse at the center
                else
                    SetMouse(lb,H/2); % set mouse at the left
                end

                data.dat.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

                % Get ratings
                time_fromstart = NaN(46800,1); % ~13 min given 60Hz flip freq
                cont_rating = NaN(46800,1); % ~13 min given 60Hz flip freq
                data.dat.rating_starttime = GetSecs;
                while true
                    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

                    [lb, rb, start_center] = draw_scale(main_scale{1});

                    [x,~,~] = GetMouse(theWindow);
                    if x < lb; x = lb; SetMouse(lb,H/2); elseif x > rb; x = rb; SetMouse(rb,H/2); end
                    [~,~,keyCode_E] = KbCheck(Exp_key);
                    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

                    rec_i = rec_i + 1;
                    cur_t = GetSecs;
                    time_fromstart(rec_i) = cur_t-data.dat.playing_starttime;
                    cont_rating(rec_i) = (x-lb)./(rb-lb);

                    if cur_t - data.dat.playing_starttime >= S.dur
                        break
                    end

                    Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                end
                data.dat.time_fromstart = time_fromstart(1:rec_i);
                data.dat.cont_rating = cont_rating(1:rec_i);

                PsychPortAudio('Stop', pahandle);
                data.dat.playing_endtime = GetSecs;
                continuous_rating_end = GetSecs;
                continuous_rating_duration = continuous_rating_end - continuous_rating_start;
                PsychPortAudio('Close');

                data.dat.caps_stim_deliver_dur = data.dat.caps_stim_deliver_end - data.dat.caps_stim_deliver_start;
                data.dat.caps_stim_remove_dur = data.dat.caps_stim_remove_end - data.dat.caps_stim_remove_start;

                data.dat.continuous_rating_end = continuous_rating_end;
                data.dat.continuous_rating_duration = continuous_rating_duration;

                save(data.datafile, '-append', 'data');
                break
            end
        end
end

Screen('Flip', theWindow); % clear screen
cur_t = GetSecs;
data.dat.experiment_endtime = cur_t;
data.dat.experiment_total_dur = cur_t - start_t;

% 5 secs for after-task spare time
msgtxt = '+';
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
Screen('Flip', theWindow);
end_t = GetSecs;
while true % Space
    cur_t = GetSecs;
    if cur_t - end_t >= 5
        break
    end
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end
Screen('TextSize', theWindow, fontsize);


if USE_BIOPAC %end BIOPAC
    bio_trigger_range = num2str(runmarker * 0.2 + 1);
    command = 'python3 labjack.py ';
    full_command = [command bio_trigger_range];
    
    data.dat.biopac_end_trigger_s = GetSecs;
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    unix(full_command)
    
    data.dat.biopac_end_trigger_e = GetSecs;
    data.dat.biopac_end_trigger_dur = data.dat.biopac_end_trigger_e - data.dat.biopac_end_trigger_s;
end

cur_t = GetSecs;
data.dat.runscan_endtime = cur_t;
data.dat.scan_total_dur = cur_t - start_t;

save(data.datafile, '-append', 'data');


%% ==================================================================================================================================
%% MAIN : Postrun questionnaire
all_start_t = GetSecs;
data.dat.postrun_rating_timestamp = all_start_t;
ratestim = strcmp(rating_types.postallstims, S.type);
scales = rating_types.postalltypes{ratestim};

Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('TextSize', theWindow, fontsize);
Screen('Flip', theWindow); % clear screen

% Going through each scale
for scale_i = 1:numel(scales)
    
    % First introduction
    if scale_i == 1

        msgtxt = '잠시 후 질문들이 제시될 것입니다. 참가자께서는 잠시 기다려주시기 바랍니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        start_t = GetSecs;
        while true
            cur_t = GetSecs;
            if cur_t - start_t >= postrun_start_t
                break
            end
        end
        
    end
    
    % Parse scales and basic setting
    scale = scales{scale_i};
    
    [lb, rb, start_center] = draw_scale(scale);
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    
    start_t = GetSecs;
    data.dat = setfield(data.dat, sprintf('%s_timestamp', scale), start_t);
    
    rec_i = 0;
    ratetype = strcmp(rating_types.alltypes, scale);
    
    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end
    
    % Get ratings
    while true % Button
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

        [lb, rb, start_center] = draw_scale(scale);
        
        [x,~,button] = GetMouse(theWindow);
        if x < lb; x = lb; elseif x > rb; x = rb; end
        if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
    end
    
    end_t = GetSecs;
    data.dat = setfield(data.dat, sprintf('%s_rating', scale), (x-lb)./(rb-lb));
    data.dat = setfield(data.dat, sprintf('%s_RT', scale), end_t - start_t);

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
    
    if scale_i == numel(scales)

        msgtxt = '질문이 끝났습니다.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        start_t = GetSecs;
        while true
            cur_t = GetSecs;
            if cur_t - start_t >= postrun_end_t
                break
            end
        end
        
    end
    
end

all_end_t = GetSecs;
data.dat.postrun_total_RT = all_end_t - all_start_t;

save(data.datafile, '-append', 'data');


if strcmp(S.type, 'CAPS1')
    msgtxt = ['참가자님의 오른손에 설탕 종이를 전달드리겠습니다.\n', ...
        '설탕을 혀 위에 묻힌 뒤 녹여 주세요.\n', ...
        '혀의 통증이 완전히 사라지면 연구자에게 말씀해주세요.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = ['본 촬영은 ''구조 촬영'' 입니다.\n', ...
        '해당 촬영 동안, 참가자님은 화면의 ''+'' 표시를 응시하면서 편안히 계시면 됩니다.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = ['지금부터 본 실험이 시작되며 스캐너 소음이 발생합니다.\n', ...
        '주의: 촬영 중 머리를 움직이지 않도록 유의해주시기 바랍니다!!!'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = '+';
    Screen('TextSize', theWindow, 60);
    DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end
    Screen('TextSize', theWindow, fontsize);

end

%% Closing screen

msgtxt = ['세션이 끝났습니다.\n', ...
    '참가자님께서는 눈을 감아주시길 바랍니다.\n', ...
    '실험자는 SPACE 키를 눌러 세션을 종료해 주세요.'];
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
Screen('Flip', theWindow);
while true % Space
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end

ShowCursor;
sca;
Screen('CloseAll');


%% Update markers and finish experiment

if runmarker < size(marker_mat,2)
    runmarker = runmarker + 1;
elseif runmarker == size(marker_mat,2)
    runmarker = 1;
end

marker_mat(subjnum, :) = false;
marker_mat(subjnum, runmarker) = true;

save(markerfile, '-append', 'marker_mat');

disp('Done');
