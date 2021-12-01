%% script used to preprocess the fMRI data

clear all; delete_all = 0;

%% paths
% spm 12 must be in your path
addpath(genpath('functions'));
suppress = 1;
I.nii_dir = 'fMRI_NII/'; % must be adapted to folder structure

%% prefix of SPM-converted nii folders
I.str_phasemag = 'gre_field_mapMakeAdjustVolumeTheSame_';
I.str_anat = 't1_mprage_sag';
I.str_base_epi = 'cmrr_24iso_mb8_TR0700_';
I.str_img_epi = 'fMX_1_1_1_';

%% prefixes
I.str_realign_unwarp = 'u'; % image prefix
I.str_slicetimed = 'a'; 
I.str_coregistered = 'r'; 
I.str_normalized_wholebrain = 'w';
I.str_normalized_brainstem = 'b';
I.anatdir = '/home/control/romlig/SASSS_fMRI1/ANAT_SSSAS/Reoriented_ANAT/';
I.suitdir = '/home/control/romlig/SASSS_fMRI1/ANAT_SSSAS/Cropped_ANAT/';

%% default run names per subjects
default_session_names = {'0007', '0008', '0009', '0010', '0013'}';
default_session_names = cellstr(strcat(I.str_base_epi, default_session_names));

%% get all folders
dum = dir(I.nii_dir);dum(1:2) = [];
for d = 1:length(dum)
    % hardcoded exceptions
    if d == 1
        special_session_names = {'0009','0010', '0011', '0012', '0018'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;
    elseif d== 6
        special_session_names = {'0007','0008', '0009', '0011', '0014'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;        
    elseif d== 9 % see comment (bloc B made last, 0013)
        special_session_names = {'0008','0016', '0009', '0010', '0013'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;
    elseif d == 23
        special_session_names = {'0008', '0009','0010', '0011', '0014'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;
     elseif d == 32
        special_session_names = {'0007', '0008','0009', '0010', '0014'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;
    else
        I.sessions{d,1} = default_session_names;
    end
end

% retrieve all images and put them in the I (import) structure
for d = 1:length(dum);
    I.nii_subdirs{d,1} = strcat(pwd,'/',I.nii_dir, dum(d).name,'/');
    I.anat_file{d,1} = strcat(I.anatdir, 'sMX_', dum(d).name, '.nii');
    I.anat_file_sprintf{d,1} = strcat(I.anatdir,'%s', 'sMX_', dum(d).name, '.nii');
    I.suit_mask{d,1} = strcat(I.suitdir, 'c_sMX_', dum(d).name, '_pcereb_corr_final.nii');
    I.suit_matrix{d,1} = strcat(I.suitdir, 'mc_sMX_', dum(d).name, '_snc.mat');
    
    dum2 = dir(I.nii_subdirs{d,1});dum2(1:2) = [];
    for dd = 1:length(dum2)
        if ~isempty(strmatch(dum2(dd).name,['realigned_unwarped_' dum(d).name]));
            I.skip(d) = 1;
        else
            I.skip(d)=0;
        end
        first2 = strfind(dum2(dd).name,'16');
        if ~isempty(first2) && first2(1)==1
            I.rawdir{d,1} = strcat(I.nii_subdirs{d,1},dum2(dd).name);
            dum3 = dir(I.rawdir{d,1});dum3(1:2)=[];
            ind = [];
            for ddd = 1:length(dum3)
                if ~isempty(strfind(dum3(ddd).name,I.str_phasemag));
                    ind(end+1,:) = [str2num(dum3(ddd).name(end-3:end)) ddd];
                end
            end
            sorted_ind = sortrows(ind,1);
            I.magnitude_file{d,1} = strcat(I.rawdir{d,1},'/', dum3(sorted_ind(1,2)).name,'/', spm_select('List',strcat(I.rawdir{d,1},'/', dum3(sorted_ind(1,2)).name),'^sMX_1'));
            I.phase_file{d,1} = strcat(I.rawdir{d,1},'/', dum3(sorted_ind(2,2)).name,'/', spm_select('List',strcat(I.rawdir{d,1},'/', dum3(sorted_ind(2,2)).name),'^sPX'));
            dumphasefile = spm_select('List',strcat(I.rawdir{d,1},'/', dum3(sorted_ind(2,2)).name),'^sPX');
            I.phase_file_sprintf{d,1} = strcat(I.rawdir{d,1},'/', dum3(sorted_ind(2,2)).name,'/%s',dumphasefile(1:end-4), '%s', '.nii');
        end
    end;
    for ss = 1:length(I.sessions{d});
        dumlist0 = spm_select('List',[I.rawdir{d,1},'/', I.sessions{d}{ss}], '^f.*nii');         
        I.epi_files{d,1}{ss} = strcat(I.rawdir{d,1},'/', I.sessions{d}{ss}, '/', dumlist0);
        I.epi_files_sprintf{d,1}{ss} = strcat(I.rawdir{d,1},'/', I.sessions{d}{ss}, '/%s', dumlist0);
    end
    
end

for d = 1:length(I.skip)
    
    clear matlabbatch;
    
    %% compute vdm maps per session
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = cellstr(I.phase_file{d,1});
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = I.magnitude_file(d,1);
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {'/home/control/romlig/Tools/spm12/toolbox/FieldMap/pm_defaults_prisma.m'};
    for ss = 1:length(I.sessions{d})
        % use the first epi of each session
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session(ss).epi = {deblank(I.epi_files{d,1}{ss}(1,:))};
    end
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = {''};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    
    %% realign & unwarp optioons
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.rtm = 0;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.einterp = 3;
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realignunwarp.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.sot = [];
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.rem = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.noi = 5;
    matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.prefix = I.str_realign_unwarp; 
    % load epis & fieldmaps
    for ss = 1:length(I.sessions{d})
        matlabbatch{2}.spm.spatial.realignunwarp.data(ss).scans = cellstr(I.epi_files{d,1}{ss});
        matlabbatch{2}.spm.spatial.realignunwarp.data(ss).pmscan = {sprintf(I.phase_file_sprintf{d,1},'vdm5_sc', ['_session' num2str(ss)])};
    end
    
    %% slice timing
    fordeletion = [];
    for ss = 1:length(I.sessions{d})
        matlabbatch{3}.spm.temporal.st.scans{ss} = regexprep(cellstr(I.epi_files_sprintf{d,1}{ss}),'%s', I.str_realign_unwarp);
        fordeletion = [fordeletion;matlabbatch{3}.spm.temporal.st.scans{ss}];
    end
    matlabbatch{3}.spm.temporal.st.nslices = 64;
    matlabbatch{3}.spm.temporal.st.tr = 0.7;
    matlabbatch{3}.spm.temporal.st.ta = matlabbatch{3}.spm.temporal.st.tr-(matlabbatch{3}.spm.temporal.st.tr/matlabbatch{3}.spm.temporal.st.nslices);
    matlabbatch{3}.spm.temporal.st.so = [2:2:64 1:2:63]; % confirmed with Paul: interleaved starting from even
    matlabbatch{3}.spm.temporal.st.refslice = 1;
    matlabbatch{3}.spm.temporal.st.prefix = I.str_slicetimed;

    %% delete non slice-timed images
    matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_move.files = fordeletion;
    matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;    
    
    %% coregister functional on T1
    % load session wise unwarped, slice-timed files into a single cellstr list
    dumstr = [];
    for ss = 1:length(I.sessions{d,1})
        dumstr = [dumstr; regexprep(cellstr(I.epi_files_sprintf{d,1}{ss}),'%s', [I.str_slicetimed I.str_realign_unwarp])];
    end    
    matlabbatch{5}.spm.spatial.coreg.estimate.ref =  I.anat_file(d,1); % raw anatomical
    matlabbatch{5}.spm.spatial.coreg.estimate.source = cellstr(sprintf(I.epi_files_sprintf{d,1}{1}(1,:),['mean' I.str_realign_unwarp]));% cell string with mean functional
    matlabbatch{5}.spm.spatial.coreg.estimate.other = dumstr;
    matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    %% normalize functional images to MNI (simultaneously apply coregistration)
    matlabbatch{6}.spm.spatial.normalise.write.subj.def = cellstr(sprintf(I.anat_file_sprintf{d,1},'y_'));
    matlabbatch{6}.spm.spatial.normalise.write.subj.resample = dumstr;
    matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
        78 76 85];
    matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = I.str_normalized_wholebrain;
    
    %% normalize functional images to SUIT (simultaneously apply coregistration? UNSURE!)
    matlabbatch{7}.spm.tools.suit.reslice.subj.paramfile = I.suit_matrix(d,1);% {'/home/control/romlig/SASSS_fMRI1/ANAT_SSSAS/Cropped_ANAT/mc_sMX_001A_snc.mat'};
    matlabbatch{7}.spm.tools.suit.reslice.subj.resample = dumstr;
    matlabbatch{7}.spm.tools.suit.reslice.subj.mask = I.suit_mask(d,1);
    matlabbatch{7}.spm.tools.suit.reslice.smooth_mask = 2;
    matlabbatch{7}.spm.tools.suit.reslice.preserve = 0;
    matlabbatch{7}.spm.tools.suit.reslice.bb = [-70 -100 -75
        70 -6 11];
    matlabbatch{7}.spm.tools.suit.reslice.vox = [2 2 2];
    matlabbatch{7}.spm.tools.suit.reslice.interp = 1;
    matlabbatch{7}.spm.tools.suit.reslice.prefix = I.str_normalized_brainstem;
    
     %% delete non-normalized images
    matlabbatch{8}.cfg_basicio.file_dir.file_ops.file_move.files = dumstr;
    matlabbatch{8}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;    
    
    
    %% insert subject in cluster_job structure
    cluster_job{d} = matlabbatch;

end

%% save job
active_jobfile = 'active_job.mat';
save(active_jobfile, 'cluster_job')

%% run job (see spm_jobman to adapt to your needs)
jobs = cluster_job{jobid}; %matlabbatch(jobid);
spm('defaults', 'FMRI');
spm_jobman('serial', jobs);
   
% adapt to your needs:
save(['LEVEL0/ preprocess' date '_' num2str(length(I.skip)) 's.mat'], 'I', 'cluster_job');