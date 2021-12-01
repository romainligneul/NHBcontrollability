clear all
close all

addpath('/project/3017049.01/Tools/spm12')
addpath('/project/3017049.01/Tools/functions/gramm-master')

%% where are the volumes from which the signal should be extracted
tic

disp('multiROIs multifolders: preprocessing');
basedir = '/project/3017049.01/SASSS_fMRI1/MACS/ALL_MAPS/';
subdirs = {'Null/',...
           'SS/',...
           'SAS/',...
           'OmPE/',...
           'Om/',...
           'dPE/' };
       subdirs = {'Null/',...
           'SS/',...
           'SAS/',...
           'dPE/' };
        subdirs = {'Null/',...
           'SS/',...
           'SAS/' };
 subdirs = subdirs(1:end);      
pattern_pref = 'MA__AIC';
pattern_suff = '.nii';

% gather all files
filenames={};
for d = 1:length(subdirs)
    targetdir = [basedir subdirs{d}];
    dummy = dir(targetdir);
    dummy = {dummy.name}';
    cellsz = 1-cell2mat(cellfun(@isempty,regexpi(dummy,['^' pattern_pref '.*' pattern_suff]),'uni',false));
    filenames{d} = dummy(find(cellsz));
end
    
controlACC=[0.705263157894737;0.683673469387755;0.710843373493976;0.837837837837838;0.792207792207792;0.732558139534884;0.565891472868217;0.743902439024390;0.576271186440678;0.752808988764045;0.759493670886076;0.736263736263736;0.594339622641509;0.470588235294118;0.780487804878049;0.712643678160920;0.770833333333333;0.805555555555556;0.740259740259740;0.783783783783784;0.699186991869919;0.644444444444445;0.846153846153846;0.488721804511278;0.519083969465649;0.726027397260274;0.666666666666667;0.823529411764706;0.747474747474748;0.691489361702128;0.884057971014493;0.747126436781609];
ACC = [0.657894736842105;0.642857142857143;0.704819277108434;0.858108108108108;0.792207792207792;0.732558139534884;0.468992248062016;0.737804878048781;0.487288135593220;0.668539325842697;0.765822784810127;0.670329670329670;0.570754716981132;0.495798319327731;0.725609756097561;0.706896551724138;0.552083333333333;0.833333333333333;0.772727272727273;0.790540540540541;0.402439024390244;0.655555555555556;0.900000000000000;0.458646616541353;0.461832061068702;0.815068493150685;0.694444444444444;0.867647058823529;0.616161616161616;0.675531914893617;0.876811594202899;0.672413793103448];
subset_subj = 1:32;%find(controlACC>median(controlACC));
find(ACC<0.5)
subset_subj = find(~ismember(subset_subj, [7 9 16 19 32]));

%% where are the ROIs from which the signal should be extracted
% they should all be in the same location

 roidir = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/p0001_all/ModelsOfInterestPEsimple/';
%   roidir = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/p0001_all/ModelsOfInterest/';
%    roidir = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/Anatomical_ROIs_subset/rPauli2018_SNVTA/';
%   roidir = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/spheres_quin/';

 roilist = 'all'; % 'all' for all images in folder. cellstr of exact names (no extension) otherwise
roi_ext = '.nii';

if strcmp(roilist,'all')
    dummy = dir(roidir);
    dummy = {dummy.name}';
    cellsz = 1-cell2mat(cellfun(@isempty,regexpi(dummy,['^.*' pattern_suff]),'uni',false));    
    roinames = dummy(find(cellsz));
else
    roinames = roilist;
end

    
%% do the extraction job
result_table = table();

for r=1:length(roinames)
    
    disp(['multiROIs multifolders: ' roinames{r}]);

    % open the roi file
    ROI = spm_vol([roidir roinames{r}]);
    [R XYZ] = spm_read_vols(ROI);
    roi_ind = find(R>0);
    R_XYZ = XYZ(:,roi_ind);
        
    for d=1:length(subdirs)
        
        % obtain image space from first file
        VOL = spm_vol([basedir subdirs{d} filenames{d}{1}]);
        [V XYZ] = spm_read_vols(ROI);
        roi2vol_ind = nan(1,size(R_XYZ,2));
        for vx=1:size(R_XYZ,2)
           [dum,roi2vol_ind(vx)] = spm_XYZreg('NearestXYZ',R_XYZ(:,vx),XYZ);
