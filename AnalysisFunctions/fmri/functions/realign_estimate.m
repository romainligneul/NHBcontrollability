% List of open inputs
% Realign: Estimate: Data - cfg_repeat
nrun = X; % enter the number of runs here
jobfile = {'/project/3017054.01/Pipelines/functions/realign_estimate_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Realign: Estimate: Data - cfg_repeat
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
