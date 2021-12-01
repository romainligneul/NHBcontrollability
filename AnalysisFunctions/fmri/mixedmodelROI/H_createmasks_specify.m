% clear all
% spm file: just to define image space
spmfile = '/project/3017049.01/SASSS_fMRI1/LEVEL1/SPM12_GLM30empty_R6RETROICOR_2ROI_HP96/001/beta_0001.nii';

% csv to use of the results (output of third)
% results_coordinates ='/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis/all_nocov/std5xstd_omegaPE^1/Table_InvPE_005_peaks.csv';
% results_coordinates ='/project/3017049.01/SASSS_fMRI1/LEVEL2/SPM12_GLM30sasbis_R6RETROICOR_2ROI_HP96_bis/SS_SAS_intermodel/Table_PEdissociation.csv';
results_coordinates = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/Table_DiffPE_Peaks.csv';
dumfile = importdata(results_coordinates, ',', 1);
coords = dumfile.data(:,end-2:end);
% distances = squareform(pdist(coords, 'euclidean'));
% remove_ROIS=[];
% for d=1:size(distances,1);
%     for dd=d+1:size(distances,1);
%         if distances(d,dd)<15
%             remove_ROIS(end+1) = dd;
%         end
%     end
% end
% coords = [6 -25 29];% coords(find(~ismember(1:size(distances,1),unique(remove_ROIS))),:)

% distances = squareform(pdist(coords, 'euclidean'));


labels = {'Str', 'mPFC'};%dumfile.textdata(2:end,1);
% labels = labels(7); %find(~ismember(1:size(distances,1),unique(remove_ROIS)))) 

% otherwise labels and coordinates (X,Y,Z in columns, roi in row) can be
% defined manually
diam = 6; % specify ROI radius

% output folder where ROIs will be saved
output_ROI_folder = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/ROIimages/DiffPE6mm/';
mkdir(output_ROI_folder);

% add dependencies to path
addpath('/project/3017049.01/Tools/spm12');

% 
curdir = pwd;
for v=1:size(coords,1)
    
    cd(output_ROI_folder)
    create_sphere_image(spmfile,coords(v,:),{[labels{v} '_' num2str(coords(v,1)) '_' num2str(coords(v,2)) '_' num2str(coords(v,3)) '_' num2str(diam) 'mm']},diam);
    cd(pwd)
end
    