%%%%%%%%%%%%% Initalize experiment / New subject %%%%%%%%%%%%%%
clear all;
% add toolbox to path
addpath(genpath('../SmartPST'));

% init PST
KbName('UnifyKeyNames');

% subject number, to be defined by the experimenter before the experiment.
S.number = 33;


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

% save subject structure as the 'active subject'
save('active_subject', 'S');
save(['subjects/' S.fullid], 'S');

try
    save(['M:\Experiments_Logfiles\SAS_protocol\subjects\' S.fullid],'S')
end


run('expe_1_SSSAS_training1.m');





























% % set email pref
% setpref('Internet','E_mail','romainvictor@gmail.com');
% setpref('Internet','SMTP_Server','smtp.gmail.com');
% setpref('Internet','SMTP_Username','romainvictor@gmail.com');
% pss = ['bloe' 'odbry' 'ainbu' 'arrierp']; pss([4 9 14 end]) = [];
% setpref('Internet','SMTP_Password',pss);
% clear pss;
% props = java.lang.System.getProperties;
% props.setProperty('mail.smtp.auth','true');
% props.setPropqerty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
% props.setProperty('mail.smtp.socketFactory.port','465');
% 
% try
% sendmail('r.ligneul@donders.ru.nl',['AutoExpMail_' upper(S.input{1}(1:3)) upper(S.input{2}(1:2)) '_' S.date],['Experiment started at: ' S.time])
% end