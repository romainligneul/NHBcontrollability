%% script used to compute the tSNR of functional images

clear all;close all


%% mean and std images

nii_dir = 'fMRI_NII/';
subjlist = dir(nii_dir)
subjlist(1:2)=[];
subjlist = subjlist([subjlist.isdir]);
subjlist = {subjlist.name}';

tsnr_dir = 'tSNR/';
mkdir(tsnr_dir);

for s=1:length(subjlist)
    
    subdir = [nii_dir subjlist{s} '/'];
    pattern = '.*wau';
    files_nii = cellstr(spm_select('FPListRec',subdir,pattern));
    
    matlabbatch{s}.spm.util.imcalc.input = files_nii;
    matlabbatch{s}.spm.util.imcalc.output = ['mean_' subjlist{s}];
    matlabbatch{s}.spm.util.imcalc.outdir = {[tsnr_dir  '/']};
    matlabbatch{s}.spm.util.imcalc.expression = 'mean(X)';
    matlabbatch{s}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{s}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{s}.spm.util.imcalc.options.mask = 0;
    matlabbatch{s}.spm.util.imcalc.options.interp = 1;
    matlabbatch{s}.spm.util.imcalc.options.dtype = 4;
    
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.input = files_nii;
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.output = ['std_' subjlist{s}];
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.outdir = {[tsnr_dir  '/']};
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.expression = 'std(X)';
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.options.mask = 0;
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.options.interp = 1;
    matlabbatch{s+length(subjlist)}.spm.util.imcalc.options.dtype = 4;
    
end

% run
spm_jobman('initcfg')
clear job_batch
for ss=1:s
    job_batch{1} = matlabbatch{ss};
    spm_jobman('run', job_batch);
end

%% mean/std images

tsnr_dir = 'tSNR/';
subjlist = dir(tsnr_dir)
subjlist(1:2)=[];
subjlist = subjlist([subjlist.isdir]);
subjlist = {subjlist.name}';

mkdir(tsnr_dir);

clear matlabbatch

for s=1:length(subjlist)/2
    pattern = '.*tSNR';
    
    matlabbatch{s}.spm.util.imcalc.input = {[tsnr_dir subjlist{s}];[tsnr_dir subjlist{s+length(subjlist)/2}]};
    matlabbatch{s}.spm.util.imcalc.output = ['tSNR_' subjlist{s}];
    matlabbatch{s}.spm.util.imcalc.outdir = {[tsnr_dir  '/']};
    matlabbatch{s}.spm.util.imcalc.expression = 'i1./i2';
    matlabbatch{s}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{s}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{s}.spm.util.imcalc.options.mask = 0;
    matlabbatch{s}.spm.util.imcalc.options.interp = 1;
    matlabbatch{s}.spm.util.imcalc.options.dtype = 4;
    
end

spm_jobman('initcfg')

spm_jobman('run', matlabbatch)

clear matlabbatch

%% group image
clear matlabbatch
pattern = '.*tSNR';

matlabbatch{1}.spm.util.imcalc.input = cellstr(spm_select('FPListRec',tsnr_dir,pattern));
matlabbatch{1}.spm.util.imcalc.output = 'grouplevelSNR';
matlabbatch{1}.spm.util.imcalc.outdir = {[tsnr_dir  '/']};
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run', matlabbatch)