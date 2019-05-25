clear all;

sub_name = input('Enter the name of subject - ', 's');
subject_number = input('Enter the subject number - ');
currentFolder = pwd;
dbase = strcat(currentFolder,'\Subject_', sub_name,'_',num2str(subject_number),'_Exp_OBNF.xlsx');

[wPtr,rect]=Screen('OpenWindow',0);
black=BlackIndex(wPtr);
white=WhiteIndex(wPtr);
Screen('FillRect',wPtr,black);
Screen(wPtr, 'Flip');
xcenter = rect(3)/2;
ycenter = rect(4)/2;
xdim = rect(3);
ydim = rect(4);

HideCursor;

Screen('TextSize', wPtr, 22);
Screen('TextFont',wPtr,char('Arial'));
Screen('TextStyle',wPtr,0);

training_rt = null(100);
training_accuracy = null(100);
test_rt = null(100);
test_accuracy = null(100);
training_RT = [];
training_ACC = [];
relevance_index_test = [];
fixed_config_record = [];
Reloc = [];
epoch_log = [];
trial_no = [];
test_RT = [];
test_ACC = [];
%block_score = null(100);
q = null(100);

img = imread('checkerboard.bmp');
imgt = Screen('MakeTexture', wPtr, img);

welText = 'Welcome to the experiment. Press any key to start ...';
widthWel=RectWidth(Screen('TextBounds',wPtr,welText));
Screen('DrawText', wPtr,welText,xcenter-widthWel/2,ycenter-10,[255 255 255]);        
Screen(wPtr, 'Flip');
KbWait;

queueName = strcat('OBNC_queue',num2str(subject_number),'.mat');
load(queueName);
m = matfile(queueName);
config = m.queue;

for i=1:8
    
    q(i,1) = config(i);

%     p = randperm(56);
%     for k = 1:8
%         p(p == config(k)) = [];
%     end

    a = randperm(7);
    a(8) = floor(rand*7);
    b = randperm(8);
    p = (b-1)*7 + a;
    
    while(ismember(config(i),p))
        a = randperm(7);
        a(8) = floor(rand*7);
        b = randperm(8);
        p = (b-1)*7 + a;
    end
    
    for j = 2:8
        q(i,j) = p(j);
    end

end



%%%%%%%%%%%%%%%%%%%%%%%TRAINING PHASE%%%%%%%%%%%%%%%%%%%%%%

flip_target = rem(randperm(50),2);

blockText = strcat('TRAINING BLOCK');
widthB = RectWidth(Screen('TextBounds',wPtr,blockText));
Screen('DrawText',wPtr,blockText,xcenter-widthB/2,ycenter-20,[255 255 255]);
Screen(wPtr,'Flip');
pause(1);

%previous_score = 0;

for i=1:50% change to 50
    
    fixation_screen(wPtr,xcenter,ycenter);               
    [training_rt(i),training_accuracy(i)] = new_context(wPtr,imgt,flip_target(i));
    training_RT = cat(1,training_RT,training_rt(i));
    training_ACC = cat(1,training_ACC,training_accuracy(i));
    
   
end

train_avgRT = mean(training_rt((i-49):i));
train_avgACC = mean(training_accuracy((i-49):i))*100;

