clear all;

%%%% short RL task
run('objects_generator');

load('active_subject');

exp_id = 'RL';

stim_folder = 'RL_stims/';
instr_folder = 'RL_stims/RL_instructions_en/';
external_folder = 'M:\Experiments_Logfiles\SAS_protocol\RL_logs\';

% open PST if necessary
if S.automated == 0;
    
    w = open_PSTscreen(0, [180 180 180], 2,1, 1);
    %spst.sounds = init_PSTsounds({'corrSound.wav', 'incorSound.wav'}, [], []);
    
end

%% instructions
ilist = ls([instr_folder '*.jpg']);
i = 1;
while i <= size(ilist,1)
    [~, iresp] = instr_pic_arrow(w,[instr_folder ilist(i,:)])
    i = i+iresp;
    if i < 1
        i = 1;
    end
    if i > size(ilist,1)
        KbWait;
    end
    KbReleaseWait;
end
% end of instructions

%% build and loop for training
% No training for the RL experiment.
% end of training
%% build main
% description
% three different conditions: positive / negative / reversal
% 60 trials per condition. / 25% noise. Reversal after 30.
% 3s / trial on average.
% the first of each pairs will always be the rewarding one.
E.pairs = {{'E', 'F'}, {'C','D'}, {'G', 'H'}};
E.pairs = E.pairs(randperm(3));
for p = 1:length(E.pairs)
    E.pairs{p} = E.pairs{p}(randperm(2));
end
% E.WM_letters_span = 'BCDFGHJKLMNPQRSTVWXZ';
% E.WM_nletters = repmat([1 5],9);
% E.WM_displays = 1:10:180;
% E.WM_tests = 10:10:180;

% pairs(1) = positive
% pairs(2) = negative
% pairs(3) = positive_reversal
E.condvec = [];
E.maintrans = [];
dumvec =repmat([1 2 3], 1, 12);
% here, we control for the amount of noise:
dumtrans =[ones(1,27) zeros(1,9)];
E.side = [ones(1,72) zeros(1,72)];E.side = Shuffle(E.side);
for r = 1:4
    shufind = randperm(36);
    E.condvec = [E.condvec dumvec(shufind)];
    E.maintrans = [E.maintrans dumtrans(shufind)];
end
% configure stimuli
spst.image.height = 0.3;
spst.image.width = 0.3;
spst.image.pos = [0.5 0.5];
% define timings
E.uniform_iti_distribution = [0.5 1.5];
E.postchoice_duration = [0.3];
E.uniform_preoutcome_duration = [0.45];
E.fixed_outcome_duration = 1.5;
E.delay_hurryup = 2.5;

% end of build main
%% main loop
E.start_time = GetSecs;
L.condcount(1,1:3)=0;
Screen('TextSize', w.id, 40);

for t = 1:length(E.condvec);
    
    eval(spst.fix.exe);
    Screen('Flip', w.id);
    WaitSecs(E.uniform_iti_distribution(1)+rand*E.uniform_iti_distribution(2));
    
    if stim(t) == 0
        stimpair = [E.pairs{E.condvec(t)}{1} E.pairs{E.condvec(t)}{2} '.png'];
    else
        stimpair = [E.pairs{E.condvec(t)}{2} E.pairs{E.condvec(t)}{1} '.png'];
    end;
    
    L.cond(t,1) = E.condvec(t);
    L.reversed(t,1) = double(L.cond(t,1)==3 && L.condcount(E.condvec(t))>24);
    
    %%% display choice
    spst.image.fullpath = [stim_folder stimpair];
    spst.image.height = 0.3;
    spst.image.width = 0.3;
    eval(spst.image.exe);
    Screen('Flip',w.id, [], 1);
    L.onset_choice(t,1) = E.start_time - GetSecs;
  
    % wait for available response
    keypressed = 0; L.decision_onset(t,1) = GetSecs;
    
    while ~ismember(keypressed, [37 39])
         [~, keyCode] = KbWait([],2);
         L.RT(t,1) = GetSecs-L.decision_onset(t,1);
         keypressed = find(keyCode, 1, 'first');
         KbReleaseWait;
    end;
    L.onset_response(t,1) = E.start_time - GetSecs;
    L.keypressed(t,1) = find(keypressed==[37 39], 1, 'first');
    if L.keypressed(t,1)==1
        spst.image.fullpath = [stim_folder 'left_chosen.png'];
    elseif L.keypressed(t,1)==2
        spst.image.fullpath = [stim_folder 'right_chosen.png'];
    end
    eval(spst.image.exe);
    Screen('Flip',w.id);
    WaitSecs(E.postchoice_duration);
        
    
    %%% determine accuracy
    if (E.side(t)==0 && L.keypressed(t,1)==1) || (E.side(t)==1 && L.keypressed(t,1)==2)
        L.acc(t,1) = 1;
        if L.reversed(t,1)==1
            L.acc(t,1)=0;
        end
    else
        L.acc(t,1) = 0;
        if L.reversed(t,1)==1
            L.acc(t,1)=1;
        end        
    end

    %%% determine outcome
    if (L.acc(t,1) == 1 && E.maintrans(t)==1) || (L.acc(t,1) == 0 && E.maintrans(t)==0) 
        if L.cond(t,1) == 1
            L.reward(t,1) = 1;
        elseif L.cond(t,1) == 2
            L.reward(t,1) = 0;
        else
            L.reward(t,1) = 1;
        end
    else
        if L.cond(t,1) == 1
            L.reward(t,1) = 0;
        elseif L.cond(t,1) == 2
            L.reward(t,1) = -1;
        else
            L.reward(t,1) = 0;
        end    
    end
    
    %%% preoutcome fixation
    eval(spst.fix.exe);
    Screen('Flip', w.id);
    WaitSecs(E.uniform_preoutcome_duration);
    
    %%% display outcome
    spst.image.height = 0.1;
    spst.image.width = 0.1;
    spst.image.fullpath = [stim_folder 'smiley' num2str(L.reward(t,1)) '.png'];    
    eval(spst.image.exe);
%     if L.reward(t,1)==1
%         PsychPortAudio('FillBuffer', spst.sounds.port_h(1), spst.sounds.wav{1});
%         PsychPortAudio('Start', spst.sounds.port_h(1), 1, 0, 1);
%     elseif L.reward(t,1)==-1
%         PsychPortAudio('FillBuffer', spst.sounds.port_h(1), spst.sounds.wav{2});
%         PsychPortAudio('Start', spst.sounds.port_h(1), 1, 0, 1);
%     end
    Screen('Flip',w.id);
    L.onset_outcome(t,1) = E.start_time - GetSecs;
    WaitSecs(E.fixed_outcome_duration);
%     if L.reward(t,1)~=0
%         PsychPortAudio('Stop', spst.sounds.port_h(1));
%     end
        
    % update stim count
    L.condcount(E.condvec(t)) = L.condcount(E.condvec(t))+1;
    
    
    % update
% % end of main loop
% catch err
%     
%     rethrow(err);
%     
end;

%% finalize
Screen('CloseAll');
save(['logfiles\RL\' exp_id '_' S.fullid '.mat'], 'S', 'L', 'E');
try
save([external_folder exp_id '_' S.fullid '.mat'], 'S', 'L', 'E');
end
% end of everything
