function [response_time,accuracy] = irrelevant_context(wPtr,imgt,q,flip_target,reloc_tar,reloc_dis,distractor_location)

    Screen('TextSize', wPtr, 22);

    monitorFlipInterval=Screen('GetFlipInterval',wPtr);
    xdim = 1366;
    ydim = 768;
    xcenter = xdim/2;
    ycenter = ydim/2;
    
    m = matfile('myFile.mat');
    xoffset = m.xoffset;
    yoffset = m.yoffset;
    
    if reloc_tar == 1
        reloc_tar_offset = 50*((rand>0.5)*2-1);
    else
        reloc_tar_offset = 0;
    end
    
    if reloc_dis == 1
        reloc_dis_offset = 50*((rand>0.5)*2-1);
    else
        reloc_dis_offset = 0;
    end
    
    count = 1;
    counter = 0;
    for i=1:8
        for j=1:7
            if ismember(count,q)
                if count == q(1)
                    element = 'F';
                    DrawFormattedText(wPtr,element,i*(xdim/9) + xoffset(i,j) + reloc_tar_offset + (flip_target*4-2),j*(ydim/8)+ yoffset(i,j) + reloc_tar_offset,[255 255 255], [], flip_target);
                elseif count == q(distractor_location)
                    element = 'E';
                    DrawFormattedText(wPtr,element,i*(xdim/9) + xoffset(i,j) + reloc_dis_offset,j*(ydim/8)+ yoffset(i,j) + reloc_dis_offset,[255 255 255],[], flip_target);
                else
                    counter = counter+1;
                    if counter < 3
                        element = 'E';
                        DrawFormattedText(wPtr,element,i*(xdim/9) + xoffset(i,j),j*(ydim/8)+ yoffset(i,j),[255 255 255],[], flip_target);
                    else
                        element = 'E';
                        DrawFormattedText(wPtr,element,i*(xdim/9) + xoffset(i,j),j*(ydim/8)+ yoffset(i,j),[255 255 255],[], 1-flip_target);
                    end
                end
            end
            count = count + 1;
        end
    end

    Screen(wPtr, 'Flip');
    start = GetSecs();
    [~,keyCode,~] = KbWait([], 2);
    stop = GetSecs();
    
    
    Screen('DrawTexture', wPtr, imgt, [], [0 0 1366 786]);
    
%     for i=1:8
%         for j=1:7
%             DrawFormattedText(wPtr,'E',i*(xdim/9) + xoffset(i,j) + reloc_tar_offset - 2 ,j*(ydim/8)+ yoffset(i,j) + reloc_tar_offset,[255 255 255],[]);
%             DrawFormattedText(wPtr,'E',i*(xdim/9) + xoffset(i,j) + reloc_tar_offset + 2,j*(ydim/8)+ yoffset(i,j) + reloc_tar_offset,[255 255 255],[],1);
%         end
%     end
    
    [wPtr1] = Screen(wPtr, 'Flip');
    WaitSecs('UntilTime', wPtr1 + 0.2-monitorFlipInterval);
    
    response_time = (stop-start)*1000;
    
   
    if ((flip_target==0)&&(find(keyCode)==39))||((flip_target==1)&&(find(keyCode)==37))
        accuracy = 1;
    else
        accuracy = 0;
    end
    
%     if (response_time < 3000)
%         trial_score = round(accuracy*(3-(response_time/1000))*10);
%     else
%         trial_score = 0;
%     end
%     
%     total_score = previous_score + trial_score;
    
    if (accuracy == 0)
        fbText = 'Incorrect response. Please press any key to continue';
        %fbCol = [0 255 0];
        widthfb = RectWidth(Screen('TextBounds',wPtr,fbText));
        Screen('DrawText', wPtr,fbText,xcenter-widthfb/2,ycenter,[255 255 255]);
        Screen(wPtr, 'Flip');
        KbWait;
    end
    
%     fb1Text = strcat('Your Response Time is_',num2str(round(response_time)),'_ms');
%     fb2Text = strcat('Your trial score is_',num2str(trial_score),'_points');
%     fb3Text = strcat('Your total score is_',num2str(total_score),'_points');
%     widthfb = RectWidth(Screen('TextBounds',wPtr,fbText));
%     widthfb1 = RectWidth(Screen('TextBounds',wPtr,fb1Text));
%     widthfb2 = RectWidth(Screen('TextBounds',wPtr,fb2Text));
%     widthfb3 = RectWidth(Screen('TextBounds',wPtr,fb3Text));
%     Screen('DrawText', wPtr,fbText,xcenter-widthfb/2,ycenter-60,fbCol);
%     Screen('DrawText', wPtr,fb1Text,xcenter-widthfb1/2,ycenter-20,[255 255 255]);
%     Screen('DrawText', wPtr,fb2Text,xcenter-widthfb2/2,ycenter+20,[255 255 255]);
%     Screen('DrawText', wPtr,fb3Text,xcenter-widthfb3/2,ycenter+60,[255 255 255]);
%     Screen(wPtr, 'Flip');
%     if (accuracy == 1)
%         Beeper(600,0.5,0.1);
%     else
%         Beeper(300,0.5,0.3);
%     end
%     KbWait;

end