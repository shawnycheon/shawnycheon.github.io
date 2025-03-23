
anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;
anchor_middle = [0.2 0.5].*(rb1-lb1)+lb1;

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
        