%
clear all
close all
addpath('/project/3017049.01/Tools/functions')
addpath('/project/3017049.01/Tools/functions/gramm-master')
addpath('/project/3017049.01/SASSS_fMRI1/Pipelines/functions');
rmpath(genpath('/project/3017049.01/Tools/spm12'))
addpath('/project/3017049.01/Tools/spm12')

%
example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30empty_R6RETROICOR_2ROI_HP96/001/';
%   voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis/all_nocov/std5xstd_omegaPE^1/clusters/'
% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis/all_nocov/prdxprd_omega^1/clusters/';

% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30sasbis_R6RETROICOR_2ROI_HP96_bis/SS_SAS_intermodel/clusters/';
% 
% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30sasbis_R6RETROICOR_2ROI_HP96_bis/SS_SAS_intermodel/clusters/';
%  voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30sasbis_R6RETROICOR_2ROI_HP96_bis/SS_SAS_intermodel/clusters/';

%   voi_argument = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/InvPE_peaks_005/';
% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis/all_nocov/std5xstd_omegaPE^1/clusters/';
example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30empty_R6_2ROI_hP96/001/';
voi_mode = 'maskfolder';
% voi_argument ='/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii';
voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_catPE_RT/rois_cat/';
suffix = '';
voilist = execute_voi_extraction(example_level1, voi_argument,voi_mode,suffix, 'give_names');
timeseries_dir = 'OmegaPE/';
timeseries_filelist = dir(timeseries_dir);
timeseries_filelist(1:2)=[];


% example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30totallyempty_R6RETROICOR_2ROI/001/'
% voi_argument =  '/project/3017049.01/Tools/Harvard_Brainstem_ROIs/';
% voi_mode = 'maskfolder';
% suffix = '';
% voilist = execute_voi_extraction(example_level1, voi_argument, voi_mode,suffix, 'give_names')
% timeseries_dir = 'BScluster_std5_all_196/';
% timeseries_filelist = dir(timeseries_dir);
% timeseries_filelist(1:2)=[];

%
% auto list method
% example_level1 = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30totallyempty_R6RETROICOR_2ROI/001/'
% voi_argument = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96/all_mm/std5xstd_omegaPE^1/Table_InvOmegaPE_005_10.csv';
% voi_mode = 'csv_table_3mm';
% suffix = 'InvOmPE';
% voilist = execute_voi_extraction(example_level1, voi_argument,
% voi_mode,suffix, 'give_names')',
% voilist={'Lingual L', 'Frontal Inf Oper R', 'SupraMarginal R', 'Cingulum Mid R*', 'Thalamus R', 'Cingulum Ant L*', 'Temporal Pole Sup L','Parietal Inf L*'};
% timeseries_dir = 'InvOmegaPEpeaks_std5_all/';
% timeseries_filelist = dir(timeseries_dir);
% timeseries_filelist(1:2)=[];

% regressors = {'prd_sigomega', 'prd_RT'};

% regressors = {'std_omega', 'std_RT'};
tic
regressors = {'std_omegaPE','std_omega', 'std_RT'};%,'std_sasPE', 'std_RT'};
% regressors = {'std_sasPE','std_ssPE','std_RT'};%,'std_ssPE'};%,'std_RT'};

split_regressors = {'', '', ''};


% regressors = {'std_omegaPE'};


rsTR=0.1;
TR = 0.5;

trial_window_inTR = [-round(5/TR) round(20/TR)];
trial_window_inS = [-5:TR:20];

trial_window_newFS = trial_window_inS;
bsl_window = [-3 -0.5];

timeseries_filelist([timeseries_filelist.isdir])=[];

roi_vec = 1:length(voilist);

