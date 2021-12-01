%% script used to compute second level paired t-tests (allowing different GLMs of origin)

%%%%
clear matlabbatch
% left model
firstlevpath{1} = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_R6RETROICOR_2ROI_HP96_prior1_SASunc/';
% right model
firstlevpath{2} = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_R6RETROICOR_2ROI_HP96_prior1_SSunc/';
% results stored in left model!

load([firstlevpath{1} 'infos_FIPRT.mat'],'F')%, 'F');C
Cinfo{1} = load([firstlevpath{1} 'C.mat']);
Cinfo{2} = load([firstlevpath{2} 'C.mat']);

disp('%%% MODEL LEFT:')
strcat(num2str([1:length(Cinfo{1}.C.regressor_list)]'), ' - ', Cinfo{1}.C.regressor_list)
disp('%%% MODEL RIGHT:')
strcat(num2str([1:length(Cinfo{2}.C.regressor_list)]'), ' - ', Cinfo{2}.C.regressor_list)

addpath(F.spmpath);
spm('defaults', 'fmri')

S.name = F.name;

S.analysis_name = 'SAS_SS_entropy';

S.id_left = 11;
S.id_right = 11;
S.name_left = Cinfo{1}.C.regressor_list{S.id_left};
S.name_right = Cinfo{2}.C.regressor_list{S.id_right};

S.output_dir= [F.secondlevpath '' S.analysis_name '/'];mkdir(S.output_dir);
matlabbatch{1}.spm.stats.factorial_design.dir = {S.output_dir};

ss = 0;

for s = 1:length(F.subjnames);
    
    if ~isempty(Cinfo{1}.C.con_name(s,S.id_left)) &&  ~isempty(Cinfo{2}.C.con_name(s,S.id_right))
        ss = ss+1;    
        leftfile = [firstlevpath{1}  '' F.subjnames{s} '/' Cinfo{1}.C.con_id{s,S.id_left}];
        rightfile = [firstlevpath{2} '' F.subjnames{s} '/' Cinfo{2}.C.con_id{s,S.id_right}];

        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(ss).scans = {leftfile; rightfile};
        matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};%{'/project/3017049.01/SASSS_fMRI1/brainmask_adapted.nii'};
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

