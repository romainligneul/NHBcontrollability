%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Single-script experimental file for the SAS experiment (2016)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

run('objects_generator');
addpath(genpath('functions_all'));

load('active_subject');
KbName('UnifyKeyNames');


%% Experiment configuration
load('counterbalancing');

%%% timing
E.timing.stdpostchoice = 0.05;
E.timing.fadedur = 0.25;
E.timing.postfade = 0.75;
E.timing.stdminimaldur = 0.5;
E.timing.testhighlight = 0.3;
E.timing.testpostfix = 0.5;
E.timing.stdwarning = 1.5;
E.timing.predwarning = 4;
E.timing.fixdur1 = 'rand*0.25 + 0.25';
E.timing.fixdur2 = 'rand*1 + 1';
E.timing.postpredresp = 0.3;
E.timing.postpredresp2 = 0.7; % 'outcome'
E.externalfolder = 'M:\Experiments_Logfiles\SAS_protocol\SAS_logs\';

%%% general
E.timing.trialmeanperiod = 0.5;
E.timing.trialspanperiod = 0.25;
E.predbuttoncodes = [37 40 39]; % left right midde ascii codes <=> 1, 2, 3

% manage sound
E.alarm = audioread('SAS_stims/alarm.wav');
E.alarm = [E.alarm, E.alarm]';
InitializePsychSound;
soundriver = PsychPortAudio('Open', [], [], 0,[], 2);

%% APPEARANCE
E.fontsize = 30;
E.fontstyle = 'calibri';
E.lightgreycol = [180 180 180];

% the 3 isoluminant colors
E.colors = {[194,94,224],... % purple
    [30,142,236]... % blue
    [180,121,0]}; % yellow. Luminance matched.

%%% positions, size.
% left
E.pos{1}= [0.45,0.525];
% right
E.pos{2}= [0.55,0.525];
% testleft
E.pos{3} = [0.35,0.35];
% testmid
E.pos{4} = [0.5, 0.35];
% testright
E.pos{5} = [0.65, 0.35];
% central binary question: question
E.pos{6} = [0.5 0.45];
% central binary question: propositions
E.pos{7} = [0.5 0.45];
% central binary propositions
E.pos{8} = [0.35 0.5];
E.pos{9} = [0.65 0.5];
% warning message
E.pos{10} = [0.3 0.8];
% position of the tested cue: used for sequential testing
E.pos{11} = [0.5 0.525];

%%% messages delivered to the subject
E.msg{1} = 'Next?';
% msg{2} =
% binary control estimation
E.msg{8} = 'actor';
E.msg{9} = 'spectator';
E.msg{10} = 'Please answer more rapidly..';
E.msg{11} = 'You should not see this message. \nTry to answer more rapidly next time..';


%% custom SPST objects
%E.microshift_predcues = {[0.008 -0.008], [0.006 -0.006], [0.007 0.007]};
E.microshift_predcues = {[-0.02 -0.036], [-0.02 -0.032], [-0.02 -0.034]};

% 1 = triangle
form{1}.exe = 'Screen(''FramePoly'', w.id, form{1}.color, eval(form{1}.pointList), form{1}.penWidth)';
form{1}.pos = [0.1 0.1];
form{1}.height = 0.08;
form{1}.color = [255 255 255];
form{1}.pointList = ['[scrconv(w, [form{1}.pos(1)-form{1}.height/2, form{1}.pos(2)+(form{1}.height*sqrt(3)/4)]);',...
    'scrconv(w, [form{1}.pos(1)+form{1}.height/2, form{1}.pos(2)+(form{1}.height*sqrt(3)/4)]);',...
    'scrconv(w, [form{1}.pos(1), form{1}.pos(2)-(form{1}.height*sqrt(3)/4)]);]'];
form{1}.highfactor = 1;%1.07;
form{1}.penWidth = 4;
form{1}.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', form{1}.pos(1), form{1}.pos(2), form{1}.color,)';
form{1}.exe_highlight2 = 'kheight = form{1}.height; form{1}.height = form{1}.height*form{1}.highfactor; Screen(''FramePoly'', w.id, form{1}.color, eval(form{1}.pointList), form{1}.penWidth*1.5);form{1}.height=kheight;';

