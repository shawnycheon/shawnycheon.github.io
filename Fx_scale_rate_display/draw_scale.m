function [lb, rb, start_center] = draw_scale(scale)

global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_middle anchor_vas korean alpnum space special bgcolor white orange red

%% Basic setting
lb = lb1;
rb = rb1;
start_center = false;


%% Drawing scale
switch scale
    case 'line'
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
%         DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
%         DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'lms'
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        for i = 1:5
            Screen('DrawLine', theWindow, 0, anchor_lms(i), H/2+scale_W, anchor_lms(i), H/2, 2);
        end
        DrawFormattedText(theWindow, double('거의\n없는'), anchor_lms(1)-korean.x-10, H/2-korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('약한'), anchor_lms(2)-korean.x+10, H/2-korean.y/2, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('보통'), anchor_lms(3)-korean.x, H/2-korean.y/2, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('강한'), anchor_lms(4)-korean.x, H/2-korean.y/2, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우\n강한'), anchor_lms(5)-korean.x, H/2-korean.y, white, [], [], [], 1);
        
    case 'overall_int'
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_int_numel'
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('0 kg/cm^2'), lb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('10 kg/cm^2'), rb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 1);
        
    case 'overall_avoidance'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_unpleasant'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n       않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_sound'

        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('소리가 작음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('소리가 큼'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'cont_int'
        
        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n       않음'), lb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n    가장 심한'), rb1-korean.x*3-space.x, H/6+scale_W+korean.y, white, [], [], [], 1);

    case 'cont_int_vas'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('전혀 느껴지지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('상상할 수 있는\n 가장 강한 통증'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'cont_int_vas_exp'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

    case 'cont_threat_vas'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('매우 안전'), lb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 위협'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
    
    case 'cont_pleasure_vas'
%         start_center = true;

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        %         Screen('DrawLine', theWindow, 255, anchor_lms(5), H/2+scale_W, anchor_lms(5), H/2, 2);
        %         Screen('DrawLine', theWindow, orange, anchor_lms(5), H/2+scale_W/2, rb1, H/2+scale_W/2, 5);
        %
%         Screen(theWindow,'DrawLines', xy, 5, 255);
%         Screen('DrawLine', theWindow, 255, anchor_vas(1), H/2+scale_W, anchor_vas(1), H/2, 2);
%         Screen('DrawLine', theWindow, 255, anchor_vas(2), H/2+scale_W, anchor_vas(2), H/2, 2);
%         Screen('DrawLine', theWindow, 255, anchor_vas(3), H/2+scale_W, anchor_vas(3), H/2, 2);

    case 'cont_pleasure_lms'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1, H/2+scale_W+korean.y*1, lb1, H/2+scale_W+korean.y*10];
        winRect_R = [rb1, H/2+scale_W+korean.y*1, rb1, H/2+scale_W+korean.y*10];
        DrawFormattedText(theWindow, double('즐겁지\n않음'), 'center', winRect_L(2), white, [], [], [], 1, [], winRect_L);
        DrawFormattedText(theWindow, double('음악적 전율'), 'center', winRect_R(2), white, [], [], [], 1, [], winRect_R);

        for i = 1:4
            Screen('DrawLine', theWindow, 255, anchor_lms(i), H/2, anchor_lms(i), H/2+scale_W, 4);
        end
        winRect_A{1} = [anchor_lms(1), H/2-korean.y*1, anchor_lms(1), H/2-korean.y*1];
        %         DrawFormattedText(theWindow, double('약한'), anchor_lms(1)-korean.x-10, H/2, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('약한'), 'center', winRect_A{1}(2), white, [], [], [], 1, [], winRect_A{1});
        DrawFormattedText(theWindow, double('보통'), anchor_lms(2)-korean.x+10, H/2-korean.y*1, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('강한'), anchor_lms(3)-korean.x, H/2-korean.y*2, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우\n강한'), anchor_lms(4)-korean.x, H/2-korean.y*3, white, [], [], [], 1);

    case 'overall_pleasure'
        %         start_center = true;

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        %         Screen('DrawLine', theWindow, 255, anchor_middle(2), H/2+scale_W, anchor_middle(2), H/2, 2);
        
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('쾌감 없음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 쾌감'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
%         winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
%         winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
%         DrawFormattedText(theWindow, double('상상할 수 있는\n 가장 강한 불쾌함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
%         DrawFormattedText(theWindow, double('상상할 수 있는\n 가장 강한 즐거움'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'overall_familiarity'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 친숙하지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 친숙함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'overall_familiarity_lms'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 친숙하지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 친숙함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'cont_avoidance'

        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText(theWindow, double('전혀 피할\n필요 없음'), lb1-korean.x*2-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double(' 절대로 다시\n경험하고 싶지\n      않음'), rb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 1);

    case 'cont_avoidance_vas'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 피할\n필요 없음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double(' 절대로 다시\n경험하고 싶지\n      않음'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
    
    case 'cont_avoidance_exp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', white, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_aversive_ornot'
        start_center = true;
        lb = lb2;
        rb = rb2;
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText(theWindow, double('예'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('아니오'), (rb2+rb2_middle)/2-korean.x*3/2,  H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_pain_ornot'
        start_center = true;
        lb = lb2;
        rb = rb2;
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText(theWindow, double('예'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('아니오'), (rb2+rb2_middle)/2-korean.x*3/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_boredness'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 지겹지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 지겨움'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_alertness'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('매우 졸림'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 또렷'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_relaxed'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('매우 불편함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 편함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'overall_attention'
        start_center = true;

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('전혀 집중되지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 집중\n잘 됨'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'overall_music_attention'

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 집중되지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 집중됨'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'overall_resting_positive'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);

        
    case 'overall_resting_negative'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_myself'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_others'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_imagery'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_present'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_past'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_future'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_bitter_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_bitter_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_capsai_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_capsai_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_odor_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_resting_odor_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_thermal_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_thermal_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_pressure_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_pressure_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_negvis_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_negvis_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_negaud_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_negaud_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_posvis_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_posvis_ple'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 기분 좋은'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_comfortness'
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('매우 불편함'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 편함'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        
    case 'overall_mood'
        start_center = true;
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText(theWindow, double('매우 부정적'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 1);
        DrawFormattedText(theWindow, double('매우 긍정적'), rb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 1);

    case {'overall_music_pleasure_1','overall_music_pleasure_2','overall_music_pleasure_3','overall_music_pleasure_4'}

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('쾌감 없음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('상상할 수 있는\n가장 강한 쾌감'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case {'overall_music_attention_1','overall_music_attention_2','overall_music_attention_3','overall_music_attention_4'}

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('전혀 집중되지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 집중\n잘 됨'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case {'overall_music_familiarity_1','overall_music_familiarity_2','overall_music_familiarity_3','overall_music_familiarity_4'}

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 친숙하지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 친숙함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case {'overall_music_chill_1','overall_music_chill_2','overall_music_chill_3','overall_music_chill_4'}
        start_center = true;

        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen('DrawLine', theWindow, 255, anchor_middle(2), H/2+scale_W, anchor_middle(2), H/2, 2);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('경험하지 않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('경험함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

    case 'cont_sound_volume'
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen('DrawLine', theWindow, 255, anchor_middle(2), H/2+scale_W, anchor_middle(2), H/2, 2);

        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('0'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('100'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);

end

end