%            VOL_XYZmm(:,vx)=dum;
        end
        [x,y,z] = ind2sub(size(V),roi2vol_ind);
        XYZvx = [x;y;z];
        
        % obtain all voxel values
        [extdata] = spm_get_data(cellstr(strcat(basedir,subdirs{d},char(filenames{d}))),XYZvx,true);
        
        % build the fields
        Roi = repmat(cellstr(roinames{r}(1:end-4)),size(extdata,1),1);
        Folder = repmat(cellstr(subdirs{d}),size(extdata,1),1);        
        Target = filenames{d};
        Mean = nanmean(extdata,2);
        Std = nanstd(extdata,[],2);
        Median = nanmedian(extdata,2);  
        Subindex = [1:size(extdata,1)]';

        % apply summary statistics across voxels and make a table
        result_table = [result_table; table(Roi,Folder, Target, Mean, Std, Median, Subindex)];
        result_table = [result_table; table(Roi,Folder, Target, Mean, Std, Median, Subindex)];
        
    end
    
    toc;
    
end

% substract target
folder_flag = subdirs{1};
unique_rois = unique(result_table.Roi)
result_table_corrected = result_table;
for r=1:length(unique_rois)
    target_mean = mean(result_table.Mean(ismember(result_table.Folder, folder_flag) & ismember(result_table.Roi,unique_rois{r}) & ismember(result_table.Subindex, subset_subj)));
    result_table_corrected.Mean(ismember(result_table.Roi,unique_rois{r})) = result_table.Mean(ismember(result_table.Roi,unique_rois{r}))-target_mean;
    target_median = mean(result_table.Median(ismember(result_table.Folder, folder_flag) & ismember(result_table.Roi,unique_rois{r}) & ismember(result_table.Subindex, subset_subj)));
    result_table_corrected.Median(ismember(result_table.Roi,unique_rois{r})) = result_table.Median(ismember(result_table.Roi,unique_rois{r}))-target_median;
end

% plot per ROI per folder
CC.omegaPE = [20 55 90]/100;
CC.ssPE = [30 80 30]/100;
CC.sasPE = [85 80 20]/100;
CC.omega = [80 35 80]/100;
CC.RT = [90 30 30]/100;
CC.main_effect = [45 45 45]/100;
CC.omegaPE = [20 55 90]/100;
CC.ssPE = [30 80 30]/100;
CC.sasPE = [85 80 20]/100;
CC.omega = [80 35 80]/100;
CC.sasminssPE = [90 56 10]/100;
CC.RT = [90 30 30]/100;
CC.main_effect = [45 45 45]/100;
color_map = [CC.ssPE; CC.sasPE; CC.sasminssPE];

 figure('Name', 'ROI as X, Folder as Color');
h = figure('name', 'ROI as X, Folder as Color', 'color', 'w', 'Units', 'inches','Position', [3.8041    4.6082    0.8763    1.7938],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]);
roi_tag = 'conjPE_rDLPFC_001';
clear g
g=gramm('x', result_table.Roi, 'y', length(subset_subj)*result_table_corrected.Mean, 'color', result_table.Folder, 'subset', ismember(result_table.Subindex, subset_subj) & ~ismember(result_table.Folder, folder_flag) & ismember(result_table.Roi, roi_tag));
 g.stat_summary('type', 'sem', 'geom', 'bar', 'dodge', 0.7, 'width', 0.7);%, 'setylim', 'true');
