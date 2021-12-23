%% script used to compute second level group contrasts

clear all;
% rmpath('/home/common/matlab/spm12')

%% set domain name
S.Fname = 'SPM12_R6RETROICOR_2ROI_HP96_prior1'

%% set analysis name
S.Sname = 'all';

%% retrieve first level info
S.Fdir = '/project/3017049.01/SASSS_fMRI1/LEVEL1/';

% import first level structures
load([S.Fdir S.Fname '/infos_FIPRT.mat']);
load([S.Fdir S.Fname '/C.mat']);
load('personality_fmri.mat');
% S.F = F;clear F;

S.S_maindir = [F.secondlevpath S.Sname '/'];

try
rmdir(S.S_maindir)
end
list = C.regressor_list;%     s_ind(s) = strmatch(S.F.subjnames{s},covsubjects);
% end

load('SUBINF.mat');
load('BEHAVIOR/behavior_32s.mat')

% get Omega bias
load('/project/3017049.01/SASSS_fMRI1/BEHAVIOR/modeling_seq_final/o_MBtype2_wOM2_bDEC1_max_nobound_e_aSASSSSAS1_aOMIntInf1_nobound_13-Oct-2019_1/fitted_model.mat','muX', 'phiFitted')
omega_ind = 49;
for s=1:length(muX)
    mean_omega(s,1) = mean(VBA_sigmoid(muX{s}(omega_ind,:), 'slope', phiFitted(s,2), 'center', phiFitted(s,3)));
end

ccc=0;

%ccc=ccc+1;
%S.covariates(ccc).name = 'cbias';
%S.covariates(ccc).values = zscore(cbias');

S.covariates = [];

subset_subjects = 1:32;

% these subjects had poor quality physiological regressors: subset_subjects = find(~ismember(subset_subjects,[7 9 16 19 32]));

j=0;
for c = 1:size(list)
        
    cname = list{c};
    bind = strfind(cname, '*bf(1)');
    cname(bind:end) = [];
    
    S.S_subdir{c,1} = [F.secondlevpath  '/' S.Sname '/' cname '/'];
    
    mkdir(S.S_subdir{c,1})
    
    sc = 0;
    keep_ind =[];
    for s = subset_subjects %1:size(C.subj_array,2)
        if ~isempty(C.con_id{s,c})
            sc=sc+1;
            keep_ind(sc,1)=s;
            S.S_subscans{c}{sc,1} = char(strcat([F.firstlevpath F.subjnames{s} '/'],  char(C.con_id{s,c})));
        end
    end
    
    j = j+1;
    matlabbatch{j}.spm.stats.factorial_design.dir = {S.S_subdir{c,1}};
    matlabbatch{j}.spm.stats.factorial_design.des.t1.scans = S.S_subscans{c};
    matlabbatch{j}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    if ~isempty(S.covariates)
        for cov = 1:length(S.covariates)
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).cname = S.covariates(cov).name;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).iCFI = 1;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).iCC = 1;
            matlabbatch{j}.spm.stats.factorial_design.cov(cov).c = S.covariates(cov).values(keep_ind);
        end
    end
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.files = {''};
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.iCFI = 1;
%     matlabbatch{j}.spm.stats.factorial_design.multi_cov.iCC = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{j}.spm.stats.factorial_design.masking.em = {'/project/3017049.01/SASSS_fMRI1/brainmask_adapted.nii'};
    matlabbatch{j}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{j}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{j}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    j = j+1;
    matlabbatch{j}.spm.stats.fmri_est.spmmat = {[S.S_subdir{c,1} 'SPM.mat']};
    matlabbatch{j}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
    
    j = j+1;
    contrast_vec = zeros(1,1+length(S.covariates));
    matlabbatch{j}.spm.stats.con.spmmat = {[S.S_subdir{c,1} 'SPM.mat']};
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'normal';
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = contrast_vec;
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec(1) = 1;
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{j}.spm.stats.con.delete = 1;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.name = 'inverse';
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.convec = contrast_vec;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.convec(1) = -1;
    matlabbatch{j}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{j}.spm.stats.con.delete = 1;
    if ~isempty(length(S.covariates))
        for cov = 1:length(S.covariates)
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.name = ['pos_' S.covariates(cov).name];
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.convec = contrast_vec;
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.convec(1+cov) = 1;
            matlabbatch{j}.spm.stats.con.consess{2+1+(cov-1)*2}.tcon.sessrep = 'none';
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.name = ['neg_' S.covariates(cov).name];
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.convec = contrast_vec;
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.convec(1+cov) = -1;
            matlabbatch{j}.spm.stats.con.consess{2+2+(cov-1)*2}.tcon.sessrep = 'none';
        end
    end  
end

mkdir(S.S_maindir)
save([S.S_maindir 'one_sample_' date '.mat'], 'matlabbatch');

% execute batch
spm_jobman('initcfg')
spm_jobman('serial', matlabbatch);

