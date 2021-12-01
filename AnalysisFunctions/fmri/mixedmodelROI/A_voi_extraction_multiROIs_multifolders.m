
addpath('/project/3017049.01/Tools/spm12')
addpath('/project/3017049.01/Tools/functions/gramm-master')

%% where are the volumes from which the signal should be extracted
tic

disp('multiROIs multifolders: preprocessing');
basedir = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis_GPPI/';
subdirs = {'InvOmPE_pCC_001_thres/group/'}%,...
%             'DIFF/'};
% 
% basedir = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis_GPPI/';
% subdirs = {'InvOmPE_rTPJ_001/group/'}%,...
% %             'DIFF/'};

% pattern_pref = 'con_PPI_std_omega_mean';
pattern_suff = '.nii';

subset_subj = 1:32;%find(controlACC>median(controlACC));
% subset_subj = find(~ismember(subset_subj, [7 9 16 19 32]));

% gather all files
filenames={};
for d = 1:length(subdirs)
    targetdir = [basedir subdirs{d}];
    dummy = dir(targetdir);
    dummy = {dummy.name}';
    cellsz = 1-cell2mat(cellfun(@isempty,regexpi(dummy,['^' pattern_pref '.*' pattern_suff]),'uni',false));
    filenames{d} = dummy(find(cellsz));
end
    
    
%% where are the ROIs from which the signal should be extracted
% they should all be in the same location

roidir = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/p0001_all/ModelsOfInterest/';
% roidir = '/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_catPE/rois_all/';

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
roinames = roinames(1)
    
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
        
    end
    
    toc;
    
end
        
% plot per ROI per folder
figure('Name', 'ROI as X, Folder as Color');
clear g
g=gramm('x', result_table.Roi, 'y', result_table.Median, 'color', result_table.Folder, 'subset', ~ismember(result_table.Subindex, [7 9 16 19 32]));
g.stat_summary('type', 'sem', 'geom', 'bar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
g.geom_hline('yintercept', 0);      

g.set_names('x', 'ROI', 'y', pattern_pref, 'color', 'Volumes')
g.draw();
rotateXLabels(g.facet_axes_handles,45)
g.redraw();


% plot per Folder per ROI
figure('Name', 'Folder as X, ROI as Color');
clear g
g=gramm('color', result_table.Roi, 'y', result_table.Mean, 'x', result_table.Folder, 'subset', ~ismember(result_table.Subindex, [7 9 16 19 32]));
g.stat_summary('type', 'sem', 'geom', 'bar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
g.stat_summary('type', 'sem', 'geom', 'black_errorbar', 'dodge', 0.7, 'width', 0.7, 'setylim', 'true');
g.geom_hline('yintercept', 0);
g.geom_jitter('dodge', 0.7, 'width', 0.2);%, 'setylim', 'true');
% g.axe_property('ylim',[-0.3 0])
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
sub_table = result_table(ismember(result_table.Roi,roi_flag) & ismember(result_table.Folder,folder_flag) & ~ismember(result_table.Subindex, [7 9 16 19 32]),:)%& ~ismember(result_table.Subindex, [7 9 16 19 32]),:);
disp(unique_rois{r})
[h p ci stats] = ttest(sub_table.Mean)
[p h stats] = signtest(sub_table.Mean)

end