pauseText = 'Please rest for 10 seconds.';
widthP = RectWidth(Screen('TextBounds',wPtr,pauseText));
resumeText = 'Please press any key to resume the experiment.';
widthR = RectWidth(Screen('TextBounds',wPtr,resumeText));
FeedbackText = strcat('Your average response time is_',num2str(train_avgRT),'_and accuracy is_',num2str(train_avgACC),'_percent');
widthFT = RectWidth(Screen('TextBounds',wPtr,FeedbackText));
Screen('DrawText',wPtr,pauseText,xcenter-widthP/2,ycenter-20,[255 255 255]);
Screen('DrawText',wPtr,FeedbackText,xcenter-widthFT/2,ycenter+20,[255 255 255]);
Screen(wPtr,'Flip');
pause(10);
Screen('DrawText',wPtr,resumeText,xcenter-widthR/2,ycenter-20,[255 255 255]);
Screen(wPtr,'Flip');
KbWait([],3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TEST PHASE%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reloc_tar = null(100);
reloc_dis = null(100);
main_index = null(100);
fixed_config_no = null(100);
distractor_location_matrix = null(100);
relocation = null(100);

flip_target = rem(randperm(256),2);
relocation_order = randperm(256);

for i=1:8
    main_index(relocation_order(i)) = 1;
    reloc_tar(relocation_order(i)) = 1;
    reloc_dis(relocation_order(i)) = 0;

    fixed_config_no(relocation_order(i)) = i;
    
    distractor = 1;
    while distractor == 1
        distractor = randi(8);
    end
    
    distractor_location_matrix (relocation_order(i)) = distractor;
    relocation(relocation_order(i)) = 1;
end


for i=9:64
    main_index(relocation_order(i)) = 1;
    reloc_tar(relocation_order(i)) = 0;
    reloc_dis(relocation_order(i)) = 1;
    fixed_config_no(relocation_order(i)) = fix((i-2)/7);
    
    distractor_location_matrix (relocation_order(i)) = rem((i-2),7)+2;
    relocation(relocation_order(i)) = 2;
end

for i=65:256
    main_index(relocation_order(i)) = 1;
    reloc_tar(relocation_order(i)) = 0;
    reloc_dis(relocation_order(i)) = 0;
    fixed_config_no(relocation_order(i)) = fix((i-41)/24);
    
    distractor = 1;
    while distractor == 1
        distractor = randi(8);
    end
    
    distractor_location_matrix (relocation_order(i)) = distractor;
    relocation(relocation_order(i)) = 3;
end

% for i=257:512
%     main_index(relocation_order(i)) = 0;
%     reloc_tar(relocation_order(i)) = 0;
%     reloc_dis(relocation_order(i)) = 0;
%     relocation(relocation_order(i)) = 4;
%     
%     fixed_config_no(relocation_order(i)) = 0;
% end

block_no = 1;

for epoch=1:3
    
    for i=1:256 % change to 1536

        if rem(((epoch-1)*256 + i - 1),50) == 0
            %previous_score = 0;
            blockText = strcat('TEST BLOCK NO.',num2str(block_no));
            widthB = RectWidth(Screen('TextBounds',wPtr,blockText));
            Screen('DrawText',wPtr,blockText,xcenter-widthB/2,ycenter-20,[255 255 255]);
            Screen(wPtr,'Flip');
            pause(1);
        end
        
        if main_index(i) == 0
            fixation_screen(wPtr,xcenter,ycenter);               
            [test_rt((epoch-1)*256 + i),test_accuracy((epoch-1)*256 + i)] = new_context(wPtr,imgt,flip_target(i));
            test_RT = cat(1,test_RT,test_rt((epoch-1)*256 + i));
            test_ACC = cat(1,test_ACC,test_accuracy((epoch-1)*256 + i));
        elseif main_index(i) == 1 
            fixation_screen(wPtr,xcenter,ycenter);        
            [test_rt((epoch-1)*256 + i),test_accuracy((epoch-1)*256 + i)] = irrelevant_context(wPtr,imgt,q(fixed_config_no(i),:),flip_target(i),reloc_tar(i),reloc_dis(i),distractor_location_matrix(i));
            test_RT = cat(1,test_RT,test_rt((epoch-1)*256 + i));
            test_ACC = cat(1,test_ACC,test_accuracy((epoch-1)*256 + i));
        end

        %previous_score = total_score;

        relevance_index_test = cat(1,relevance_index_test,main_index(i));
        fixed_config_record = cat(1, fixed_config_record,fixed_config_no(i));
        Reloc = cat(1,Reloc,relocation(i));
        epoch_log = cat(1,epoch_log,epoch);
        trial_no = cat(1,trial_no,(epoch-1)*256 + i);
        
        if rem(((epoch-1)*256 + i),50) == 0  % change to 201 and 401
%             block_score(block_no) = total_score;
%             
%             for rep = 1:block_no
%                 block_score_text = strcat('Block_',num2str(rep),'_Score____',num2str(block_score(rep)));
%                 Screen('DrawText',wPtr,block_score_text, 20+ 1020*fix(rep/16), 20 + 44*((rep-15*fix(rep/16))-1),[255 255 255]);
%             end
            
            avgRT = mean(test_rt((((epoch-1)*256 + i)-49):((epoch-1)*256 + i)));
            avgACC = mean(test_accuracy((((epoch-1)*256 + i)-49):((epoch-1)*256 + i)))*100;

            pauseText = 'Please rest for 10 seconds.';
            widthP = RectWidth(Screen('TextBounds',wPtr,pauseText));
            resumeText = 'Please press any key to resume the experiment.';
            widthR = RectWidth(Screen('TextBounds',wPtr,resumeText));
            FeedbackText = strcat('Your average response time is_',num2str(avgRT),'_and accuracy is_',num2str(avgACC),'_percent');
            widthFT = RectWidth(Screen('TextBounds',wPtr,FeedbackText));
            Screen('DrawText',wPtr,pauseText,xcenter-widthP/2,ycenter-20,[255 255 255]);
            Screen('DrawText',wPtr,FeedbackText,xcenter-widthFT/2,ycenter+20,[255 255 255]);
            Screen(wPtr,'Flip');
            pause(10);
            Screen('DrawText',wPtr,resumeText,xcenter-widthR/2,ycenter-20,[255 255 255]);
            
%             for rep = 1:block_no
%                 block_score_text = strcat('Block_',num2str(rep),'_Score____',num2str(block_score(rep)));
%                 Screen('DrawText',wPtr,block_score_text, 20+ 1020*fix(rep/16), 20 + 44*((rep-15*fix(rep/16))-1),[255 255 255]);
%             end
            
            Screen(wPtr,'Flip');
            KbWait([],3);
            
            block_no = block_no + 1;
        end
        
    end
    
end

thank_text = 'Thank you for your participation.';
width_thank=RectWidth(Screen('TextBounds',wPtr,thank_text));
wait_text = 'The data is being written up in the file. Please wait';
width_wait=RectWidth(Screen('TextBounds',wPtr,wait_text));
Screen('DrawText', wPtr,thank_text , xcenter-width_thank/2,300, [255 255 255]); 
Screen('DrawText', wPtr,wait_text , xcenter-width_wait/2,400, [255 255 255]);     
Screen(wPtr, 'Flip');

header = {'subject_number','training_RT','training_ACC','trial_no','test_relevance','fixed_config_no','epoch','relocation','test_RT','test_ACC'};
xlswrite(dbase, header, 1, 'A1')
xlswrite(dbase, subject_number, 1, 'A2:A769')
xlswrite(dbase, training_RT, 1, 'B2:B769')
xlswrite(dbase, training_ACC, 1, 'C2:C769')
xlswrite(dbase, trial_no, 1, 'D2:D769')
xlswrite(dbase, relevance_index_test, 1, 'E2:E769')
xlswrite(dbase, fixed_config_record, 1, 'F2:F769')
xlswrite(dbase, epoch_log, 1, 'G2:G769')
xlswrite(dbase, Reloc, 1, 'H2:H769')
xlswrite(dbase, test_RT, 1, 'I2:I769')
xlswrite(dbase, test_ACC, 1, 'J2:J769')
Screen('CloseAll');

