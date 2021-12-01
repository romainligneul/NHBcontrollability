%% script used to compute second level paired t-tests

%%%%
clear matlabbatch
firstlevpath = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_R6RETROICOR_2ROI_HP96_prior1_UNC/';
load([firstlevpath 'infos_FIPRT.mat'])%, 'F');C
load([firstlevpath 'C.mat']);
addpath(F.spmpath);
spm('defaults', 'fmri')

strcat(num2str([1:length(C.regressor_list)]'), '-', C.regressor_list)

S.name = F.name;
S.analysis_name = 'SAS_SS';

S.id_left = 11;
S.id_right = 12;
S.name_left = C.regressor_list{S.id_left};
S.name_right = C.regressor_list{S.id_right};

S.output_dir= [F.secondlevpath '' S.analysis_name '/'];mkdir(S.output_dir);
matlabbatch{1}.spm.stats.factorial_design.dir = {S.output_dir};

ss = 0;

%%%
noOmegaBIC=[7 9 13 14 17 21 22 24];
% subset_subjects(noOmegaBIC)=[];

for s = 1:length(F.subjnames);
    
%     if ismember(s,noOmegaBIC)
%         warning('skip subjects manually')
%         continue
%     end
%     
    if ~isempty(C.con_id{s,S.id_left}) &&  ~isempty(C.con_id{s,S.id_right})
        ss = ss+1;    
        leftfile = [F.firstlevpath '' F.subjnames{s} '/' C.con_id{s,S.id_left}];
        rightfile = [F.firstlevpath '' F.subjnames{s} '/' C.con_id{s,S.id_right}];

        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(ss).scans = {leftfile; rightfile};
        matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/project/3017049.01/SASSS_fMRI1/LEVEL0/brainmask_binarized.nii'};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    else
        disp(['contrast missing in ' num2str(s)])
    end
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[S.output_dir 'SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

 matlabbatch{3}.spm.stats.con.spmmat = {[S.output_dir 'SPM.mat']};
    matlabbatch{3}.spm.stats.con.delete = 1;

    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = S.name_left;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 0 ones(1,ss)/ss];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
 
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = S.name_right;
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 1 ones(1,ss)/ss];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = [S.name_left ' MIN ' S.name_right];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 -1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
     
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = [S.name_right ' MIN ' S.name_left];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';   
    
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.name = 'fplot';
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.convec = [1 0 ones(1,ss)/ss; 0 1 ones(1,ss)/ss];
    matlabbatch{3}.spm.stats.con.consess{5}.fcon.sessrep = 'none';   
    
end

% execute batch
spm_jobman('initcfg')
spm_jobman('serial', matlabbatch);

