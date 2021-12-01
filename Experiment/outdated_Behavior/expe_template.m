%%%%% short RL task
exp_id = 'RL';

run('objects_generator');

try
if S.automated == 0;
    
    load('active_subject');
    w = open_PSTscreen(0, [180 180 180], 2,1, 1);
    spst.sounds = init_PSTsounds({'corrSound.wav', 'incorSound.wav'}, [], []);
    
end

%% instructions
ilist = ls('RL_stims/RL_instructions_en/*.png');

for i = 1:size(ilist,1)
    
    
end

% end of instructions
%% build and loop for training


% end of training
%% build main


% end of build main
%% main loop


% end of main loop
catch err
    
    rethrow(err);
    
end;

%% finalize
Screen('CloseAll');
save(['logfiles' exp_id '_' S.fullid '.mat'], 'S', 'L', 'E');

% end of everything
