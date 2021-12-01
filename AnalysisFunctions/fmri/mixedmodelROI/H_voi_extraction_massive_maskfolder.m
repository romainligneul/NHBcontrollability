%-----------------------------------------------------------------------
% Job saved on 30-Oct-2019 20:06:06 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear all

addpath(genpath('/project/3017049.01/SASSS_fMRI1/Pipelines/functions'))
main_path = '/project/3017049.01/SASSS_fMRI1/LEVEL1/';
model_name = 'SPM12_GLM30empty_R6RETROICOR_2ROI_HP96';

% voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/InvPE_peaks_005/';


% voi_argument = '/project/3017049.01/SASSS_fMRI1/Anatomical_ROIs_subset/';

% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30sasbis_R6RETROICOR_2ROI_HP96_bis/SS_SAS_intermodel/clusters/';
% voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/Omega_Encoding/';
voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/SNVTA_func/';
subjlist = dir([main_path model_name]);
subjlist(1:2)=[];

cluster_comp = true;
        folder_name = [main_path model_name];

voi_mode = 'maskfolder';
%              execute_voi_extraction_superlinear(folder_name,voi_argument,voi_mode, '')
if ~cluster_comp
    %              execute_voi_extraction_linear(subfolder_name,voi_argument,voi_mode, '')
    execute_voi_extraction_superlinear(folder_name,voi_argument,voi_mode, '')
    
else

    for s=1:length(subjlist)
        if subjlist(s).isdir
            subfolder_name = [main_path model_name '/' subjlist(s).name '/'];
            
            job_id{s} = qsubfeval('execute_voi_extraction', subfolder_name,voi_argument,voi_mode,'', 'memreq',  6*(1024^3), 'timreq', 300*60);%, 'matlabcmd', 'matlab -nodisplay -nodesktop -nosplash');
        end
    end

end




