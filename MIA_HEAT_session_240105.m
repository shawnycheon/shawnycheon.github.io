%% SETUP : Basic parameter
clear;
close all;
Screen('CloseAll');

rng('shuffle');

global basedir subjID subjnum runtype theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_middle korean alpnum space special bgcolor white orange red;

test_mode = false;
% test_mode = true;

if test_mode
    USE_BIOPAC = false;
    show_cursor = false;
    expt_param.Pathway = false;
    screen_mode = 'full';
    disp('***** TEST mode *****');
elseif ~test_mode
    USE_BIOPAC = true;
    show_cursor = false;
    expt_param.Pathway = true;
    screen_mode = 'full';
    disp('***** EXPERIMENT mode *****');
end

ismacbook = false;
[~, hostname] = system('hostname');
switch strtrim(hostname)
    case 'sehwanui-MacBookPro.local'
        basedir = '/Users/shawn/WORK/test/MIA_code';
        ismacbook = true;
        if test_mode
            outputdev.HostAudioAPIName = 'Core Audio';
            outputdev.DeviceName = 'MacBook Pro ³»Àå ½ºÇÇÄ¿'; %'?´ì?? ì¶???'
        elseif ~test_mode
            outputdev.HostAudioAPIName = 'Core Audio';
            outputdev.DeviceName = 'MacBook Pro ³»Àå ½ºÇÇ';
        end
    case 'euijin-macbookpro.local'
        basedir = '/Users/euijin/Dropbox/Project/MIA/MIA_codes_sync';
        ismacbook = true;
        if test_mode
            outputdev.HostAudioAPIName = 'Core Audio';
            outputdev.DeviceName = 'MacBook Pro ?¤í?¼ì»¤'; %'?´ì?? ì¶???'
        elseif ~test_mode
            outputdev.HostAudioAPIName = 'Core Audio';
            outputdev.DeviceName = 'MacBook Pro ?¤í?¼ì»¤';
        end
    case 'Cocoanui-iMac-2.local' % ???? ?¤í???? MAC
        basedir = '/Users/deipp/Dropbox/Project/MIA/MIA_codes_sync';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '?´ì?? ì¶???';
    case 'cnirui-Mac-Pro.local'
        basedir = '/Users/cocoan/Dropbox/Project/MIA/MIA_codes_sync';
        outputdev.HostAudioAPIName = 'Core Audio';
        outputdev.DeviceName = '?´ì?? ì¶???';
end

cd(basedir);
addpath(genpath(basedir));

exp_scale = {'cont_int_vas', 'overall_alertness', 'cont_threat_vas', 'cont_pleasure_vas', 'overall_sound'}; % ???? ????
main_scale = {'cont_int_vas_exp', 'line', 'cont_sound_volume'}; % ???? ????


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
markerfile = fullfile(basedir, 'MIA_HEAT_run_data.mat');
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
savedir = fullfile(basedir, 'Data', 'HEAT');

nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = subjID;
data.datafile = fullfile(savedir, sprintf('%s_%s_run%.2d_%s_HEAT.mat', subjID, subjtime, runmarker, runs{runmarker}));
data.version = 'MIA_HEAT_cocoanlab_20240105';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

ip = '192.168.0.3'; %     ip = '192.168.0.3';
port = 20121;

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
rating_types = call_ratingtypes_heat;

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
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('ì½?'), lb1-30, H/2+scale_W+40, bgcolor);
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