% 2 = square
form{2}.exe = 'Screen(''FrameRect'', w.id, form{2}.color, eval(form{2}.rect), form{2}.penWidth)';
form{2}.pos = [0.098 0.098];
form{2}.height = 0.08;
form{2}.color = [255 255 255];
form{2}.rect = 'scrconv(w,[form{2}.pos(1)-form{2}.height/2,form{2}.pos(2)-form{2}.height/2, form{2}.pos(1)+form{2}.height/2,form{2}.pos(2)+form{2}.height/2])';
form{2}.penWidth = 4;
form{2}.highfactor = 1;%1.07;
form{2}.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', form{2}.pos(1), form{3}.pos(2), form{2}.color,)';
form{2}.exe_highlight2 = 'kheight = form{2}.height; form{2}.height = form{2}.height*form{2}.highfactor; Screen(''FrameRect'', w.id, form{2}.color, eval(form{2}.rect), form{2}.penWidth*1.5);form{2}.height=kheight;';

% 3 = square
form{3}.exe = 'Screen(''FrameOval'', w.id, form{3}.color, eval(form{3}.rect), form{3}.penWidth)';
form{3}.pos = [0.1 0.1];
form{3}.height = 0.08;
form{3}.color = [255 255 255];
form{3}.rect = 'scrconv(w,[form{3}.pos(1)-form{3}.height/2,form{3}.pos(2)-form{3}.height/2, form{3}.pos(1)+form{3}.height/2,form{3}.pos(2)+form{3}.height/2])';
form{3}.highfactor = 1;%1.18;
form{3}.penWidth = 4;
form{3}.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', form{3}.pos(1), form{3}.pos(2), form{3}.color,)';
form{3}.exe_highlight2 = 'kheight = form{3}.height; form{3}.height = form{3}.height*form{3}.highfactor; Screen(''FrameOval'', w.id, form{3}.color, eval(form{3}.rect), form{3}.penWidth*1.5);form{3}.height=kheight;';
spst.text.pos = E.pos{10};

%% Transition matrices


%%% statepairs / 2016
E.stact{1} = {[1 2], [1 3], [2 3]};
E.stact{2} = {[2 1], [3 1], [3 2]};

%%%%%%%%%%%%%%%%%% SS
% A1 = purple / A2 = blue / A3 = yellow
% S1 = purple+blue / A2 = purple+yellow / A3 = blue+yellow
%%%% cond 1: no control 2
% action 1 X     % A(12)  %B(13)       %C(23)
E.T{1}{1} = ['[noise/2 1-noise noise/2; ',... % A(12)
    'noise/2 noise/2 1-noise; ',...             % B(13)
    '1-noise noise/2 noise/2]'];                % C(23)
% action 2
E.T{1}{2} = ['[noise/2 1-noise noise/2; ',...
    'noise/2 noise/2 1-noise; ',...
    '1-noise noise/2 noise/2]'];
% action 3
E.T{1}{3} = ['[noise/2 1-noise noise/2; ',...
    'noise/2 noise/2 1-noise; ',...
    '1-noise noise/2 noise/2]'];
%%%% cond 2: no control 2
% action 1 X     % A(12)  %B(13)       %C(23)
E.T{2}{1} = ['[noise/2 noise/2 1-noise; ',... % A(12)
    '1-noise noise/2 noise/2; ',...  % B(13)
    'noise/2 1-noise noise/2]'];     % C(23)
% action 2 Y
E.T{2}{2} = ['[noise/2 noise/2 1-noise; ',... % A(12)
    '1-noise noise/2 noise/2; ',...  % B(13)
    'noise/2 1-noise noise/2]'];     % C(23)
% action 3 Z
E.T{2}{3} = ['[noise/2 noise/2 1-noise; ',... % A(12)
    '1-noise noise/2 noise/2; ',...  % B(13)
    'noise/2 1-noise noise/2]'];     % C(23)

%%%%%%%%%%%%%%%%%% AS
% A1 = purple / A2 = blue / A3 = yellow
% S1 = triangle(purple+blue) / A2 = square(purple+yellow) / A3 =
% circle(blue+yellow)

% cond 3: continuous flow of states
% action 1       % A(12)  %B(13)  %C(23)
E.T{3}{1} = ['[noise/2 noise/2 1-noise; ',... % A(12)
             'noise/2 noise/2 1-noise; ',...  % B(13)
             'noise/2 noise/2 1-noise]'];     % C(23) => should never happen.