strcat(num2str([1:length(voilist)]'),'-',char(voilist))
%  roi_vec = 6;
concat_trial_info = [];
concat_trial_data = [];
concat_trial_id = [];

subset_subjects = 1:32;
% subset_subjects = find(~ismember(subset_subjects,[7 9 16 19 32]));

ss=0;
for s=subset_subjects % 1:length(timeseries_filelist);

    load([timeseries_dir timeseries_filelist(s).name]);
    ss = ss+1;
    concat_subj_info = [];   
    concat_subj_data = [];
    ds_subj_concat_data = [];
    for ses=1:length(V)
        concat_subj_data = [concat_subj_data; V{ses}.trial_data];
        concat_subj_info = [concat_subj_info; V{ses}.trial_info];
        concat_trial_id = [concat_trial_id; ss*ones(size(V{ses}.trial_info,1),1)];
    end
    for r=1:size(concat_subj_data,2)
        x_base = [0:size(concat_subj_data,3)-1]*rsTR;
        x_target = [0:(1*TR):x_base(end)];
        rdata = squeeze(concat_subj_data(:,r,:))';
        ds_subj_concat_data(:,r,:) = interp1(x_base,rdata, x_target)';
    end
    concat_trial_info = [concat_trial_info;     zscore(concat_subj_info)] ;%
%     concat_trial_info = [concat_trial_info; concat_subj_info-repmat(mean(concat_subj_info),size(concat_subj_info,1),1);];
    nonan = ~isnan(ds_subj_concat_data);
    ds_subj_concat_data(nonan)= zscore(ds_subj_concat_data(nonan));
    concat_trial_data = [concat_trial_data; ds_subj_concat_data];
    
end

% % % 
% disp('smooth and baseline correct')
% for t=1:size(concat_trial_data,1)
%     for r=1:size(concat_trial_data,2)
% %         rs1_concat_trial_data(t,r,:) = interp1(trial_window_inS, smooth(squeeze(concat_trial_data(t,r,:)),2.1/rsTR, 'moving'), trial_window_newFS);
%         bsl_val = nanmean(squeeze(concat_trial_data(t,r,trial_window_inS>bsl_window(1) & trial_window_inS<bsl_window(2))));
%         if isnan(bsl_val)
%             bsl_val = nanmean(concat_trial_data(t,r,:));
%         end
%          concat_trial_data(t,r,:) = concat_trial_data(t,r,:)-bsl_val ; 
% %         concat_trial_data_final(t,r,:) = smooth(squeeze(concat_trial_data(t,r,:))-bsl_val,2.1/rsTR, 'moving');
% %         concat_trial_data_final(t,r,:) = smooth(squeeze(concat_trial_data(t,r,:)),1.4/rsTR, 'moving');
%     end
% end
% % 
% % build group variable
SUBJ = {nominal(concat_trial_id)};

% build random effects
for reg=1:length(regressors)
    reg_ind(reg) = strmatch(regressors{reg}, V{ses}.trial_info_header, 'exact');
end
% substract_ind = strmatch('std_sasPE',V{ses}.trial_info_header, 'exact');
% substract_to_ind = strmatch('std_ssPE',V{ses}.trial_info_header, 'exact');
% concat_trial_info(:,substract_to_ind) = concat_trial_info(:,substract_to_ind)-concat_trial_info(:,substract_ind);
%  FFX = [ones(size(concat_trial_info,1), 1) zscore(concat_trial_info(:,reg_ind(1))-concat_trial_info(:,reg_ind(2))) zscore(concat_trial_info(:,reg_ind(3)))];

FFX = [ones(size(concat_trial_info,1), 1) concat_trial_info(:,reg_ind(1)) concat_trial_info(:,reg_ind(2)) concat_trial_info(:,reg_ind(3))];
%  FFX(:,2) = FFX(:,2)-mean(FFX(:,2));
%  FFX(:,3) = FFX(:,3)-mean(FFX(:,3));

%     FFX = [ones(size(concat_trial_info,1), 1) zscore(concat_trial_info(:,reg_ind))];

for reg = 1:length(regressors)
    
    if strcmp(split_regressors{reg}, 'tercile')
       dummy=binvariable(zscore(concat_trial_info(:,reg_ind(reg))),3);
       % the middle category will correspond to the intercept
       FFX(:,end+1)=double(dummy==1);
       FFX(:,end+1)=double(dummy==3);
       FFX(:,reg+1)=[];
       regressors(end+1) = {['low_' regressors{reg}]};
       regressors(end+1) = {['high_' regressors{reg}]};
       regressors(reg) = [];
    elseif strcmp(split_regressors{reg}, 'quintile')
       dummy=binvariable(zscore(concat_trial_info(:,reg_ind(reg))),5);
       % the middle category will correspond to the intercept
       FFX(:,end+1)=double(dummy==1);
       FFX(:,end+1)=double(dummy==5);
       FFX(:,end+1)=double(dummy==2);
       FFX(:,end+1)=double(dummy==4);       
       FFX(:,reg+1)=[];
       regressors(end+1) = {['vlow_' regressors{reg}]};
       regressors(end+1) = {['vhigh_' regressors{reg}]};
       regressors(end+1) = {['low_' regressors{reg}]};
       regressors(end+1) = {['high_' regressors{reg}]};
       regressors(reg) = [];        
    end
    
end
% regressors = {'std_sas_min_ssPE', 'std_RT'};


% RFXnames = {'Intercept', regressors{:}};

% random fixed effects
RFX = {ones(size(concat_trial_info,1), 1)};

for r=roi_vec
    
    disp(['process roi ' num2str(r)]);
    
    mixed.roi_name{r,1} = voilist{r};
    mixed.time_axis = trial_window_newFS;
    mixed.FFX = FFX;
    mixed.bsl_window = bsl_window;
    
    for tb=1:size(concat_trial_data,3)
        
        % build Y (single roi)
        Y = squeeze(concat_trial_data(:,r,tb));
        
        lme = fitlmematrix(FFX,Y,RFX,SUBJ,'FitMethod','REML','FixedEffectPredictors',....
            {'Intercept' regressors{:}},'RandomEffectPredictors',{{'Intercept'}},...
            'RandomEffectGroups',{'Intercept'},'DummyVarCoding','effects');
        
        
        mixed.estimate{r,1}(:,tb)=lme.Coefficients.Estimate;
        mixed.tStat{r,1}(:,tb)=lme.Coefficients.tStat;
        mixed.se{r,1}(:,tb)=lme.Coefficients.SE;
        mixed.lowCI95{r,1}(:,tb)=lme.Coefficients.Lower;
        mixed.highCI95{r,1}(:,tb)=lme.Coefficients.Upper;
        mixed.pValue{r,1}(:,tb)=lme.Coefficients.pValue;
%         for eff1=1:length(lme.Coefficients.Estimate)
%             for eff2=1:length(lme.Coefficients.Estimate)
%                 h_mat = zeros(1,length(lme.Coefficients.Estimate));
%                 h_mat(eff1)= 1;
%                 h_mat(eff2)= 1;
%                 mixed.contrast_pval{r,1}(eff1,eff2,tb) = coefTest(lme,h_mat);
%             end
%         end
    end
end

disp('save');

dumstr = {'Intercept' regressors{:}};
savestr = 'MixedModel_ds';
for d=1:length(dumstr)
    savestr = [savestr '_'  dumstr{d}];
end

mkdir([timeseries_dir 'results/']);

save([timeseries_dir 'results/' savestr '.mat'], 'mixed');
