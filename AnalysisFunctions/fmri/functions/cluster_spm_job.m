% List of open inputs
function [status] = splitlaunch_job(jobfile, jobid)

    % launch job
    load(jobfile);
    jobs = cluster_job{jobid}; %matlabbatch(jobid);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs);
    
end
