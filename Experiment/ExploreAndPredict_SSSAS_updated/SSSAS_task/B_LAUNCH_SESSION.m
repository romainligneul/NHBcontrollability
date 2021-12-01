%% Clear all
% This is a small script to manage the experiment
% To force quit, you have to do a Ctrl+Alt+Delsca


load('active_subject.mat');

promptMessage = ['Subject: ' num2str(S.number), '\nSession: ', num2str(S.session), '\nAge: ' , num2str(S.input{1}), '\nSex: ', num2str(S.input{2}), '\n\n OK ?'];
button = questdlg(sprintf(promptMessage), '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')  
else
    error('The, check what''s wrong! :=)')
end


%%
promptMessage = sprintf('Do training?');
button = questdlg(promptMessage, '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')
    run('TRAINING_SSSAS.m')
end

%%
promptMessage = sprintf('Do run 1 on 4?');
button = questdlg(promptMessage, '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')
    run('RUN1_SSSAS.m')
end

%%
promptMessage = sprintf('Do run 2 on 4?');
button = questdlg(promptMessage, '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')
    run('RUN2_SSSAS.m')
end

%%
promptMessage = sprintf('Do run 3 on 4?');
button = questdlg(promptMessage, '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')
    run('RUN3_SSSAS.m')
end

%%
promptMessage = sprintf('Do run 4 on 4?');
button = questdlg(promptMessage, '', 'Yes', 'No', 'Yes');
if strcmp(lower(button), 'yes')
    run('RUN4_SSSAS.m')
end

%%
disp('THANK YOU!!! END OF THIS EXPERIMENT!')

