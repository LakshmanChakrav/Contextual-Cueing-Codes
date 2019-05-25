function fixation_screen(wPtr,xcenter,ycenter)
    Screen('TextSize', wPtr, 22);

    fixation = '+';
    widthFix = RectWidth(Screen('TextBounds',wPtr,fixation));
    Screen('DrawText', wPtr,fixation,xcenter-widthFix,ycenter-10,[255 255 255]);
    Screen(wPtr, 'Flip');
    pause(1);
end