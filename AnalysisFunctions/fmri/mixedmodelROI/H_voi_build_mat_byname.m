%-----------------------------------------------------------------------
% Job saved on 30-Oct-2019 20:06:06 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear all; close all

addpath(genpath('../Pipelines/functions'))
addpath(genpath('/project/3017049.01/Tools/functions'));

REG_file = 'REG.mat';

load(REG_file)
labelled_atlas = '/project/3017049.01/Tools/BN_Atlas_246_1mm.nii,1';
main_path = '/project/3017049.01/SASSS_fMRI1/LEVEL1/'; 
n_sess = 4;

%% atlas
% example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30empty_R6RETROICOR_2ROI_hP96/001/'
% output_path = 'schaeffer_96_noretroi_mean/';
% VOI_model_name = 'SPM12_GLM30empty_R6_2ROI_HP96';
% voi_mode = 'atlas_schaeffer';
% voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.nii';
% suffix = '';
% voilist = execute_voi_extraction(example_level1, voi_argument,voi_mode,suffix, 'give_names');

%% maskfolder
example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30empty_R6RETROICOR_2ROI_HP96/001/';
output_path = 'DiffPE_mean/';
VOI_model_name = 'SPM12_GLM30empty_R6RETROICOR_2ROI_HP96';
voi_mode = 'maskfolder';
voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/SNVTA_func/';
suffix = '';
voilist = execute_voi_extraction(example_level1, voi_argument,voi_mode,suffix, 'give_names');

n_rois = length(voilist);

subjlist = dir([main_path VOI_model_name]);
subjlist(1:2)=[];

%
std5_ind = 1;
% std_omegaPE_ind = 3;

epoching_reg = 'std5'; 
% param 2 extract: which reg, which pmod
% param2extract_reg = {'std5'}, 'prd'};
% param2extract_name = {'std1_omega', 'prd_omega'};
param_interval = [1];
TR=0.7;
rsTR=0.1; % is the time resolution of the file!

trial_window_inTR = [-round(5/rsTR) round(20/rsTR)];
trial_window_inS = [-5:rsTR:20];
mkdir(output_path);

for s=1:length(subjlist)
%      try
    if subjlist(s).isdir
        subfolder_name = [main_path VOI_model_name '/' subjlist(s).name '/'];
        load([subfolder_name 'SPM.mat']);
        clear V;
        fprintf('\n');
        for ses=1:n_sess
            disp(['process subject ' num2str(s) ' / ' sprintf('SES_%0.3d', ses)]);
            concat_roi_rs = [];
            concat_roi = [];
            load([subfolder_name sprintf('%0.3d_runmat_b%d.mat', s,ses)]);
            for r=1:n_rois
                % obtain signal
                voi_file = [subfolder_name sprintf(['VOI_' voilist{r,1} '_%d.mat'], ses)];
                load(voi_file);
%                  try
%                     % within ROI coherence
%                     V{ses}.within_corr(r,1) = nanmean(-1-pdist(xY.y', 'correlation'));
%                     V{ses}.median_data(:,r) = Ymedian;
%                     V{ses}.mean_data(:,r) = Ymean;

%                     V{ses}.mean_data(:,r) = nanmean(xY.y,2);
                    
                    % within ROI entropy
%                     for vx=1:size(xY.y,2)
%                         mparam = 2;
%                         rparam = 0.15*std(xY.y(:,vx)); % *0.5 *0.2
%                         dumentropy(vx,1) = sampen(xY.y(vx,:), mparam,rparam, 'chebychev');
%                     end
%                     V{ses}.within_entropy(r,1) = nanmean(dumentropy);
%                 end
%                 squareform(-1+pdist(xY.y', 'correlation'))
                % resampling through interpolation
                x_base = [0:length(Y(:))-1]*TR;
                x_target = [0:(1*rsTR):x_base(end)];
%                 concat_roi_rs = [concat_roi_rs zscore(smooth(detrend(resample(Y(:),10*TR,10*0.1)),2.1/rsTR, 'moving'))];
                concat_roi_rs = [concat_roi_rs zscore(smooth(interp1(x_base, Ymedian(:), x_target),2.1/rsTR, 'moving'))];
%                 concat_roi_rs = [concat_roi_rs zscore(smooth(interp1(x_base, Y(:), x_target),2.1/rsTR, 'moving'))];

                %                 warning('use Ymean')
                concat_roi = [concat_roi Ymedian(:)];
%                 concat_roi_mean = [concat_roi Ymean(:)];

            end
            % obtain trial onsets
            ind_epoch = strmatch(epoching_reg, REG{s,ses}.names, 'exact');
            trial_start_TR = round(REG{s,ses}.onsets{ind_epoch}*(1/rsTR));
%             for i=1:length(param2extract_reg)
%                 ind_reg = strmatch(param2extract_reg{i},REG{s,ses}.names, 'exact');
%                 possible_names = {REG{s,ses}.pmod(ind_reg).name};
%                 ind_name = strmatch(param2extract_name{i},possible_names{1}, 'exact');
%                 V{ses}.trial_info(:,i) = [REG{s,ses}.pmod(ind_reg).param{ind_name}(1:param_interval(i):end)];
%             end
            V{ses}.trial_data = nan(length(trial_start_TR),n_rois,1+trial_window_inTR(2)-trial_window_inTR(1));
            
            dumnames = {REG{s,ses}.pmod(ind_epoch).name};
            
            V{ses}.trial_info_header = dumnames{1};
            
            for pp=1:length(REG{s,ses}.pmod(ind_epoch).param)
                V{ses}.trial_info(:,pp) = REG{s,ses}.pmod(ind_epoch).param{pp}';
            end
            
            for t=1:length(trial_start_TR)
                trial_indices = trial_start_TR(t)+trial_window_inTR(1):trial_start_TR(t)+trial_window_inTR(2);
                remove_start_indices = find(trial_indices<30);
                remove_end_indices = find(trial_indices>=size(concat_roi_rs,1));
                trial_indices([remove_start_indices remove_end_indices])=[];
                for r=1:n_rois
                    V{ses}.trial_data(t,r,1+length(remove_start_indices):size(V{ses}.trial_data,3)-length(remove_end_indices))=concat_roi_rs(trial_indices,r)'; 
                end
%                 if sum(isnan(V{ses}.trial_data(t,:,1+length(remove_start_indices):size(V{ses}.trial_data,3)-length(remove_end_indices))))==n_rois
%                     error()
%                 end
            end
            
            V{ses}.concat_brain = concat_roi;
            V{ses}.concat_brain_mean = concat_roi;

        end
        save([output_path sprintf('V%.2d.mat',s)],'V');
%         fprintf('\n');
    end
%      catch
%          warning('not')
%     
%     end
end



% 
% % perform the regressions
% for r=1:n_rois
%     roi_trial_data = squeeze(V{s,ses}.trial_data(:,r,:));
%     for tb=1:size(roi_trial_data,2);
%         dumbeta = robustfit(REG{s,ses}.pmod(std5_ind).param{std_omegaPE_ind},roi_trial_data(:,tb));
%         tb_beta(s,r,tb) = dumbeta(2);
%     end
% end

