%% script used to smooth the functional images

clear all;close all


nii_dir = 'fMRI_NII/';
subjlist = dir(nii_dir)
subjlist(1:2)=[];
subjlist = subjlist([subjlist.isdir]);
subjlist = {subjlist.name}';
spm_jobman('initcfg')

for s=1:length(subjlist)
    
    subdir = [nii_dir subjlist{s} '/'];
    pattern = '.*^wau';
    files_nii = cellstr(spm_select('FPListRec',subdir,pattern));

    matlabbatch{1}.spm.spatial.smooth.data = files_nii;
    %%
    matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's6';
    
    qsubfeval('spm_jobman', 'serial', matlabbatch, 'memreq', 16*(1024^3), 'timreq', 119*59, 'display', 'no')
   
    
end

