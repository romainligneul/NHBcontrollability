%%%%%%%%%%%%% Initalize experiment / New subject %%%%%%%%%%%%%%
clear all;
% add toolbox to path
addpath(genpath('../SmartPST'));

% init PST
KbName('UnifyKeyNames');

% subject number, to be defined by the experimenter before the experiment.
S.number = 31;

% automatization of the multi-task experiment
S.automated = 0;

% run
dialogtext = {...
    'Last name',...
    'First name',...
    'Age',...
    'Sex (m/f)',...
    'Sona Id',...
    'Email'};
    
S.input = inputdlg(dialogtext, 'General information');

% other infos
S.date = date;
dumtime = clock;
S.time = [num2str(dumtime(4)) 'h' num2str(dumtime(5))];
S.fullid = [num2str(S.number) '_' upper(S.input{1}(1:3)) upper(S.input{2}(1:2)) '_' S.date '_' S.time]
% save subject structure as the 'active subject'

% assignation of conditions to different blocks
% 1243 = UUCC;
% 2314 = UCUC;
% 3421 = UCUC;
% 4132 = CUCU;
if mod(S.number,4)==1 % e.g 1
    S.first5 = {[1 2 4 3], [2 3 1 4], [3 4 2 1], [4 1 3 2]};
    S.tasktype = [1 1 1 1];% {[1 1 1 1], [1 1 1 1], [1 1 2 2], [2 2 1 1]};
    S.trainingtype = [1 2 3 4 1 2 3 4; 1 1 1 1 1 1 1 1];
elseif mod(S.number,4)==2 % e.g 1
    S.first5 = {[2 3 1 4], [3 4 2 1], [4 1 3 2], [1 2 4 3]};
    S.tasktype = [1 1 1 1];
    S.trainingtype = [2 3 4 1 2 3 4 1; 1 1 1 1 1 1 1 1];
elseif mod(S.number, 4)==3 % eg 2
    S.first5 = {[3 4 2 1], [4 1 3 2], [1 2 4 3], [2 3 1 4]};    
    S.tasktype = [1 1 1 1];
    S.trainingtype = [3 4 1 2 3 4 1 2; 1 1 1 1 1 1 1 1];
else %if mod(S.number, 4) == 0 % e.g. 4
    S.first5 = {[4 1 3 2], [1 2 4 3], [2 3 1 4], [3 4 2 1]}; 
    S.tasktype = [1 1 1 1];
    S.trainingtype = [4 1 2 3 4 1 2 3; 1 1 1 1 1 1 1 1];
end

save('active_subject', 'S');
save(['subjects/' S.fullid], 'S');
try
    save(['M:\fMRI_logfiles\subjects\' S.fullid],'S');
    mkdir(['M:\fMRI_logfiles\' S.fullid])
end


    