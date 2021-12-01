%%%%%%%%%%%%% Initalize experiment / New subject %%%%%%%%%%%%%%
clear all;
% add toolbox to path
addpath(genpath('../SmartPST'));

% init PST
KbName('UnifyKeyNames');

% subject number, to be defined by the experimenter before the experiment.
S.number =99;

% session indice if repeated measures
S.session = 1;

 % instruction can be in 'english' or 'german'
S.language = 'english';

% screen
S.screen = 1; % 0 = all available screens % otherwise, 1 for primary or 2 for secondary

% automatization of the multi-task experiment
S.automated = 0;

% make logdir
S.subj_logdir = ['Logfiles\'];
mkdir(S.subj_logdir);

% keep variable value to avoid overwriting when loading S struct from
% initial session :)
keep_session = S.session;
keep_logdir = S.subj_logdir;

% do stuff (include counterbalancing)
if S.session == 1
    
    % run
    dialogtext = {
        'Age',...
        'Sex (m/f)'};
    
    % comment
    S.input = inputdlg(dialogtext, 'General information');
    
    % other infos
    S.date = date;
    dumtime = clock;
    S.time = [num2str(dumtime(4)) 'h' num2str(dumtime(5))];
    S.fullid =  [sprintf('subj%0.3i' ,S.number) '_sess' num2str(S.session)]; %[num2str(S.number) '_' upper(S.input{1}(1:3)) upper(S.input{2}(1:2)) '_' S.date '_' S.time]

    
    % assignation of conditions to different blocks
    % 1243 = UUCC;
    % 2314 = UCUC;
    % 3421 = CCUU;
    % 4132 = CUCU;
    if mod(S.number,4)==1
        S.first5 = {[1 2 4 3], [2 3 1 4], [3 4 2 1], [4 1 3 2]};
        S.tasktype = [1 1 1 1];% {[1 1 1 1], [1 1 1 1], [1 1 2 2], [2 2 1 1]};
        S.trainingtype = [1 2 3 4 1 2 3 4;1 1 1 1 1 1 1 1];
    elseif mod(S.number,4)==2
        S.first5 = {[2 3 1 4], [3 4 2 1], [4 1 3 2], [1 2 4 3]};
        S.tasktype = [1 1 1 1];
        S.trainingtype = [2 3 4 1 2 3 4 1; 1 1 1 1 1 1 1 1];
    elseif mod(S.number,4)==3
        S.first5 = {[3 4 2 1], [4 1 3 2], [1 2 4 3], [2 3 1 4]};
        S.tasktype = [1 1 1 1];
        S.trainingtype = [3 4 1 2 3 4 1 2;1 1 1 1 1 1 1 1];
    else %if mod(S.number, 4) == 0 % e.g. 4
        S.first5 = {[4 1 3 2], [1 2 4 3], [2 3 1 4], [3 4 2 1]};
        S.tasktype = [1 1 1 1];
        S.trainingtype = [4 1 2 3 4 1 2 3;1 1 1 1 1 1 1 1];
    end    
    save(['subjects/' sprintf('subj%0.3i' ,S.number) '.mat'], 'S');
end

try
    load(['subjects/' sprintf('subj%0.3i' ,S.number) '.mat'], 'S');
catch err
    error('no subject .mat file in subjects/');
end

S.session = keep_session;
S.subj_logdir = keep_logdir;

% save active subject (the one used by B_LAUNCH_SESSION)
save('active_subject', 'S');

% save subject structure if possible
try
    save(S.subj_logdir, 'S');
end


