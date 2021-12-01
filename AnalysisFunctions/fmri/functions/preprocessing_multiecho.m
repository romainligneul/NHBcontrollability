%-----------------------------------------------------------------------
% Performs the preprocessing for the study Working Memory / RL
% Irene
% Romain Ligneul
% August 2016
% This is the second script to run after pre-preprocessing
%-----------------------------------------------------------------------
clear all;
% add to path
addpath('/home/common/matlab/fieldtrip/qsub'); % addpath to the Qsub module

info_xls = '/project/3017054.01/Level_0/subjects_info.xlsx';
[xnum xtxt] = xlsread(info_xls);
nsubj = size(xnum,2)-2;
redo_all  = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if redo_all==1
    redo_check = [];
    warning('Erase and redo option selected. Are you sure?')
    [redo_check] = input('Y/N [default: N]: ', 's');
    if strcmp(lower(redo_check),'y')
    else
        error('Set redo all option to 0')
        break
    end
end   

%% preprocessing settings
for s = 1:nsubj
    
    P = [];
    
    P.s = s;
    % skip unincluded subject
    if xnum(1,s+2)~=1
        continue;
    end
    
    % get useful info
    P.subjname = xtxt{1,s+1};
    P.xnum = xnum;
    
    % recombination information
    P.recombine.n_echoes = 5;
    P.recombine.n_weighting = 30;
    P.recombine.echo_times = [7 16.25 22.5 34.75 44];
    
    % run infos
    P.recombine.id = P.xnum(6,s+2);
    P.resting.id = P.xnum(7,s+2);
    P.run_id = xnum(10:13,s+2);   

    % general infos
    P.dir_output = '/project/3017054.01/Pipelines/preprocessing/torque_output/';
    P.dicom_subdir = ['/project/3017054.01/Level_0/fMRI_DICOM/' P.subjname];
    P.nii_subdir = ['/project/3017054.01/Level_0/fMRI_nii/' P.subjname];
    P.dir_saveP = ['/project/3017054.01/Subjects_Structures/Preproc/' P.subjname '/'];
    P.function_path = '/project/3017054.01/Pipelines/functions';
    P.spm_path = '/home/common/matlab/spm12_r6470_20150506/';
    addpath(genpath(P.function_path));
    % directory management
    if exist(P.nii_subdir,'dir')~=0 && redo_all == 0;
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(['Subject ' P.nii_subdir ' is already preprocessed. Skipping...']);       
        continue
    elseif exist(P.nii_subdir,'dir')==0 && redo_all == 0;
        mkdir(P.nii_subdir);mkdir(P.dir_saveP);
    else
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(['Delete folder: ' P.nii_subdir]);
        try
            rmdir(P.nii_subdir, 's');rmdir(P.dir_saveP, 's');
        catch
            disp(['Folder: ' P.nii_subdir ' already deleted'])
        end
        mkdir(P.nii_subdir);mkdir(P.dir_saveP);      
    end
    
    % prefix of output images
    P.str_resliced = 'r';
    P.str_recombined = 'c';
    P.str_slicetimed = 'a';
    P.str_normalized = 'w';
    P.str_smoothed = 's';

    % submit job to server
    cd(P.dir_output);
    %splitlaunch_preprocess_job(P);
    qsubfeval('splitlaunch_preprocess_job', P, 'memreq',  6*(1024^3), 'timreq', 180*60);
    
end
%