% action 2
E.T{3}{2} = ['[noise/2 1-noise noise/2; ',...
             'noise/2 1-noise noise/2; ',...
             'noise/2 1-noise noise/2]'];
% action 3
E.T{3}{3} = ['[1-noise noise/2 noise/2;',...
             '1-noise noise/2 noise/2;',...
             '1-noise noise/2 noise/2]'];

% cond 4: repeat possible
% action 1       % A(12)  %B(13)  %C(23)
E.T{4}{1}= [  '[1-noise noise/2 noise/2;',...  % A(12)
    '1-noise noise/2 noise/2;',... % B(13)
    '1-noise noise/2 noise/2]'];    % C(23)
% action 2
E.T{4}{2} = ['[noise/2 noise/2 1-noise;',...
    'noise/2 noise/2 1-noise;',...
    'noise/2 noise/2 1-noise]'];
% action 3
E.T{4}{3} = ['[noise/2 1-noise noise/2; ',...
    'noise/2  1-noise noise/2; ',...
    'noise/2  1-noise noise/2]'];

% cond 4: repeat possible
% action 1       % A(12)  %B(13)  %C(23)
E.T{5}{1}= [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)
% action 2
E.T{5}{2} = [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)
% action 3
E.T{5}{3} = [  '[1/3 1/3 1/3;',...  % A(12)
    '1/3 1/3 1/3;',... % B(13)
    '1/3 1/3 1/3]'];    % C(23)

%% get instructions slides

instructions.path = 'SAS_stims\instructions_newbis\';
instrfiles = dir([instructions.path '*jpg']);
dumid = [];
for f = 1:length(instrfiles); dumid(f) = str2num(instrfiles(f).name(12:end-4)); end;
[~, dumid] = sort(dumid);
instrfiles = instrfiles(dumid);
for f = 1:length(instrfiles); fname{f,1} = instrfiles(f).name; end;
instructions.pics = cellstr(strcat(instructions.path, char(fname)));


%% START THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% open screen
if S.automated == 0;
    w = open_PSTscreen(0, [50 50 50], 2,1, 1);
    w.bg = [50 50 50];
end

Screen('TextSize', w.id, E.fontsize);

%% Part 3: LATENT
%%% Instructions for the block. FIXME

%%% counterbalancing
E.latent.testpairs = [];
for cc = 1:200 % dummy limit
    E.latent.testpairs = [E.latent.testpairs repmat(Shuffle([1 2 3]),1, 3)];
end
s(1) = randi(3);
rewpun = 1;
%latent.cond = 4;

% should I make noise dependent on performance on previous blocks?
E.latent.noise = 0.075;

% we are going to test 15 reversals <=> 16 periods of learning (five by
% rule). There will be random interludes between each series of 4
E.latent.maxdur = 60*48/16; % maximal duration per reversal unit <=> 3 min
E.latent.showscore = [];
ok = 0;
while ok == 0
    try
        dumcond = [combnk([1 2 3 4],2);combnk([4 3 2 1],2)];
        %dumcond = {[1 2], [2 4 2 1], [3 1 4 3], [4 3 1 4]};
        shuffleind = randperm(12);
        dumcond = dumcond(shuffleind,:);
        L.latent.cond = [];
        L.latent.cond(1) = dumcond(randi(4),1);
        for i = 1:12
            next = find(dumcond(:,1)==L.latent.cond(end), 1, 'first');
            L.latent.cond(end+1) = dumcond(next,2);
            dumcond(next,:) = [];
        end
        ok = 1;
    catch
        ok = 0;
    end
end
%L.latent.cond(1) = 3
% L.latent.cond = [];
% E.latent.showscore = [];
% % add random periods.
% for cr = 1:12
%     for ccr = 1:4
%         if ccr==1
%             L.latent.cond = [L.latent.cond 5 dumcond{cr}(ccr)];
%             E.latent.showscore = [E.latent.showscore 1 0 0];
%         else
%             L.latent.cond = [L.latent.cond dumcond{cr}(ccr)];
%             E.latent.showscore = [E.latent.showscore 0 ];
%         end;
%     end
% end


% test trials:
E.latent.testfreqs = [0 0 0 0 0 0 1];

