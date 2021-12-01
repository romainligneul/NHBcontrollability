%-----------------------------------------------------------------------
% Job saved on 20-Mar-2016 19:20:35 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
addpath('/project/3017049.01/Tools/spm12')

clear all; delete_all = 0;
addpath('/home/common/matlab/fieldtrip/qsub');
addpath(genpath('functions'));
suppress = 1;
I.nii_dir = 'fMRI_NII/';
% prefix of SPM-converted nii folders
I.str_phasemag = 'gre_field_mapMakeAdjustVolumeTheSame_';
I.str_anat = 't1_mprage_sag';
I.str_base_epi = 'cmrr_24iso_mb8_TR0700_';
I.str_img_epi = 'fMX_1_1_1_';
% prefixes
I.str_realign_unwarp = 'u'; % image prefix
I.str_slicetimed = 'a'; 
I.str_coregistered = 'r'; 
I.str_normalized_wholebrain = 'w';
I.str_normalized_brainstem = 'b';
% I.str_normalized = 'w';
% I.str_smoothed = 's';
I.anatdir = '/project/3017049.01/SASSS_fMRI1/ANAT_SSSAS/Reoriented_ANAT/';
I.suitdir = '/project/3017049.01/SASSS_fMRI1/ANAT_SSSAS/Cropped_ANAT/';
% build session per subjects
default_session_names = {'0007', '0008', '0009', '0010', '0013'}';
default_session_names = cellstr(strcat(I.str_base_epi, default_session_names));
% get all folders
dum = dir(I.nii_dir);dum(1:2) = [];
for d = 1:length(dum)
    if d == 1
        special_session_names = {'0009','0010', '0011', '0012', '0018'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;
    elseif d== 6
        special_session_names = {'0007','0008', '0009', '0011', '0014'}';
        special_session_names = cellstr(strcat(I.str_base_epi, special_session_names));
        I.sessions{d,1} = special_session_names;        
    elseif d== 9 % see comment (BLOC B unrecorded at first)
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
    for ss = I1:lIength(I.sessions{d});
        dumlistI0 = spm_select('List',[I.rawdir{d,1},'/', I.sessions{d}{ss}], '^f.*nii');         
        I.epi_files{d,1}{ss} = strcat(I.rawdir{d,1},'/', I.sessions{d}{ss}, '/', dumlist0);
        I.epi_files_sprintf{d,1}{ss} = strcat(I.rawdir{d,1},'/', I.sessions{d}{ss}, '/%s', dumlist0);
    end
    
end

save(['LEVEL0/ preprocess_relocate_' date '_' num2str(length(I.skip)) 's.mat'], 'I');