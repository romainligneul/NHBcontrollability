%%%%% RUN 1
clear all

%S.number = 1;
load('active_subject.mat');

E.serialport = 1;
E.serialkeys = 1;
E.subject = S;

% load smartPST
addpath(genpath('../SmartPST'));

% stims & functions
addpath('shooter_functions');
E.stimdir = 'shooter_stim/';

%%% define instructions
E.instructions.dir =[E.stimdir 'instructions\'];
E.instructions.left_right_keycode = [37 39];

%%% open PST screen
w = open_PSTscreen(0, [180 180 180], 2,1, 1);
w.bg = [180 180 180];

% general timings;
E.timing.prelaunch_jitter = '0.25 + rand/4'; % to be evaluated;
E.timing.bird_max_duration = 3;
E.timing.bird_grey_duration = 2;
E.timing.gun_max_duration = 2;
E.timing.gun_grey_duration = 1;
E.timing.correct_resp_delay = [.75 1.25]; % a 200 ms window
E.timing.outcome_shrinkdur = 0.3;
E.timing.outcome_postshrinkdur = 1.2;
E.timing.restdur = 4;
% key map association
if mod(E.subject.number,2)==1 % case bluebird on left => blue bullet on right
    E.left_right_keycode = [39 37]; % press right to get blue (i.e. to get find(resp==keymap) = 1, i.e. 1)
else
    E.left_right_keycode = [37 39]; % press right to get blue (i.e. to get find(resp==keymap) = 1, i.e. 1)
end

%
E.bird.path.x_path = [0.2 0.5];
E.bird.path.y_path = [0.5 0.5];
E.bird.resize = 0.25; % only for image loading (to save ram)
E.bird.size = [0.05 0.05]; % for display
%
E.gun.path.height = 0.2;
E.gun.path.x_path = [0.5 0.5];
E.gun.path.y_path = [0.3 0.5];
E.gun.path.full_duration = 2;
E.gun.path.grey_duration = 2;
E.gun.resize = 0.25; % only for image loading
E.gun.size = [0.1 0.1]; % for display

%
E.frame.pos = [0.5 0.5];
E.frame.size = [815 547]/815;
E.frame.resize = 1;

% load feedback texture
[img, ~, alpha] = imread([E.stimdir 'negative_feedback.png']);
img(:,:,4) = alpha;
E.feedback.texture_id(1) = Screen('MakeTexture',w.id,img);
[img, ~, alpha] = imread([E.stimdir 'positive_feedback.png']);
img(:,:,4) = alpha;
E.feedback.texture_id(2) = Screen('MakeTexture',w.id,img);
E.feedback.rect = scrconv(w,[0.46 0.36 0.54 0.44]);

% build experiment vector
E.stat.samefreq = 0.5; %
E.stat.changegunfreq = 0.5; % defines prob that gun color changes if same == false.
E.stat.changebirdfreq = 0.5; % defines prob that bird color changes if same == false.

% change type vector
% 1 = faithful / 2 = sensorimotor surprise /
% 3 = bird change (SS) / 4 = bullet change (SAS)
% condition indice + 4 indicates a right-sided trial (i.e. other color)
% 0 = rest intervals
% uses precomputed design based on Tor Wager's GA algorithm (see functions)
E.stimlist = zeros(1,300);
E.birdchange_conds = [2 4 6 8];
E.gunchange_conds =  [3 4 7 8];
E.leftside_conds = [1 2 3 4];
% do motor agency orthogonalization
allcond = unique(E.stimlist(E.stimlist>0)); condorder = [1 2 3 4];
E.stimlist2 = zeros(size(E.stimlist));
% for c = 1:length(allcond)
%     condorder = condorder(randperm(4));
%     condind = find(E.stimlist==allcond(c));
%     dumvec = repmat(condorder,1,ceil(length(condind)/length(condorder)));
%     dumvec = dumvec(1:length(condind)); % last items have a chance to be cropped
%     dumvec = dumvec(randperm(length(dumvec)));
%     E.stimlist2(condind) = dumvec;
% end
% merge cond 3 and 4 into one single agentic condition
E.stimlist2(E.stimlist2==4)=3;

%%% load instruction textures
E = instructions_tool(E,w,'load');

%%% load bird images
% raw = color (1 = grey, 2 = blue, 3 = magenta) & column = side (left = 1, right = 2)
for c = 1:3
    for s = 1:2
        [img, ~, alpha] = imread([E.stimdir 'bird_' num2str(c) '_' num2str(s) '.png']);
        E.bird.img{c,s} = imresize(img, E.bird.resize);
        E.bird.img{c,s}(:,:,4) = imresize(alpha, E.bird.resize);
        E.bird.texture{c,s} = Screen('MakeTexture',w.id,E.bird.img{c,s});
    end
end
E.bird.rectsize = [scrconv(w,E.bird.size(1), 1)-scrconv(w,0, 1) scrconv(w,E.bird.size(2), 2)];

%%% load bullets images
% raw = color (1 = grey, 2 = blue, 3 = magenta)
for c = 1:3
    [img, ~, alpha] = imread([E.stimdir 'bullet_' num2str(c) '.png']);
    E.gun.img{c,1} = imresize(img, E.gun.resize);
    E.gun.img{c,1}(:,:,4) = imresize(alpha, E.gun.resize);
    E.gun.texture{c,1} = Screen('MakeTexture',w.id,E.gun.img{c,1});
end
E.gun.rectsize = [scrconv(w,E.gun.size(1), 1)-scrconv(w,0, 1) scrconv(w,E.gun.size(2), 2)];

%%% load frame images
% raw 1: col1:left col2:right frame
% raw 2 = col1: canon (aligned with frame)
for s = 1:2
    [img, ~, alpha] = imread([E.stimdir 'frame_' num2str(s) '.png']);
    E.frame.img{1,s} = imresize(img, E.frame.resize);
    E.frame.img{1,s}(:,:,4)  = imresize(alpha, E.frame.resize);
    E.frame.texture{1,s} = Screen('MakeTexture',w.id,E.frame.img{1,s});
end
[img, ~, alpha] = imread([E.stimdir 'frame.png']);
E.frame.img{2,1} = imresize(img, E.frame.resize);
E.frame.img{2,1}(:,:,4)  = imresize(alpha, E.frame.resize);
E.frame.texture{2,1} = Screen('MakeTexture',w.id,E.frame.img{2,1});
E.frame.rect = scrconv(w,[E.frame.pos(1)-E.frame.size(1)/2,E.frame.pos(2)-E.frame.size(2)/2, E.frame.pos(1)+E.frame.size(1)/2,E.frame.pos(2)+E.frame.size(2)/2]);

%%% prepare run_mat structures
% configure serial port and wait for scanner
% which triggers to send/receive when?
% left = 97/65 // middle = 98/66 // right = 99/67 // extreme right = 100/68
if E.serialport
    
    E.serialtrig.reinforcer = {'61', '62', '63'}; % + / - / null
    E.left_right_keycode = [97 99];
    E.left_middle_right_keycode = [97 98 99];
    E.instructions.left_right_keycode = [97 99];

    % open eye-track + respi + cardio port
    specialSettings = [];
    joker = '';
    baudRate = 115200;
    portSettings = sprintf('%s %s BaudRate=%i ReadFilterFlags=1', joker, specialSettings, baudRate);
    E.mainserialport = IOPort('OpenSerialPort', 'COM2',portSettings);
    % open scan serial port for asynchronous recording
%     joker = '';
%     specialSettings = [];
%     sampleFreq = 120;
%     baudRate = 115200;
%     InputBufferSize = sampleFreq * 4800;
%     readTimeout = max(10 * 1/sampleFreq, 15);
%     readTimeout = min(readTimeout, 21);
%     portSpec = FindSerialPort('COM3', 3);
%     portSettings = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=0 ReceiveTimeout=%f ReceiveLatency=0.0001', joker, specialSettings, baudRate, InputBufferSize, readTimeout);
%     E.scanserialport = IOPort('OpenSerialPort', portSpec, portSettings);
%     asyncSetup = sprintf('%s BlockingBackgroundRead=1 StartBackgroundRead=1', joker);
%     IOPort('ConfigureSerialPort', E.scanserialport, asyncSetup);
%     treceived = [];
%     while length(treceived)<1
%         [pktdata, treceived] = IOPort('Read', E.scanserialport, 1, 1);
%     end
end
E.timing.start_time = GetSecs;

names = {'fullAgency_left', 'motorDisrupt_left', 'ssDisrupt_left', 'sasDisrupt_left','sssasDisrupt_left',...
    'fullAgency_right', 'motorDisrupt_right', 'ssDisrupt_right', 'sasDisrupt_right','sssasDisrupt_right',...
    'rest', 'missed_target', 'motor'};
onsets = cell(1,length(names));
[E output] = instructions_tool(E,w, 'display', 1, 1, 1);
[E output] = instructions_tool(E,w, 'display', 1, 1, 1);

test = 0;
t = 0;
E.start_time = GetSecs;
E.trainingdur = 1.5*60;

while GetSecs-E.start_time < E.trainingdur
    
    t = t+1;
    % blank
%     if E.stimlist(t)==0
%         Screen('Flip', w.id)
%         onsets{E.stimlist(t)+1}(t) = GetSecs-E.timing.start_time;
%         WaitSecs(E.timing.restdur);
%         continue;
%     end
    
    side = randi(2);      % left sided trial

    
    if mod(E.subject.number,2)==1 % odd subject number
        E.expected_birdcolor(t) = side + 1;     % = blue on the left
    else                          % even subject number
        E.expected_birdcolor(t) = 3-side+1;     % = rose on the left
    end;
    
    % 3/8
    if ismember(E.stimlist(t), E.birdchange_conds) % case where the bird has not the correct color
        E.actual_birdcolor(t) = 5-E.expected_birdcolor(t);
    else
        E.actual_birdcolor(t) = E.expected_birdcolor(t);
    end
    
    %%% animated paths
    if side == 1
        bird_xrange = [E.frame.rect(1) mean(E.frame.rect([1 3]))];
    else
        bird_xrange = [E.frame.rect(3) mean(E.frame.rect([1 3]))];
    end
    gun_yrange = [E.frame.rect(4) mean(E.frame.rect([2 4]))];
    
    %%% draw once and wait for jitter
    bird_xpos = bird_xrange(1);
    gun_ypos = gun_yrange(1);
    draw_shooter(w, E, side, 1, 1,bird_xpos, gun_ypos, []);
    Screen('Flip', w.id)
    if E.serialport
        % write state_hyp code
        IOPort('Write', E.mainserialport, uint8(20+E.stimlist(t)), 0);
    end
    onsets{E.stimlist(t)+1}(t) = GetSecs-E.timing.start_time;
    jitdur = eval(E.timing.prelaunch_jitter);
    WaitSecs(jitdur);
    
    %%% initialize response
    E.choice(t) = 0;
    bird_onmove = 0;
    gun_onmove = 0;
    %%% start animation
    stop_loop = 0;
    
    E.start_bird_move(t) = GetSecs;
    bird_onmove = 1;
    E.outcome(t) = 0;
    if E.serialkeys==1
        IOPort('Purge', E.mainserialport);
    end
    
    if E.stimlist(t)==0
        E.actual_birdcolor(t)=1;
        E.expected_birdcolor(t)=1;
        E.actual_guncolor(t)=1;
        E.expected_guncolor(t)=1;        
    end
    
    while stop_loop == 0
                
        if E.serialkeys==0
            [keydown, secs, keyCode] = KbCheck();
        else
            [keydown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_right_keycode)
        end
        
        current_dur = (GetSecs-E.timing.start_time)-onsets{E.stimlist(t)+1}(t)-jitdur;
        
        if keydown && gun_onmove == 0
            if ismember(find(keyCode, 1, 'first'), E.left_right_keycode(1:2));
                E.choice(t) = find(ismember(E.left_right_keycode(1:2), find(keyCode,1,'first')));
                E.rt(t) = current_dur;
                % case where gun color changed ( 4 / 9 )
                if ismember(E.stimlist(t), E.gunchange_conds)
                    E.expected_guncolor(t) = E.choice(t)+1;
                    E.actual_guncolor(t) = 3-E.choice(t)+1;
                else % case unchanged
                    E.expected_guncolor(t) = E.choice(t)+1;
                    E.actual_guncolor(t) = E.choice(t)+1;
                end;
                if E.stimlist(t)==0
                    E.actual_guncolor(t) = 1;
                end
                if t<(length(E.stimlist)/2)
                    E.choiceACC(t) = double(E.expected_guncolor(t)==E.expected_birdcolor(t));
                    E.outcome(t) = double(E.actual_guncolor(t)==E.actual_birdcolor(t));if E.outcome(t)==0;E.outcome(t)=-1;end;
                else
                    E.choiceACC(t) = double(E.expected_guncolor(t)~=E.expected_birdcolor(t));
                    E.outcome(t) = double(E.actual_guncolor(t)~=E.actual_birdcolor(t));if E.outcome(t)==0;E.outcome(t)=-1;end;
                end
                E.rtACC(t) = double(E.rt(t)>E.timing.correct_resp_delay(1) && E.rt(t)<E.timing.correct_resp_delay(2));
                if ismember(E.stimlist2(t),3) || ismember(E.stimlist2(t),0) % launch only in case of preserved motor agency
                    E.start_gun_move(t) = GetSecs;
                    gun_onmove = 1;
                end
                if E.rtACC(t)==0
                    E.outcome(t) = -2;
                end
            end
        end
        
        % update bird
        bird_xpos = bird_xrange(1) + (bird_xrange(2)-bird_xrange(1))*((GetSecs-E.start_bird_move(t))/E.timing.bird_max_duration);
        if current_dur > E.timing.bird_grey_duration
            birdcolor = E.actual_birdcolor(t);
            if gun_onmove
                try
                    guncolor = E.actual_guncolor(t);
                catch
                    guncolor = 1;
                end                 
            else
                guncolor=1;
            end
        else
            birdcolor = 1;
            guncolor = 1;
        end
        % update gun (once a response has been given and after bird starts)
        % second condition to release the gun as soon as possible (disrupted motor
        % agency)
       % if gun_onmove == 1 || ismember(E.stimlist2(t),1)
       % premature move
         if ismember(E.stimlist2(t),1) && current_dur>E.timing.correct_resp_delay(1)+0.015 % second case = prerelease
             if gun_onmove==0
                 E.start_gun_move(t)=GetSecs;
                 gun_onmove = 1;
             end
             gun_ypos = gun_yrange(1) + (gun_yrange(2)-gun_yrange(1))*((GetSecs-E.start_gun_move(t))/E.timing.gun_max_duration);
         % delayed move
         elseif ismember(E.stimlist2(t),2) && current_dur>E.timing.correct_resp_delay(2)-0.015 
             if gun_onmove==0
                 E.start_gun_move(t)=GetSecs;
                 gun_onmove = 1;
             end
             gun_ypos = gun_yrange(1) + (gun_yrange(2)-gun_yrange(1))*((GetSecs-E.start_gun_move(t))/E.timing.gun_max_duration);
         elseif ismember(E.stimlist2(t),3) && gun_onmove
                gun_ypos = gun_yrange(1) + (gun_yrange(2)-gun_yrange(1))*((GetSecs-E.start_gun_move(t))/E.timing.gun_max_duration);
         elseif ismember(E.stimlist2(t),0) && gun_onmove
                gun_ypos = gun_yrange(1) + (gun_yrange(2)-gun_yrange(1))*((GetSecs-E.start_gun_move(t))/E.timing.gun_max_duration);
         end
        
        % stops animation because one of the bird elements has finished its
        % move
        if current_dur > E.timing.bird_max_duration % || current_dur-E.start_gun_move(t) > E.timing.gun_max_duration %|| current_dur-E.timing.bird_grey_duration > E.timing.bird_max_duration
            E.outcome_onset(t) = GetSecs;
            while GetSecs-E.outcome_onset(t) < E.timing.outcome_shrinkdur;
                shrink = 1-((GetSecs-E.outcome_onset(t))/ E.timing.outcome_shrinkdur);
                draw_shooter(w, E, side, birdcolor,guncolor, bird_xpos, gun_ypos,E.outcome(t),shrink);
                Screen('Flip', w.id);
            end
            E.timing.outcome_postshrinkdur
            draw_shooter(w, E, side, birdcolor, guncolor,bird_xpos, gun_ypos,E.outcome(t),0);
            if E.stimlist(t)>0
                if E.outcome(t) == 1
                    Screen('DrawTexture', w.id, E.feedback.texture_id(2), [], E.feedback.rect);
                else % will display a negative feedback if no response has occured (i.e. E.outcome(t) == 0 / or -1)
                    Screen('DrawTexture', w.id, E.feedback.texture_id(1), [], E.feedback.rect);
                end
                Screen('Flip', w.id);
                if E.serialport
                    % write state_hyp code
                    IOPort('Write', E.mainserialport, uint8(45+E.outcome(t)), 0);
                end
                WaitSecs(E.timing.outcome_postshrinkdur);
            else
                E.outcome(t)=-5;
                if E.serialport
                    % write state_hyp code
                    IOPort('Write', E.mainserialport, uint8(45+E.outcome(t)), 0);
                end
                WaitSecs(E.timing.outcome_postshrinkdur); 
                Screen('Flip', w.id);
            end

            stop_loop=1;
            % simply update positions
        else
            test = test+1;
            draw_shooter(w, E, side, birdcolor, guncolor,bird_xpos, gun_ypos,[],[]);
            Screen('Flip', w.id);            
        end
        
    end
    
end

% %%% post process serial port buffer
% L.scanportlog = [];
% if E.serialport
%    % treceived =treceived(1);
%     tEnd = GetSecs;
%     fprintf('TRIAL LOOP STOPPED AT t = %f seconds. Now fetching pending triggers up to that point...\n', tEnd);
%     % Fetch all pending data that has been received up to systemtime tEnd:
%     while (treceived < tEnd) && (IOPort('BytesAvailable', E.scanserialport) > 0)
%         % Same as above, but now a non-blocking read (flag == 0):
%         [pktdata, treceived] = IOPort('Read', E.scanserialport, 0, 1);
%         L.scanportlog = [L.scanportlog;pktdata, treceived];
%     end
% end
filename = mfilename;
save([filename '_' S.fullid '.mat']);
try
    save(['M:\fMRI_logfiles\' S.fullid '\' filename '_' S.fullid '.mat'])
end

[E output] = instructions_tool(E,w, 'display', 2, 2, 2);
[E output] = instructions_tool(E,w, 'display', 2, 2, 2);
[E output] = instructions_tool(E,w, 'display', 2, 2, 2);

Screen('CloseAll')
