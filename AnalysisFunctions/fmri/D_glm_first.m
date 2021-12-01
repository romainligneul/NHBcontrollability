%% script used to run first-level whole-brain GLM, subject per subject
clear all;close all;

% name of the GLM specification script to use (no D_ prefix)
analysis_name = 'SPM12_R6RETROICOR_2ROI_HP96_prior1_Diffunc';
 
%%%%%%%                  STEPS TO BE EXECUTED                       %%%%%%%
%
design_firstlev_step = 1;
%
estimate_firstlev_step = 1;

%%%%%%%                     EXECUTION CODE                          %%%%%%%
base_directory = pwd; % where the GLM specification scripts are located

% 
run([base_directory '/D_' analysis_name '.m']);

% add relevant paths
addpath(genpath(F.homefunc));
addpath(genpath(F.spmpath));
spm_defaults;
addpath(genpath('/home/common/matlab/fieldtrip/qsub'))

%%%%%%%                    FIRST LEVEL GLM                               %%
% uniterated first level    
for sub = 1:length(F.subjnames)

    execute_first_level( F,I,sub)
    % parallel job_id{sub} = qsubfeval('execute_first_level', F,I, sub, 'memreq',  24*(1024^3), 'timreq', 119*60, 'display', 'no');%, 'matlabcmd', 'matlab -nodisplay -nodesktop -nosplash');

end