% g.geom_bar('dodge', 0.7, 'width', 0.7, 'stacked', false);%, 'setylim', 'true');
% g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
% g.geom_hline('yintercept', 0);   untitled.fig   
g.axe_property('ylim', [-700 100])
g.set_names('x', 'ROI', 'y', pattern_pref, 'color', 'Volumes')
g.set_order_options( 'color', 0)
g.set_text_options('base_size', 6)
g.no_legend()
g.set_color_options('map', color_map)
g.draw();
rotateXLabels(g.facet_axes_handles,45)
get(g.facet_axes_handles, 'ylim')
g.redraw();
% 
% 
% unique_effects = unique(result_table.Folder);
% for r=1:length(unique_rois)
%     for e=1:length(unique_effects);
%        metric{r}(e,:) = result_table.Mean(ismember(result_table.Roi,unique_rois{r}) & ismember(result_table.Folder,unique_effects{e}) & ismember(result_table.Subindex, subset_subj));
%     end
%     options.figName = unique_rois{r};
%      options.modelNames = unique_effects;
%     
%     VBA_groupBMC(-metric{r}/2, options);
%      
% end

unique_rois = unique(result_table.Roi)
for r=1:length(unique_rois)
roi_flag = unique_rois(r);
result_table.Folder;
folder_flag = subdirs{1};
effect_flag1 = subdirs(3);
effect_flag2 = subdirs(2);
sub_table_1 = result_table.Mean(ismember(result_table.Folder, effect_flag1) & ismember(result_table.Roi,roi_flag) & ismember(result_table.Subindex, subset_subj));%  & ~ismember(result_table.Subindex, [7 9 16 19 32]),:);
sub_table_2 = result_table.Mean(ismember(result_table.Folder, effect_flag2) & ismember(result_table.Roi,roi_flag) & ismember(result_table.Subindex, subset_subj));% &  ~ismember(result_table.Subindex, [7 9 16 19 32]),:);
disp(unique_rois{r})
[h p ci stats] = ttest(sub_table_1, sub_table_2)
% [p h stats] = signtest(sub_table.Median)
end

% plot per ROI per folder
figure('Name', 'ROI as X, Folder as Color');
clear g
g=gramm('x', result_table.Roi, 'y', result_table.Mean, 'color', result_table.Folder);%, 'subset', ~ismember(result_table.Subindex, [7 9 16 19 32]));
%  g.stat_summary('type', 'sem', 'geom', 'bar', 'dodge', 0.7, 'width', 0.7);%, 'setylim', 'true');
g.geom_jitter('dodge', 0.7, 'width', 0.2);%, 'setylim', 'true');
% g.geom_line('dodge', 0.7);%'dodge', 0.7, 'width', 0.2);%, 'setylim', 'true');
% g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
% g.geom_hline('yintercept', 0);      
% g.axe_property('ylim', 'auto')
g.set_names('x', 'ROI', 'y', pattern_pref, 'color', 'Volumes')
g.draw();
rotateXLabels(g.facet_axes_handles,45)
get(g.facet_axes_handles, 'ylim')
g.redraw();

% plot per Folder per ROI
figure('Name', 'Folder as X, ROI as Color');
clear g
g=gramm('color', result_table.Roi, 'y', result_table_corrected.Mean, 'x', result_table.Folder);%, 'subset', ~ismember(result_table.Subindex, [7 9 16 19 32]));
g.stat_summary('type', 'sem', 'geom', 'bar', 'dodge', 0.7, 'width', 0.7);%, 'setylim', 'true');
% g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
% g.geom_hline('yintercept', 0);
g.set_names('x', 'ROI', 'y', pattern_pref, 'color', 'Volumes')
g.draw();
rotateXLabels(g.facet_axes_handles,45)
g.redraw();


% 
unique_rois = unique(result_table.Roi)
for r=1:length(unique_rois)
roi_flag = unique_rois{r};
result_table.Folder;
folder_flag = subdirs{1};
sub_table = result_table(ismember(result_table.Roi,roi_flag) & ismember(result_table.Folder,folder_flag) & ~ismember(result_table.Subindex, [7 9 16 19 32]),:);
disp(unique_rois{r})
[h p ci stats] = ttest(sub_table.Median)
[p h stats] = signtest(sub_table.Median)

end