% these frequencies denotes the probability of having
% learning criterion
E.latent.ntrials = 360; % maximal number of standard trials
E.latent.maxcrit = floor(E.latent.ntrials/4); %
E.latent.showscore_timing = 2.5;
instr_length = 15;
instr_i = 14;
while instr_i <= instr_length
    [onset resp] = instr_pic_arrow(w, instructions.pics{instr_i});
    instr_i = instr_i + resp;WaitSecs(0.1);
    if instr_i < 1; instr_i = 1; end; if instr_i > instr_length; KbWait; break; end;
end


try
    
    L.latent.global_starttime = GetSecs;
    L.latent.global_trialmarker = 1;
    L.latent.global_marker = 1;
    ttt = 0;
    
    for r = 1:length(L.latent.cond)
        %
        %         if E.latent.showscore(r)==1
        %             if r==1
        %                 spst.text.str = ['Your frequency of correct predictions: *NA* % \n\n Your current score is: *NA* points \n\n Estimated remaining time: <48 min \n\n Estimated total time <48 min \n\n\n\n Double-press a button when you''re ready to continue...'];
        %                 spst.text.pos = [0.5 0.5];
        %                 % normBoundsRect = Screen('TextBounds', w.id, text.str);
        %             else
        %                 accstr = num2str(mean(mean(L.latent.global_acc))*100,3);
        %                 L.score(r) = sum(sum(L.latent.global_acc)) + sum(double(L.latent.global_acc(:,1) == 1 & L.latent.global_acc(:,2) == 1))*2;
        %                 L.estimatedtotaltime = (((GetSecs-L.latent.global_starttime)/(r-1))*16);
        %                 totaltime_str = num2str(L.estimatedtotaltime/60,3);
        %                 remaintime_str = num2str((L.estimatedtotaltime-(GetSecs-L.latent.global_starttime))/60,3);
        %                 spst.text.pos = [0.5 0.5];
        %                 spst.text.color = [255 255 255];
        %                 spst.text.str = ['Your frequency of correct predictions: ' accstr ' % \n\nYour current score is: ' num2str(L.score(r),4) ' points \n\nEstimated remaining time: ' remaintime_str ' min\n\nEstimated total time: ' totaltime_str ' min \n\n\n\nDouble-press a button when you''re ready to continue...'];
        %             end
        %             eval(spst.text.exe_centered);
        %             Screen('Flip',w.id);
        %             KbWait;
        %             KbReleaseWait;
        %             KbWait;
        %         end
        
        %         coin = 1;
        %         if rand<0.5
        %             coin = -coin;
        %         end
        L.latent.learning_criterion(r) = 0; %
        L.latent.starttime(r) = GetSecs; %
        t = 0;
        tt = 0;
        clear acc;
        stdtrial.streaklength = 0;
        predtrial.streaklength = 0;
        
        while L.latent.learning_criterion(r) == 0 % && (GetSecs-L.latent.starttime(r))<E.latent.maxdur
            
            if (GetSecs-L.latent.global_starttime(end))/60 > E.latent.showscore_timing
                total_accstr = num2str(mean(mean(L.latent.global_acc))*100,3);                
                accstr = num2str(mean(mean(L.latent.global_acc(L.latent.global_trialmarker:end)))*100,3);
                L.score(L.latent.global_marker) = sum(sum(L.latent.global_acc(L.latent.global_trialmarker:end))) + sum(double(L.latent.global_acc(L.latent.global_trialmarker:end,1) == 1 & L.latent.global_acc(L.latent.global_trialmarker:end,2) == 1))*5;
                spst.text.pos = [0.5 0.5];
                spst.text.color = [255 255 255];
                spst.text.str = ['Correct predictions (global):' accstr  '%\n\nIn last ' num2str(E.latent.showscore_timing) ' min :' '\n Correct predictions:' accstr  ' %\n Points per minute: ' num2str(L.score(L.latent.global_marker)/E.latent.showscore_timing,4) '\n\n\n\nPress a button when you''re ready to continue...'];
                eval(spst.text.exe_centered);
                Screen('Flip',w.id);
                KbWait;
                KbReleaseWait;
                L.latent.global_marker = L.latent.global_marker+1;
                L.latent.global_trialmarker = ttt;
                L.latent.global_starttime(end+1) = GetSecs;
                
            end
            
            t = t+1;
            %%% trial infos # 1
            stdtrial.t = t;
            stdtrial.block_order = r;
            stdtrial.streaklength = stdtrial.streaklength+1;
            stdtrial.cond = L.latent.cond(r);
            stdtrial.side = randi(2);
            stdtrial.s = s(t);
            stdtrial.pair = E.stact{stdtrial.side}{stdtrial.s};
            stdtrial.noise = E.latent.noise;
            
            %%% make options for choice
            % left
            form{stdtrial.s}.pos = E.pos{1};
            form{stdtrial.s}.color = E.colors{stdtrial.pair(1)};
            eval(form{stdtrial.s}.exe);
            % right
            form{stdtrial.s}.pos= E.pos{2};
            form{stdtrial.s}.color = E.colors{stdtrial.pair(2)};
            eval(form{stdtrial.s}.exe);
            %%% show options
            Screen('Flip', w.id, [],1);
            %%% wait response
            stdtrial.resp_onset = GetSecs;
            exit = 0; noreflip = 1;alarmsound = 0;
            while exit == 0
                [keydown, secs, keyCode] = KbCheck();
                if keydown && find(keyCode, 1, 'first') == 37
                    stdtrial.resp_RT = secs-stdtrial.resp_onset;
                    stdtrial.resp_side = 1; exit = 1;
                elseif keydown && find(keyCode, 1, 'first')==39
                    stdtrial.resp_RT = secs-stdtrial.resp_onset;
                    stdtrial.resp_side = 2; exit = 1;
                end
                if GetSecs-stdtrial.resp_onset>E.timing.stdwarning && noreflip
                    spst.text.pos = E.pos{10}; % 8/9
                    spst.text.str = E.msg{10};
                    if noreflip
                        eval(spst.text.exe_warning);
                        Screen('Flip', w.id);
                    end
                    noreflip = 0;
                end
                if GetSecs-stdtrial.resp_onset>E.timing.stdwarning*2 && alarmsound == 0
                    PsychPortAudio('FillBuffer', soundriver, E.alarm);
                    t1 = PsychPortAudio('Start', soundriver, 1, 0, 1);
                    alarmsound = 1;
                end
            end;
            if alarmsound == 1;
                t1 = PsychPortAudio('Stop', soundriver, 1, 0, 1);
            end
            if noreflip;Screen('Flip',w.id);end;
            stdtrial.resp_choice = stdtrial.pair(stdtrial.resp_side);
            if stdtrial.resp_RT<E.timing.stdminimaldur
                WaitSecs(E.timing.stdminimaldur-stdtrial.resp_RT);
            else
                WaitSecs(E.timing.stdpostchoice);
            end
            stdtrial.fade_onset = GetSecs;
            %%% fade off
            while GetSecs-stdtrial.fade_onset< E.timing.fadedur
                advance = (GetSecs-stdtrial.fade_onset)/E.timing.fadedur;
                for o = 1:2
                    form{stdtrial.s}.pos = E.pos{o};
                    form{stdtrial.s}.color = E.colors{stdtrial.pair(o)}*(1-advance) + w.bg*advance;
                    eval(form{stdtrial.s}.exe);
                end;
                Screen('Flip', w.id);
            end
            for o = 1:2 % force zeros
                form{stdtrial.s}.color = [w.bg];
                eval(form{stdtrial.s}.exe);
            end
            Screen('Flip', w.id);
            for o = 1:2 % reset good colors after flip
                form{stdtrial.s}.color = E.colors{stdtrial.pair(o)};
            end
            WaitSecs(eval(E.timing.fixdur1));
            %%% compute transitions
            [stdtrial.snext stdtrial.smax] = make_transition(E.T, stdtrial.cond, stdtrial.noise, stdtrial.s, stdtrial.resp_choice);
            s(t+1) = stdtrial.snext;
            %%% save trial in log structure
            L.latent.block{r}.stdtrials{t} = stdtrial;
            
            if L.latent.cond(r) < 5 && rand < E.latent.testfreqs(stdtrial.streaklength);
                L.latent.block{r}.dotest(t) = 1;
            else
                L.latent.block{r}.dotest(t) = 0;
            end
            
            %%% prediction trial
            if L.latent.block{r}.dotest(t) && L.latent.cond(r) < 5 %ismember(stdtrial.streaklength,latent.testtrials);
                %coin = -coin;
                ttt = ttt+1;
                tt= tt+1;
                predtrial.t = t;
                eval(spst.fix.exe);
                Screen('Flip', w.id);
                WaitSecs(eval(E.timing.fixdur1));
                predtrial.t = t;
                predtrial.tt = tt;
                predtrial.noise = stdtrial.noise;
                predtrial.s = E.latent.testpairs(tt);
                predtrial.block_order = r;
                predtrial.side = randi(2);
                predtrial.pair = E.stact{predtriIn the l.side}{predtrial.s};
                %                 predtrial.respside = Shuffle([1 2]);
                %                 predtrial.tested_action_firstsecond = E.stact{predtrial.side}{predtrial.s}(predtrial.respside);
                predtrial.streaklength = predtrial.streaklength+1;
                predtrial.cond = L.latent.cond(r);
                predtrial.ordering = randi(3);
                predtrial.last_s = stdtrial.s;
                predtrial.last_pair = E.stact{stdtrial.side}{predtrial.s};
                predtrial.randomorder = Shuffle([1 2 3]); % random order 1 = left option, 2 = middle option
                
                %%% build options with question marks on it and wait for
                %%% answer.
                
                for test = 1:2
                    % build lower part;
                    % Screen('FillRect', w.id, [0 0 0], w.rectpix);
                    form{predtrial.s}.pos = E.pos{11};
                    form{predtrial.s}.color = E.colors{predtrial.pair(test)};
                    eval(form{predtrial.s}.exe);
                    
                    % build higher rank
                    for f = 1:3
                        %pside = randi(2);
                        %kkheight = form{predtrial.randomorder(f)}.height;
                        form{predtrial.randomorder(f)}.pos = E.pos{2+f};
                        form{predtrial.randomorder(f)}.color = E.lightgreycol;
                        eval(form{predtrial.randomorder(f)}.exe);
                        %for i = 1:2
                        %                             E.stact{1} = {[1 2], [1 3], [2 3]};
                        %                             form{predtrial.randomorder(f)}.pos = E.pos{2+f};
                        %                             form{predtrial.randomorder(f)}.height = form{predtrial.randomorder(f)}.height+E.microshift_predcues{predtrial.randomorder(f)}(i);
                        %                             form{predtrial.randomorder(f)}.color = E.colors{E.stact{pside}{predtrial.randomorder(f)}(i)};
                        %                             eval(form{predtrial.randomorder(f)}.exe);
                        %                         end
                        %                         form{predtrial.randomorder(f)}.color = E.lightgreycol;
                        %                         form{predtrial.randomorder(f)}.height = kkheight;
                    end
                    % flip and hold on
                    Screen('Flip', w.id, [],1);
                    %%% wait control answer
                    exit = 0;
                    dumresp = [];
                    predtrial.resp_onset = GetSecs;
                    while exit == 0
                        [keydown, secs, keyCode] = KbCheck();
                        if keydown
                            dumresp = find(ismember(E.predbuttoncodes, find(keyCode,1,'first')));
                            KbReleaseWait;
                        end
                        if ~isempty(dumresp)
                            predtrial.resp_RT(test) = secs-predtrial.resp_onset;
                            predtrial.resp_choice(test) = predtrial.randomorder(dumresp);
                            predtrial.resp_side(test) = dumresp;exit = 1;
                        end
                        %KbReleaseWait();
                    end;
                    %%% highlight answered response & flip
                    %  + compute transition matrices to determine prediction accuracies
                    
                    [~, smax(test)] = make_transition(E.T, predtrial.cond, predtrial.noise, predtrial.s, predtrial.pair(test));
                    if smax(test) == predtrial.resp_choice(test)
                        predtrial.ACC(test) = 1;
                    else
                        predtrial.ACC(test) = 0;
                    end;
                    eval(form{predtrial.resp_choice(test)}.exe_highlight2);
                    Screen('Flip', w.id, [],1);
                    %                    WaitSecs(E.timing.postpredresp);
                    %                     if coin == 1
                                            if predtrial.ACC(test) == 1
                                                form{predtrial.resp_choice(test)}.color = [0 200 0];
                                            else
                                                form{predtrial.resp_choice(test)}.color = [200 0 0];
                                            end
                                            eval(form{predtrial.resp_choice(test)}.exe_highlight2);
                                            Screen('Flip', w.id);
                    %                     end
                    %                     predtrial.coin = coin;
                    WaitSecs(E.timing.postpredresp2);
                    form{predtrial.resp_choice(test)}.color = E.lightgreycol; % reset color
                    if predtrial.resp_RT(test)>E.timing.predwarning
                        spst.text.pos = [0.2 0.5]; % 8/9
                        spst.text.str = E.msg{11};
                        eval(FULL.SASSS.muX{s}.text.exe_warning);
                        Screen('Flip', w.id);
                        WaitSecs(2)
                    end
                    if test == 1
                        Screen('Flip',w.id);
                        WaitSecs(0.3);
                    end
                end;
                
                %%% log accuracies properly
                L.latent.global_acc(ttt,:) = predtrial.ACC;
                L.latent.streak_acc{r}(tt,:) = predtrial.ACC;
                last
                if predtrial.cond < 3 && predtrial.resp_choice(1)==predtrial.resp_choice(2)
                    predtrial.controlACC = 1;
                elseif predtrial.cond > 2 && predtrial.resp_choice(1)~=predtrial.resp_choice(2)
                    predtrial.controlACC = 1;
                else
                    predtrial.controlACC = 0;
                end;
                
                L.latent.block{r}.predtrials{tt} = predtrial;
                stdtrial.streaklength = 0;
                
                % exit condition
                if predtrial.streaklength>=4
                    if mean(mean(L.latent.global_acc(ttt-2:end,:)))>=0.833 || mean(mean(L.latent.global_acc(ttt-1:end,:)))==1
                        L.latent.learning_criterion(r) = predtrial.streaklength;
                    elseif t>=70
                        L.latent.learning_criterion(r) = -1;
                    end
                end
                
            end
            
            %             if predtrial.streaklength==4;
            %                 if sum(sum((L.latent.streak_acc{r}(tt-3:tt,:)))) >= 7
            %                     L.latent.learning_criterion(r) = 1;
            %                 end
            %             elseif predtrial.streaklength==5;
            %                 %break; %%% FIXME !
            %                 if sum(sum((L.latent.streak_acc{r}(tt-4:tt,:)))) >= 8
            %                     L.latent.learning_criterion(r) = 2; % signals
            %                 end
            %             elseif predtrial.streaklength==6;
            %                 %break; %%% FIXME !
            %                 if sum(sum((L.latent.streak_acc{r}(tt-5:tt,:)))) >= 9
            %                     L.latent.learning_criterion(r) = 3; % signals
            %                 end
            %             elseif predtrial.streaklength>=7;
            %                 %break; %%% FIXME !
            %                 if sum(sum((L.latent.streak_acc{r}(tt-6:tt,:)))) >= 10
            %                     L.latent.learning_criterion(r) = 4; % signals
            %                 end
            %             elseif predtrial.streaklength==10;
            %                 L.latent.learning_criterion(r) = -1; % signals poor learning
            %             end
            
