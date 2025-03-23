 %% test: Both Sides
        msgtxt = '음향 테스트를 진행합니다.';
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
        msgtxt = '다음은 왼쪽 이어폰에서만 소리가 나옵니다.';
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

        msgtxt = '왼쪽 이어폰에서만 소리가 나오는 중입니다.';
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
        msgtxt = '다음은 오른쪽 이어폰에서만 소리가 나옵니다.';
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

        msgtxt = '오른쪽 이어폰에서만 소리가 나오는 중입니다.';
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

    case {'HEAT1', 'HEAT2', 'HEAT3', 'HEAT4', 'HEAT5', 'HEAT6'}

        for trial_num = 1:numel(data.dat.heat_param.program)
            % SETUP: ITI
            jitter_sec = jitter_list(trial_num);
            wait_pre_state = prestate_list(trial_num);
            wait_stimulus = wait_pre_state + 12
            wait_jitter = wait_stimulus + jitter_sec
            wait_rating = wait_jitter + 5
            total_trial_time = 30
            
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

            data.dat.jitter = jitter;
            data.dat.prestate = pre_state;
            data.dat.jitter_value(trial_num) = jitter_sec;
            data.dat.prestate_value(trial_num) = wait_pre_state

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
    
    case 'CAPS1'
        rec_rest_i = 0;
        rec_caps_i = 0;

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
            if GetSecs - continuous_rating_start < caps_control
                % Get ratings
                time_fromstart = NaN(36000,1); % ~10 min given 60Hz flip freq
                cont_rating = NaN(36000,1); % ~10 min given 60Hz flip freq
                data.dat.rest_rating_starttime = GetSecs;
                while true
                    Screen('TextSize', theWindow, 60);
                    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

                    [lb, rb, start_center] = draw_scale(main_scale{1});

                    [x,~,~] = GetMouse(theWindow);
                    if x < lb; x = lb; elseif x > rb; x = rb; end
                    [~,~,keyCode_E] = KbCheck(Exp_key);
                    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

                    rec_rest_i = rec_rest_i + 1;
                    cur_t = GetSecs;
                    time_fromstart(rec_rest_i) = cur_t-data.dat.rest_rating_starttime;
                    cont_rating(rec_rest_i) = (x-lb)./(rb-lb);

                    if cur_t - start_t >= S.dur
                        break
                    end
                    Screen('TextSize', theWindow, fontsize);
                    Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                end
                data.dat.rest_time_fromstart = time_fromstart(1:rec_rest_i);
                data.dat.rest_cont_rating = cont_rating(1:rec_rest_i);
                Screen('TextSize', theWindow, fontsize);            
                continuous_rating_end = GetSecs;
                continuous_rating_duration = continuous_rating_end - data.dat.rest_rating_starttime;
                data.dat.continuous_rating_end = continuous_rating_end;
                data.dat.continuous_rating_duration = continuous_rating_duration;
            
            elseif GetSecs - continuous_rating_start < caps_wait_stim
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

                time_fromstart = NaN(54000,1); % ~15 min given 60Hz flip freq
                cont_rating = NaN(54000,1); % ~15 min given 60Hz flip freq
                data.dat.caps_rating_starttime = GetSecs;
                while true
                    Screen('TextSize', theWindow, 60);
                    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', H*(2/5), white, [], [], [], 2);

                    [lb, rb, start_center] = draw_scale(main_scale{1});

                    [x,~,~] = GetMouse(theWindow);
                    if x < lb; x = lb; elseif x > rb; x = rb; end
                    [~,~,keyCode_E] = KbCheck(Exp_key);
                    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end

                    rec_caps_i = rec_caps_i + 1;
                    cur_t = GetSecs;
                    time_fromstart(rec_caps_i) = cur_t-data.dat.caps_rating_starttime;
                    cont_rating(rec_caps_i) = (x-lb)./(rb-lb);

                    if cur_t - continuous_rating_start >= S.dur
                        break
                    end
                    Screen('TextSize', theWindow, fontsize);
                    Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                end
                data.dat.caps_time_fromstart = time_fromstart(1:rec_caps_i);
                data.dat.caps_cont_rating = cont_rating(1:rec_caps_i);
                Screen('TextSize', theWindow, fontsize);            
              
                continuous_rating_end = GetSecs;
                continuous_rating_duration = continuous_rating_end - data.dat.caps_rating_starttime;
                data.dat.continuous_rating_end = continuous_rating_end;
                data.dat.continuous_rating_duration = continuous_rating_duration;

                data.dat.caps_stim_deliver_dur = data.dat.caps_stim_deliver_end - data.dat.caps_stim_deliver_start;
                data.dat.caps_stim_remove_dur = data.dat.caps_stim_remove_end - data.dat.caps_stim_remove_start;
                
                save(data.datafile, '-append', 'data');
                break
            end
        end
        
    case 'QUIN1'
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
            if GetSecs - continuous_rating_start < quin_wait_stim
                msgtxt = '잠시만 기다려주세요';
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.quin_stim_deliver_start = GetSecs;

            elseif GetSecs - continuous_rating_start < quin_stim_deliver
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('자극을 전달하세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.quin_stim_deliver_end = GetSecs;

            elseif GetSecs - continuous_rating_start < quin_stim_deliver + 2
                Screen('TextSize', theWindow, 45);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.quin_stim_remove_start = GetSecs;

            elseif GetSecs - continuous_rating_start < quin_stim_remove
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('자극을 제거하고, 입을 벌린 상태를 유지해주세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.quin_stim_remove_end = GetSecs;

            elseif GetSecs - continuous_rating_start < quin_stim_remove + 5
                Screen('TextSize', theWindow, 45);
                DrawFormattedText(theWindow, double('입을 닫고 혀를 입 천장 위에 고정해주세요'), 'center', H*(2/5), orange, [], [], [], 2);
                Screen('TextSize', theWindow, fontsize);
                ratetype = strcmp(rating_types.alltypes, main_scale{2});
                [lb, rb, start_center] = draw_scale(main_scale{2});
                Screen('Flip', theWindow);
                data.dat.quin_stim_remove_final = GetSecs;

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

                time_fromstart = NaN(46800,1); % ~13 min given 60Hz flip freq
                cont_rating = NaN(46800,1); % ~13 min given 60Hz flip freq
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
                    time_fromstart(rec_i) = cur_t-data.dat.rating_starttime;
                    cont_rating(rec_i) = (x-lb)./(rb-lb);

                    if cur_t - continuous_rating_start >= S.dur
                        break
                    end
                    Screen('TextSize', theWindow, fontsize);
                    Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                end
                data.dat.time_fromstart = time_fromstart(1:rec_i);
                data.dat.cont_rating = cont_rating(1:rec_i);
                Screen('TextSize', theWindow, fontsize);            
              
                continuous_rating_end = GetSecs;
                continuous_rating_duration = continuous_rating_end - data.dat.rating_starttime;
                data.dat.continuous_rating_end = continuous_rating_end;
                data.dat.continuous_rating_duration = continuous_rating_duration;

                data.dat.quin_stim_deliver_dur = data.dat.quin_stim_deliver_end - data.dat.quin_stim_deliver_start;
                data.dat.quin_stim_remove_dur = data.dat.quin_stim_remove_end - data.dat.quin_stim_remove_start;
                
                save(data.datafile, '-append', 'data');
                break
            end
        end
        data.dat.run_endtime = GetSecs;

        save(data.datafile, '-append', 'data');

end

cur_t = GetSecs;
data.dat.experiment_endtime = cur_t;
data.dat.experiment_total_dur = cur_t - start_t;

% AFTER RUN BASELINE 20secs 
msgtxt = '+';
Screen('TextSize', theWindow, 60);
DrawFormattedText(theWindow, double(msgtxt), 'center', H*(2/5), white, [], [], [], 2);
Screen('Flip', theWindow);
end_t = GetSecs;
while true % Space
    cur_t = GetSecs;
    if cur_t - end_t >= 20
        break
    end
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('q')); abort_experiment('manual'); break; end
end
Screen('TextSize', theWindow, fontsize);

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

%% Closing screen

msgtxt = ['세션이 끝났습니다.\n', ...
    '참가자님은 눈을 감아주시길 바랍니다.\n', ...
    '세션을 마치려면, 실험자는 SPACE 키를 눌러주세요.'];
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

marker_mat(subjsess, :) = false;
marker_mat(subjsess, runmarker) = true;

save(markerfile, '-append', 'marker_mat');

disp('Done');



