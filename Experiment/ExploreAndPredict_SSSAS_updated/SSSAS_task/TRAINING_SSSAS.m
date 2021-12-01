clear all;

% dependencies needed
addpath(genpath('../SmartPST'));
addpath(genpath('SASSS_functions'));
E.stimdir = ['SASSS_stim\'];
load('active_subject.mat');

% if triggers must be sent and received
E.serialport = 0;
% if buttonbox is used (Donders'fMRI setup)
E.serialkeys = 0;

try
tic
%%% open PST screen
w = open_PSTscreen(S.screen, [180 180 180], 2,1, 1);
w.bg = [180 180 180];
%Screen('CloseAll')

%%% define instructions
E.instructions.dir =[E.stimdir 'instructions_' S.language '\'];
E.instructions.left_right_keycode = [37 39];

%%% define timings
E.timing.stdpostchoice = 0.025;
%E.timing.postfade = 0.75;
E.timing.stdminimaldur = 0.5;
E.timing.predhighlight = 0.2;
E.timing.predfeedback = 0.7; % display of the feedback
E.timing.pred_postjitter = jitter_generator(400, 1, 0.5, 0.05:0.01:1.5); 
E.timing.stdwarning = 1.5;
E.timing.fadedelay = 1;
E.timing.fadedur = 0.25;
E.timing.predwarning = 3;
E.timing.fixdur1 = 'rand*0.25 + 0.25';
E.timing.fixdur2 = 'rand*1 + 1';
E.timing.postpredresp = 0.25;
E.timing.postpredresp2 = 0.7; % 'outcome'
E.timing.runtime = 14*60; % in seconds
E.post_stdjitter = 0.3*ones(1,1000);%jitter_generator(2000, 1, 0.75, 0.25:0.01:5);

%%% important misc
E.shape_names = {'triangle', 'square', 'circle'};
E.left_right_keycode = [37 39];
E.left_middle_right_keycode = [37 40 39];
E.explore.logheader = {'t', 'L.streak(r)length', 'block_rev', 'cond','noise','state', 'next_state', 'expected_state', 'violation', 'side', 'resp_side', 'resp_RT', 'resp_choice', 'warning', 'post_jitter', 'trial_onset', 'resp_onset', 'fade_onset', 'fade_offset'};
E.noise = [0 0 0]; % [0 0.1 0.2] gives on average "at least 1 violation" in 50% of the sequences of 6
E.predictfrequency = 6;
E.min_prediction_per_reversal = 4;
E.predict_maxstreak = 4;


%%% load textures
% run 1;
predictnames = {{'select_triangle', 'select_square', 'select_circle'},{'select_1', 'select_2', 'select_3'}}
%E.predict.names = predictnames{S.tasktype(1)};
%%% load textures for exploratory trials
explorenames = {{{'triangle_1', 'triangle_2'};{'square_1', 'square_3'}; {'circle_2', 'circle_3'}}, {{'triangle_1', 'square_1'};{'triangle_2', 'circle_2'}; {'square_3', 'circle_3'}}}, 
%E.explore.names = explorenames{S.tasktype(1)};%{{'triangle_1', 'square_1'};{'triangle_2', 'circle_2'}; {'square_3', 'circle_3'}};

E.predict.default_mapping = [1 2 3];

%%% define rectangles for selection trials
% targets
E.predict.target_xwidth = [0.3 0.5 0.7];
E.predict.target_ypos = 0.28;
E.predict.target_halfsize = 0.05;
for o = 1:length(E.predict.target_xwidth)
    E.predict.target_rect{o} = scrconv(w,[E.predict.target_xwidth(o)-E.predict.target_halfsize, E.predict.target_ypos-E.predict.target_halfsize, E.predict.target_xwidth(o)+E.predict.target_halfsize, E.predict.target_ypos+E.predict.target_halfsize]);
end
% hypothesis
E.predict.hypothesis_xpos = 0.5;
E.predict.hypothesis_ypos = 0.52;
E.predict.hypothesis_halfsize = 0.05;
E.predict.hypothesis_rect = scrconv(w,[E.predict.hypothesis_xpos-E.predict.hypothesis_halfsize, E.predict.hypothesis_ypos-E.predict.hypothesis_halfsize, E.predict.hypothesis_xpos+E.predict.hypothesis_halfsize, E.predict.hypothesis_ypos+E.predict.hypothesis_halfsize]);



%%% define rectangles for exploratory trials
E.explore.target_xwidth = [0.44 0.56];
E.explore.target_ypos = [0.52];
E.explore.target_halfsize = 0.05;
for o = 1:length(E.explore.target_xwidth)
    E.explore.target_rect{o} = scrconv(w,[E.explore.target_xwidth(o)-E.explore.target_halfsize E.explore.target_ypos-E.explore.target_halfsize E.explore.target_xwidth(o)+E.explore.target_halfsize E.explore.target_ypos+E.explore.target_halfsize]);
end
% mapping between {side}{state}(resp_side) => option chosen
E.explore.mapping{1} = {[1 2], [1 3], [2 3]};
E.explore.mapping{2} = {[2 1], [3 1], [3 2]};

%%% load warning texture
[img, ~, alpha] = imread([E.stimdir 'warning_minimal.png']);
img(:,:,4) = alpha;
E.warning.texture_id = Screen('MakeTexture',w.id,img);
E.warning.rect = scrconv(w,[0.45 0.45 0.55 0.55]);

%%% load feedback texture
[img, ~, alpha] = imread([E.stimdir 'negative_feedback.png']);
img(:,:,4) = alpha;
E.feedback.texture_id(1) = Screen('MakeTexture',w.id,img);
[img, ~, alpha] = imread([E.stimdir 'positive_feedback.png']);
img(:,:,4) = alpha;
E.feedback.texture_id(2) = Screen('MakeTexture',w.id,img);
E.feedback.rect = scrconv(w,[0.46 0.36 0.54 0.44]);

%%% load instruction textures
E = instructions_tool(E,w,'load');

%%% load transition matrices in E structure
run('make_matrices');

%%%
E.cond = S.first5{1};

%%% build tested states vector
E.testedstates = [];
for cc = 1:200 % dummy limit
    E.testedstates = [E.testedstates repmat(Shuffle([1 2 3]),1, 3)];
end


%%% MAIN LOOP

% configure serial port and wait for scanner
% which triggers to send/receive when?
% left = 97/65 // middle = 98/66 // right = 99/67 // extreme right = 100/68
if E.serialport
    
    E.serialtrig.predictstate_action{1} = {'21', '22', '23'}; 
    E.serialtrig.predictstate_action{2} = {'24', '25', '26'}; 
    E.serialtrig.predictstate_action{3} = {'27', '28', '29'}; 
    E.serialtrig.predictstate_action{4} = {'30', '31', '32'};
    E.serialtrig.explorestate{1} = {'41', '42', '43'}; %
    E.serialtrig.explorestate{2} = {'44', '45', '46'}; % 
    E.serialtrig.explorestate{3} = {'47', '48', '49'}; %
    E.serialtrig.explorestate{4} = {'50', '51', '52'}; %
    
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
    joker = '';
    specialSettings = [];
    sampleFreq = 120;
    baudRate = 115200;
    InputBufferSize = sampleFreq * 4800;
    readTimeout = max(10 * 1/sampleFreq, 15);
    readTimeout = min(readTimeout, 21);
    portSpec = FindSerialPort('COM3', 3);
    portSettings = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=0 ReceiveTimeout=%f ReceiveLatency=0.0001', joker, specialSettings, baudRate, InputBufferSize, readTimeout);
    E.scanserialport = IOPort('OpenSerialPort', portSpec, portSettings);
    asyncSetup = sprintf('%s BlockingBackgroundRead=1 StartBackgroundRead=1', joker);
    IOPort('ConfigureSerialPort', E.scanserialport, asyncSetup);
    treceived = [];
    while length(treceived)<1
        [pktdata, treceived] = IOPort('Read', E.scanserialport, 1, 1);
    end
end
%%% display first round of instructions
[E output] = instructions_tool(E,w, 'display', 1,5);
E.training2rule = [4 5 6 7;8 9 10 11]+3; 
newruleind = 15;
% initialize run
r = 0;          % number of reversal which have occured (+1)
t = 0;          % global indice for exploratory trials
tt = 0;         % global indice for prediction trials
ttt = 0;        % global indice for prediction doublets
L.start_time = GetSecs;
current_time = L.start_time;

for r = 1:4;
    
    % update reversal id
   % r = r +1;
    % update time
    L.criterion(r,1) = 0;
    L.streak(r) = 0;
    % initialize
    state(1) = randi(3);
    tstreak = 0;
    E.predict.names = predictnames{S.trainingtype(2,r)};
    E.explore.names = explorenames{S.trainingtype(2,r)};
    
    % load textures
    for st = 1:3
        
        for l = 0:1 % column = selected or not
            [img, ~, alpha] = imread([E.stimdir E.predict.names{st} '_' num2str(l) '.png']);
            img(:,:,4) = alpha;
            E.predict.texture_id(st,l+1) = Screen('MakeTexture',w.id,img);
            %         Screen('DrawTexture', w.id, E.predict.texture_id(st,l+1));
            %         Screen('Flip', w.id);
            %         WaitSecs(2);
        end
        
    end
    % row = states (in run A: states = shapes)
    for st = 1:3
        for n = 1:2 % column: 1 = left / 2 = right (to be inverted when revside = 1)
            [img, ~, alpha] = imread([E.stimdir E.explore.names{st}{n} '.png']);
            img(:,:,4) = alpha;
            E.explore.texture_id(st,n) = Screen('MakeTexture',w.id,img);
            %         Screen('DrawTexture', w.id, E.predict.texture_id(st,n));
            %         Screen('Flip', w.id);
            %         WaitSecs(1);
        end
    end
    
    % find indice corresponding to the correct slide for the rule
    %Screen('TextSize', w.id, 40);
    [E output] = instructions_tool(E,w, 'display', newruleind, newruleind,newruleind);
    ruleind = E.training2rule(S.trainingtype(2,r),S.trainingtype(1,r));
    [E output] = instructions_tool(E,w, 'display', ruleind,ruleind,ruleind);
    
    while L.criterion(r,1) == 0
        
        % update relevant indices
        L.streak(r) = L.streak(r) + 1;
        t = t+1;
        
        % check if run should be ended
        current_time = GetSecs;
        
        % assign side
        side = randi(2);
        if E.serialport
            % write state UC/C code
            IOPort('Write', E.mainserialport, E.serialtrig.explorestate{S.trainingtype(1,r)}{state}, 0);
        end
        % play exploratory trial
        [explore_output choice] = exploratory_trial( E, w, state, side, E.post_stdjitter(t));
        
        % compute transition
        [snext smax] = make_transition(E.T, S.trainingtype(1,r), E.noise, state, choice)
        
        % check whether the rule was violated (special flag for irrelevant
        % trials
        if L.streak(r) == 1 || mod(L.streak(r)-1,E.predictfrequency)==0
            violation = 2;
        else
            violation = double(snext == smax);
        end
        
        % log information
        L.explore.log(t,:) = [t L.streak(r) r S.trainingtype(1,r) E.noise snext smax violation explore_output]
        state = snext;
        
        %%% play predictive trial
        if mod(L.streak(r),E.predictfrequency)==0
            
            % setup
            ttt = ttt +1;
            tstreak = tstreak+1; % update local indice
            hyp_order = [1 2]; hyp_order = hyp_order(randperm(2));            
            hyp_state = E.testedstates(ttt);
            feedback = [2 2];
            feedback = feedback(randperm(2))-1;
            % 
            for p = 1:2
                 
                 tt = tt+1; % update global predictive indice
                 % reorder every time to avoid bad surprises
                 ordering = E.predict.default_mapping(randperm(3));
                 
                 % compute virtual transition
                 
                 hyp_choice = E.explore.mapping{1}{hyp_state}(hyp_order(p));
                 
                 [~, correct_resp ] = make_transition(E.T, S.trainingtype(1,r), E.noise, hyp_state, hyp_choice)
                 
                 % send trigger
                 if E.serialport
                     % write state_hyp code
                     IOPort('Write', E.mainserialport, E.serialtrig.predictstate_action{S.trainingtype(1,r)}{hyp_state}, 0);
                 end
                 
                 [output resp_choice resp_acc] = predictive_trial( E, w, hyp_state, ordering, hyp_order(p), correct_resp, feedback(p), E.timing.pred_postjitter(tt));
                 
                 L.predict.acc{r}(tstreak,p) = resp_acc;
                 
                 L.predict.log(tt,:) = [t tt ttt L.streak(r) r S.trainingtype(1,r) p output];
                 
            end
            %%%%%% FIX ME DISPLAY RULE AFTER PREDICTION TRIAL.

            if (L.streak(r)/E.predictfrequency)>=E.predict_maxstreak
                L.criterion(r,1)=-1;
            else
                [E output] = instructions_tool(E,w, 'display', ruleind,ruleind,ruleind);
            end
        end
        
        %
    end
    
end

instructions_tool(E,w, 'display', 6,6);

% %%% post process serial port buffer
% if E.serialport
%     tEnd = GetSecs;
%     fprintf('TRIAL LOOP STOPPED AT t = %f seconds. Now fetching pending triggers up to that point...\n', tEnd);
%     % Fetch all pending data that has been received up to systemtime tEnd:
%     while (treceived < tEnd) && (IOPort('BytesAvailable', E.scanserialport) > 0)
%         % Same as above, but now a non-blocking read (flag == 0):
%         [pktdata, treceived(end+1)] = IOPort('Read', E.scanserialport, 0, 1);
%     end
% end
filename = mfilename;

save([S.subj_logdir filename '_' S.fullid '.mat'], 'S','E','L')

clc
toc
disp(num2str(mean2(cell2mat(L.predict.acc))));

catch err
    rethrow(err);
    filename = mfilename;
    save([S.subj_logdir filename '_' S.fullid '_interrupted.mat'], 'S','E','L')
    Screen('CloseAll');
    ShowCursor;
end


Screen('CloseAll');