if ismember(S.type, {'TEST2', 'MUSIC2', 'HEAT2', 'HEAT3', 'HEAT4'})
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

    case 'REST2'
        msgtxt = ['???????¸ì??, ì°¸ê?????. ?°êµ¬?? ì°¸ì?¬í?? ì£¼ì???? ê°??¬í?©ë????.\n', ...
            'ë³? ì´¬ì???? ?¤ì??ê³? ê°??? ì´? 6ê°??? ê³¼ì??ë¡? êµ¬ì?±ë???? ???¼ë©°, ?? 1??ê°? 30ë¶? ?????©ë????.\n'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        inst_img = imread(fullfile(basedir, 'Pictures', 'Instruction_003.png'));
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

        msgtxt = ['ì°¸ê??????? ì´¬ì???? ???? ìµ????? ?¸í?? ???¸ë?? ì·¨í???? ??, ?¤í???? ???? ??ê¹?ì§? ??ì§??´ì£¼??ê¸? ë°??¼ë©°,\n' ...
            'ë¨¸ë¦¬ë¥? ??ì§??´ê±°?? ???? ?¤ì? ????ë¡? ê°?ë³??? ?????´ì£¼??ê¸? ë°???????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['ë¨¼ì??, ì°¸ê??????? ë¨¸ë¦¬ ??ì¹? ?????? ???? ??ë¹? ì´¬ì???? ì§?????ê²??µë????.\n', ...
            'ì°¸ê??????? ?¤ì??ê³? ê°??? ???????? ??ë©´ì?? + ????ë¥? ??????ë©´ì?? ?¸ì???? ê³???ë©? ?©ë????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = 'ì£¼ì??: ?¤ì??? ?????? ë°????©ë????!!!';
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
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        % Finish testing
        msgtxt = ['??ë¹? ì´¬ì???? ??ë£??????µë????.\n', ...
            '?´í?? ë³? ì´¬ì???? ?????©ë????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['ë³? ì´¬ì???? ''?´ì?ê¸? ì´¬ì??'' ??????.\n', ...
            '?´ë?? ì´¬ì?? ???? ì°¸ê??????? ?¤ì??ê³? ê°??? ???????? ??ë©´ì?? + ????ë¥? ??????ë©´ì?? ?¸ì???? ê³???ë©? ?©ë????.\n', ...
            'ì´¬ì?? ?¸ì???? ????ë©? ê°??¨í?? ì§?ë¬? ë°? ??ê°?ê°? ?´ë£¨?´ì?????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
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
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

    case 'TEST2'

        msgtxt = ['ë³? ì´¬ì???? ''???? ???¤í?? ì´¬ì??'' ??????.\n', ...
            '?´ë?? ì´¬ì?? ????, ì°¸ê??????? ?¸ë??ë³¼ì?? êµ´ë?? ???? ?¬ê¸°ë¥? ?????? ì¡°ì???? ì£¼ì?¸ì??.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['ë§??? ì´¬ì???? ì§??????? ??ì¤? ?????? ?¤ë¦¬ì§? ???? ê²½ì??,\n', ...
            'ì°¸ê?????ê»??? êµ¬ë??ë¡? ë§????´ì£¼??ë©? ì´¬ì???? ì¤??¨í??ê³? ???? ???¤í?¸ë?? ??ë²? ?? ì§?????ê²??µë????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end


    case 'HEAT1'

        msgtxt = ['ë³? ì´¬ì???? ''?´ì??ê·? ì´¬ì??'' ??????.\n', ...
            '?´ë?? ì´¬ì?? ????, ì°¸ê?????ê»??? ë°??? ?´ì??ê·¹ì?? ??ê°??´ì£¼?¸ì??.'];
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

        % Explain scale and test thermal pain
        msgtxt = ['ë³? ì´¬ì???? ????, ?? ??ê·? ê²½í?? ë°? ??ê°? ì²??? ?°ì?µì?? ì§?????ê²??µë????.\n',...
            '??ê»´ì??? ?µì??? ???? ??ê°?ë¥? 5ì´? ?´ë? ì§????´ì£¼?¸ì??.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
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
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        wait_pre_state = 5;  wait_stimulus = wait_pre_state + 12;
        data.dat.practice_trial_starttime = GetSecs;
        %% -------------Pre_State: Setting Pathway------------------
        main(ip,port,1, 70);     % heat_param = 70 is the highest temperature
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_pre_state-2)

        %% -------------Pre_state: Ready for Pathway------------------
        main(ip,port,2); %ready to pre-start
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_pre_state) % Because of wait_pathway_setup-2, this will be 2 seconds

        %% ------------- start to trigger thermal stimulus------------------
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
        Screen('Flip', theWindow);
        main(ip,port,2);
        %% stimulus time adjusting
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_stimulus)
        %% Setting for rating
        ratetype = strcmp(rating_types.alltypes, main_scale{1});
        [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial mouse position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        data.dat.practice_rating_starttime = GetSecs;
        %% HEAT Rating
        while true
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{1});
            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            if GetSecs - data.dat.practice_rating_starttime > 5
                break
            end
            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen
        Screen('TextSize', theWindow, fontsize);
        data.dat.practice_rating = (x-lb)/(rb-lb);


    case 'MUSIC2'

        msgtxt = ['ë³? ì´¬ì???? ''???? ê°??? ì´¬ì??'' ??????.\n', ...
            '?´ë?? ì´¬ì?? ????, ì°¸ê??????? + ????ë¥? ë°??¼ë³´ë©? ìµ????? ?????? ì§?ì¤??´ì£¼?¸ì??.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        msgtxt = ['ë§??? ì´¬ì???? ì§??????? ??ì¤? ?????? ?¤ë¦¬ì§? ???? ê²½ì??,\n', ...
            'ì°¸ê?????ê»??? êµ¬ë??ë¡? ë§????´ì£¼??ë©? ì´¬ì???? ì¤??¨í??ê³? ???? ???¤í?¸ë?? ??ë²? ?? ì§?????ê²??µë????.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end
        

    case {'HEAT2', 'HEAT3', 'HEAT4'}

        msgtxt = ['ë³? ì´¬ì???? ''?´ì??ê·? ë°? ???? ê°??? ì´¬ì??'' ??????.\n', ...
            '?´ë?? ì´¬ì?? ????, ì°¸ê?????ê»??? ë°??? ?´ì??ê·¹ì?? ??ê°??´ì£¼?¸ì??.\n', ...
            '??, ?????? ìµ????? ì§?ì¤??´ì£¼?¸ì??.'];
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

        % Explain scale and test thermal pain
        msgtxt = ['ë³? ì´¬ì???? ????, ?? ??ê·? ê²½í?? ë°? ??ê°? ì²??? ?°ì?µì?? ì§?????ê²??µë????.\n',...
            '??ê»´ì??? ?µì??? ???? ??ê°?ë¥? 5ì´? ?´ë? ì§????´ì£¼?¸ì??.'];
        DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
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
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

        wait_pre_state = 5;  wait_stimulus = wait_pre_state + 12;
        data.dat.practice_trial_starttime = GetSecs;
        %% -------------Pre_State: Setting Pathway------------------
        main(ip,port,1, 70);     % heat_param = 70 is the highest temperature
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_pre_state-2)

        %% -------------Pre_state: Ready for Pathway------------------
        main(ip,port,2); %ready to pre-start
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_pre_state) % Because of wait_pathway_setup-2, this will be 2 seconds

        %% ------------- start to trigger thermal stimulus------------------
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
        Screen('Flip', theWindow);
        main(ip,port,2);
        %% stimulus time adjusting
        waitsec_fromstarttime(data.dat.practice_trial_starttime, wait_stimulus)
        %% Setting for rating
        ratetype = strcmp(rating_types.alltypes, main_scale{1});
        [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

        % Initial mouse position
        if start_center
            SetMouse((rb+lb)/2,H/2); % set mouse at the center
        else
            SetMouse(lb,H/2); % set mouse at the left
        end

        data.dat.practice_rating_starttime = GetSecs;
        %% PRACTICE: HEAT Rating
        while true
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
            [lb, rb, start_center] = draw_scale(main_scale{1});
            [x,~,button] = GetMouse(theWindow);
            if x < lb; x = lb; elseif x > rb; x = rb; end
            if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
            if GetSecs - data.dat.practice_rating_starttime > 5
                break
            end
            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
        end

        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen
        Screen('TextSize', theWindow, fontsize);
        data.dat.practice_rating = (x-lb)/(rb-lb);

        msgtxt = '+';
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end

end


%% SETUP: Sound Setting (for. MUSIC2 & HEAT2,3,4)
% Listening Audio Setting ë°? ???? ë¶??¬ì?¤ë?? ?¸í??
my_music_list = filenames(fullfile(my_music_dir, '*'), 'char');

if ismember(S.type, {'MUSIC2', 'HEAT2', 'HEAT3', 'HEAT4'})

    switch S.type
        case 'MUSIC2'
            data.music_order = ts.run_music_order(5,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
        case 'HEAT2'
            data.music_order = ts.run_music_order(1,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
        case 'HEAT3'
            data.music_order = ts.run_music_order(2,:);
            cat_all = [];
            for music_trial_num = 1:4
                temp_music_file = deblank(my_music_list(data.music_order(music_trial_num),:));
                [temp_samp_data, temp_samp_freq] = psychwavread(temp_music_file);
                cat_all = [cat_all; temp_samp_data];
            end
        case 'HEAT4'
            data.music_order = ts.run_music_order(3,:);
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

%% SETUP: HEAT intensity list (for. HEAT1~4)
if strcmp(S.type(1:end-1),'HEAT')
    
    ip = '192.168.0.3';
    %     ip = '192.168.0.3';
    port = 20121;
    % SETUP: ITI and heat list
    pre_state = [5,6,7];
    jitter = [5,4,3];
    iti = 2;
    heat_list = ts.heat_run_trial(str2double(S.type(end)),:);

    % Making pathway program list
    PathPrg = load_PathProgram('MPC');
    [~,indx] = ismember(heat_list, [PathPrg{:,1}]);
    heat_param.program = [PathPrg{indx,4}];
    heat_param.intensity = heat_list;

    jitter_list = ts.jitter_index_list(str2double(S.type(end)),:);
    data.dat.heat_param = heat_param;
    data.dat.jitter_list = jitter_list;

end


%% Main : Ready for scan
if ismember(S.type, {'REST2', 'TEST2', 'MUSIC2', 'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4'})

    msgtxt = ['?¤í?????? ëª¨ë?? ?¸í?? ë°? ì°¸ê??????? ì¤?ë¹?ê°? ??ë£???????ì§? ???¸í??ê¸? ë°???????.\n', ...
        'ì¤?ë¹?ê°? ??ë£???ë©? ?¤í?????? SPACE ?¤ë?? ???? ì£¼ì??ê¸? ë°???????.'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, white, [], [], [], 2);
    Screen('Flip', theWindow);
    while true
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    msgtxt = ['ì§?ê¸?ë¶??? ë³? ?¤í???? ?????©ë????.\n', ...
        'ì£¼ì??: ì´¬ì?? ì¤? ë¨¸ë¦¬ë¥? ??ì§??´ê±°?? ???? ?¤ì? ????ë¡? ?????´ì£¼??ê¸? ë°???????!!!'];
    DrawFormattedText(theWindow, double(msgtxt), 'center', 200, orange, [], [], [], 2);
    Screen('Flip', theWindow);
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
        if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
    end

    %% MAIN : Sync (S key)

    msgtxt = '?¤ì??? ?????©ë????. (S ??)';
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

    msgtxt = '???????? ì¤?...';
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

    case 'REST2'

        msgtxt = '+';
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        while true % Space
            cur_t = GetSecs;
            if cur_t - start_t >= S.dur
                break
            end
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end
        Screen('TextSize', theWindow, fontsize);
        save(data.datafile, '-append', 'data');

    case 'TEST2'
        Screen('TextSize', theWindow, fontsize);

        %% test: Both Sides
        msgtxt = '???? ???¤í?¸ë?? ì§????©ë????.';
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
        msgtxt = '?¤ì???? ?¼ìª½ ?´ì?´í?°ì????ë§? ?????? ???µë????.';
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

        msgtxt = '?¼ìª½ ?´ì?´í?°ì????ë§? ?????? ???¤ë?? ì¤???????.';
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
        msgtxt = '?¤ì???? ?¤ë¥¸ìª? ?´ì?´í?°ì????ë§? ?????? ???µë????.';
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

        msgtxt = '?¤ë¥¸ìª? ?´ì?´í?°ì????ë§? ?????? ???¤ë?? ì¤???????.';
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

        msgtxt = '???? ???¤í?? ì´¬ì???? ì¢?ë£??©ë????.';
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);
        Screen('TextSize', theWindow, fontsize);
        while true % Space
            [~,~,keyCode_E] = KbCheck(Exp_key);
            if keyCode_E(KbName('space')); while keyCode_E(KbName('space')); [~,~,keyCode_E] = KbCheck(Exp_key); end; break; end
            if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
        end


    case 'MUSIC2'

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

case 'HEAT1'

        for trial_num = 1:numel(data.dat.heat_param.program)
            % SETUP: ITI
            jitter_index = jitter_list(trial_num);
            wait_pre_state = pre_state(jitter_index);
            wait_stimulus = wait_pre_state + 12;
            wait_jitter = wait_stimulus + jitter(jitter_index);
            wait_rating = wait_jitter + 5;
            total_trial_time = 28;

            %% Checking trial start time & Adjusting between trial time
            data.dat.trial_real_starttime(trial_num) = GetSecs;
            if trial_num == 1
                waitsec_fromstarttime(data.dat.run_starttime(trial_num), iti)
            else
                waitsec_fromstarttime(data.dat.trial_endtime(trial_num-1), iti)
            end

            data.dat.trial_starttime(trial_num) = GetSecs;
            data.dat.between_run_trial_starttime(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.run_starttime(1);

            %% Data recording
            Screen(theWindow, 'FillRect', bgcolor, window_rect);

            data.dat.jitter_value = jitter;
            data.dat.iti_value = pre_state;
            data.dat.jitter_index(trial_num) = jitter_index;

            %% -------------Pre_State: Setting Pathway------------------
            main(ip,port,1,heat_param.program(trial_num));     % select the program
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num),wait_pre_state-2)

            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num),wait_pre_state) % Because of wait_pathway_setup-2, this will be 2 seconds

            %% Check stimulus start time
            data.dat.stimulus_starttime(trial_num) = GetSecs;

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);
            main(ip,port,2);

            %% Check stimulus time
            data.dat.stimulus_time(trial_num) = GetSecs;

            %% stimulus time adjusting
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_stimulus)

            %% Check stimulus end time
            data.dat.stimulus_endtime(trial_num) = GetSecs;
            data.dat.stimulus_duration(trial_num) = data.dat.stimulus_endtime(trial_num) - data.dat.stimulus_time(trial_num);

            %% Check Jitter time
            data.dat.jitter_starttime(trial_num) = GetSecs;

            %% Jittering
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);

            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_jitter)

            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('Flip', theWindow);

            %% Check Jitter end time
            data.dat.jitter_endtime(trial_num) = GetSecs;
            data.dat.jitter_duration(trial_num) = data.dat.jitter_endtime(trial_num) - data.dat.jitter_starttime(trial_num);

            %% Setting for rating
            ratetype = strcmp(rating_types.alltypes, main_scale{1});
            [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
            Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

            % Initial mouse position
            if start_center
                SetMouse((rb+lb)/2,H/2); % set mouse at the center
            else
                SetMouse(lb,H/2); % set mouse at the left
            end

            start_t = GetSecs;
            data.dat.rating_starttime(trial_num) = start_t;

            %% HEAT Rating
            while true
                DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
                [lb, rb, start_center] = draw_scale(main_scale{1});
                [x,~,button] = GetMouse(theWindow);
                if x < lb; x = lb; elseif x > rb; x = rb; end
                if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

                [~,~,keyCode_E] = KbCheck(Exp_key);
                if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
                if GetSecs - data.dat.rating_starttime(trial_num) > 5
                    break
                end
                Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                Screen('Flip', theWindow);
            end

            %% saving rating result
            end_t = GetSecs;

            data.dat.rating(trial_num) = (x-lb)/(rb-lb);
            data.dat.rating_endtime(trial_num) = end_t;
            data.dat.rating_duration(trial_num) = end_t - start_t;

            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('Flip', theWindow);

            %% rating time adjusting
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_rating)

            %% Adjusting total trial time