%             if L.latent.cond(r)==5 && t>=20;
%                 L.latent.learning_criterion(r) = 5; % signals end of random period
%             end
            
            %             if t>10
            %                 break
            %             end
            
        end % trials end
        
        
        
    end
    
catch err
    
    mkdir(['logfiles/' S.fullid]);
    save(['logfiles/' S.fullid '/' 'Latent_' S.fullid '_' num2str(S.number) '_' S.date '_' S.time ], 'L', 'E', 'S');
    Screen('CloseAll');
    rethrow(err);
    
end;
%very_endtime = toc;
%L.total_experiment_duration = (very_endtime - very_starttime)/60;

mkdir(['logfiles/' S.fullid]);
save(['logfiles/' S.fullid '/' 'Latent_' S.fullid '_' num2str(S.number) '_' S.date '_' S.time ], 'L', 'E', 'S');

try
    save([E.externalfolder 'Latent_' S.fullid '_' num2str(S.number) '_' S.date '_' S.time ], 'L', 'E', 'S');
end

%%% Instructions for the block. FIXME
instr_pic_arrow(w, instructions.pics{end});
exit = 0;
while exit==0
    [~, keyCode] = KbWait;
    if strcmpi(KbName(keyCode),'q');
        Screen('CloseAll');
        exit = 1;
    end;
end;
KbReleaseWait;
PsychPortAudio('Close', soundriver);