function execute_first_level(F, I, sub)
%execute first level subject by subject
spm('defaults', 'FMRI');
global defaults;
defaults.cmdLine = true;
defaults.stats.resmem = true;
defaults.stats.maxmem = 12*(1024^3);

% load P structure

glm_target_subfolder = strcat(F.firstlevpath, F.subjnames{sub}, '/');
glm_functional_filter = ['^' F.prprcpref '.*' F.prprcsuf '$'];
glm_motion_filter = ['^' F.mvtpref '.*' '.txt' '$'];

% if exist(glm_target_subfolder, 'dir') == 0
%     mkdir(glm_target_subfolder);
% end
% if exist([F.mpath F.dir_savePFC F.subjnames{sub}], 'dir')==0
%     mkdir([F.mpath F.dir_savePFC F.subjnames{sub}], 'dir');
% end

matlabbatch{1}.spm.stats.fmri_spec.dir = {glm_target_subfolder};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = F.units;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = F.RT;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = F.fmri_t; % if we want to take advantage of the slice timing step, used the number of slices.
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = F.fmri_t0; % it has to be the slice index of the reference slide. In our case, ref is 26 and it is scanned in 13th position
 
for rr = 1:length(F.runid)
    r = F.runid(rr);
    I.images4glm{sub}{r} = cellstr(regexprep(cellstr(I.epi_files_sprintf{sub}{r}),'%s', F.prprcpref));
    % nuisance regressors
    if strcmp(F.mvtpref, 'rp_') & strcmp(F.mvtsuff, '.txt') || isempty(I.motionreg.files{sub, r}{F.mvtind})
        dumind = strfind(I.images4glm{sub}{r}{1},'/');
        motion_file = spm_select('FPList',[I.images4glm{sub}{r}{1}(1:dumind(end-1)) I.sessions{sub}{r}], ['^' F.mvtpref '.*']);
        disp(['Using 6-params txt movement parameters in ' F.subjnames{sub}]);
    else
        motion_file = [ F.mpath F.nuisancepath I.motionreg.files{sub, r}{F.mvtind}];
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).scans = I.images4glm{sub}{r};
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi = F.run_mat{sub}(r);
    load(matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi{1}, 'regressors')
    if exist('regressors','var')
        regnames = fieldnames(regressors);
        for regr=1:length(regnames);
            matlabbatch{1}.spm.stats.fmri_spec.sess(rr).regress(regr).val = eval(['regressors.' regnames{regr}]);
            matlabbatch{1}.spm.stats.fmri_spec.sess(rr).regress(regr).name = [regnames{regr} '*bf(1)'];
        end
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(rr).regress = struct('name', {}, 'val', {});
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi_reg = cellstr(motion_file);
    if ~isempty(F.hpf)
      matlabbatch{1}.spm.stats.fmri_spec.sess(rr).hpf = F.hpf;
    end
end;

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

try
    if ~F.FIR.do
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = F.hrf_derivs;
    else
        matlabbatch{1}.spm.stats.fmri_spec.bases.gamma.length = F.FIR.window;
        matlabbatch{1}.spm.stats.fmri_spec.bases.gamma.order = F.FIR.nbins;
    end
catch % for old model where FIR.do doesn't exist
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = F.hrf_derivs;
end

matlabbatch{1}.spm.stats.fmri_spec.mask = {F.mask};%F.mask;
matlabbatch{1}.spm.stats.fmri_spec.volt = 1; % hard coded
matlabbatch{1}.spm.stats.fmri_spec.global = 'None'; % hard coded;
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)'; % hard coded
matlabbatch{1}.spm.stats.fmri_spec.mthresh = F.implicit_threshold; % hard coded

matlabbatch{2}.spm.stats.fmri_est.spmmat = {[glm_target_subfolder 'SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

jobfile = [glm_target_subfolder ''  F.name '_' datestr(now,'yyyymmddTHHMMSS') '.mat']
save(jobfile, 'matlabbatch');

% execute batch
spm_jobman('initcfg')
spm_jobman('serial', matlabbatch);


end