%             Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            Screen('TextSize', theWindow, fontsize);

            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), total_trial_time)

            %% saving trial end time
            data.dat.trial_endtime(trial_num) = GetSecs;
            data.dat.trial_duration(trial_num) = data.dat.trial_endtime(trial_num) - data.dat.trial_starttime(trial_num);

            if trial_num >1
                data.dat.between_trial_time(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.trial_endtime(trial_num-1);
            else
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
        end

        data.dat.run_endtime = GetSecs;

        save(data.datafile, '-append', 'data');

    case {'HEAT2', 'HEAT3', 'HEAT4'}
        % Wait secs parameters
        msgtxt = '+';
        Screen('TextSize', theWindow, 60);
        DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
        Screen('Flip', theWindow);

        % Music start
        data.dat.playing_starttime = PsychPortAudio('Start', pahandle, 1, 0, 1);

        for trial_num = 1:numel(data.dat.heat_param.program)
            % SETUP: ITI
            jitter_index = jitter_list(trial_num);
            wait_after_music = 60;
            wait_pre_state = pre_state(jitter_index);
            wait_stimulus = wait_pre_state + 12;
            wait_jitter = wait_stimulus + jitter(jitter_index);
            wait_rating = wait_jitter + 5;
            total_trial_time = 28;

            %% Checking trial start time & Adjusting between trial time
            data.dat.trial_real_starttime(trial_num) = GetSecs;
            if trial_num == 1
                waitsec_fromstarttime(data.dat.run_starttime(trial_num), wait_after_music+iti)
            elseif ismember(trial_num,[5,9,13])
                waitsec_fromstarttime(data.dat.trial_endtime(trial_num-1), wait_after_music+iti)
            else
                waitsec_fromstarttime(data.dat.trial_endtime(trial_num-1), iti)
            end

            data.dat.trial_starttime(trial_num) = GetSecs;
            data.dat.between_run_trial_starttime(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.run_starttime(1);

            %% Data recording
            Screen(theWindow, 'FillRect', bgcolor, window_rect);

            data.dat.jitter_value = jitter;
            data.dat.iti_value = pre_state;
            data.dat.jitter_index(trial_num) = jitter_index;

            %% -------------Pre_State: Setting Pathway------------------
                main(ip,port,1, heat_param.program(trial_num));     % select the program
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_pre_state-2)

            %% -------------Pre_state: Ready for Pathway------------------
            main(ip,port,2); %ready to pre-start
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_pre_state) % Because of wait_pathway_setup-2, this will be 2 seconds

            %% Check stimulus start time
            data.dat.stimulus_starttime(trial_num) = GetSecs;

            %% ------------- start to trigger thermal stimulus------------------
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);
            main(ip,port,2);

            %% Check stimulus time
            data.dat.stimulus_time(trial_num) = GetSecs;

            %% stimulus time adjusting
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_stimulus)

            %% Check stimulus end time
            data.dat.stimulus_endtime(trial_num) = GetSecs;
            data.dat.stimulus_duration(trial_num) = data.dat.stimulus_endtime(trial_num) - data.dat.stimulus_time(trial_num);

            %% Check Jitter time
            data.dat.jitter_starttime(trial_num) = GetSecs;

            %% Jittering
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);

            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_jitter)

            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('Flip', theWindow);

            %% Check Jitter end time
            data.dat.jitter_endtime(trial_num) = GetSecs;
            data.dat.jitter_duration(trial_num) = data.dat.jitter_endtime(trial_num) - data.dat.jitter_starttime(trial_num);

            %% Setting for rating
            ratetype = strcmp(rating_types.alltypes, main_scale{1});
            [lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
            Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

            % Initial mouse position
            if start_center
                SetMouse((rb+lb)/2,H/2); % set mouse at the center
            else
                SetMouse(lb,H/2); % set mouse at the left
            end

            start_t = GetSecs;
            data.dat.rating_starttime(trial_num) = start_t;

            %% HEAT Rating
            while true
                DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);
                [lb, rb, start_center] = draw_scale(main_scale{1});
                [x,~,button] = GetMouse(theWindow);
                if x < lb; x = lb; elseif x > rb; x = rb; end
                if button(1); while button(1); [~,~,button] = GetMouse(theWindow); end; break; end

                [~,~,keyCode_E] = KbCheck(Exp_key);
                if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
                if GetSecs - data.dat.rating_starttime(trial_num) > 5
                    break
                end
                Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                Screen('Flip', theWindow);
            end

            %% Save rating result
            end_t = GetSecs;

            data.dat.rating(trial_num) = (x-lb)/(rb-lb);
            data.dat.rating_endtime(trial_num) = end_t;
            data.dat.rating_duration(trial_num) = end_t - start_t;

            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('Flip', theWindow);

            %% rating time adjusting
            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), wait_rating)

            %% Adjusting total trial time
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, 60);
            DrawFormattedText(theWindow, double('+'), 'center', H*(2/5), white, [], [], [], 1.2);
            Screen('Flip', theWindow);

            waitsec_fromstarttime(data.dat.trial_starttime(trial_num), total_trial_time)

            %% saving trial end time
            data.dat.trial_endtime(trial_num) = GetSecs;
            data.dat.trial_duration(trial_num) = data.dat.trial_endtime(trial_num) - data.dat.trial_starttime(trial_num);

            if trial_num >1
                data.dat.between_trial_time(trial_num) = data.dat.trial_starttime(trial_num) - data.dat.trial_endtime(trial_num-1);
            else
                data.dat.between_trial_time(trial_num) = 0;
            end
            save(data.datafile, '-append', 'data');
        end

        PsychPortAudio('Stop', pahandle);
        data.dat.playing_endtime = GetSecs;
        PsychPortAudio('Close');

        save(data.datafile, '-append', 'data');

end

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
    if cur_t - end_t >= 15
        break
    end
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end
Screen('TextSize', theWindow, fontsize);

if USE_BIOPAC % end BIOPAC
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

data.dat.runscan_endtime = GetSecs;
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
        
        msgtxt = '???? ?? ì§?ë¬¸ë?¤ì?? ?????? ê²???????. ì°¸ê???ê»????? ???? ê¸°ë?¤ë?¤ì£¼??ê¸? ë°???????.';
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

        msgtxt = 'ì§?ë¬¸ì?? ???¬ì?µë????.';
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


%% Closing screen

msgtxt = ['?¸ì???? ???¬ì?µë????.\n', ...
    'ì°¸ê??????? ???? ê°???ì£¼ì??ê¸? ë°???????.\n', ...
    '?¸ì???? ë§?ì¹??¤ë©´, ?¤í?????? SPACE ?¤ë?? ???¬ì£¼?¸ì??.'];
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

