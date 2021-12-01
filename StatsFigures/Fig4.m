%% this script generates the plots corresponding to Fig. 4 of the paper
clear all;close all;

% note that this script does not include the code used to plot the SPM
% maps, which are available on neurovault at the following address:
% https://neurovault.org/collections/8810/

% cosmetic parameters
basefontsize=14;

% directories
gitdir='/project/3017049.01/github_controllability/';
datadir='AnonymizedData/';

% add required dependencies to path
listpathdir={'StatsFigures/auxfiles/','AnalysisFunctions/behavior','AnalysisFunctions/other','ExternalTools/gramm', 'ExternalTools/VBA-toolbox','ExternalTools/externalfunctions'};
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end
run('colorstock_specification.m'); % load the custom color names

%% Panel 4a
mixedeffect_folder=[gitdir 'AnonymizedData/fmri/ROI/'];
% load mixed effects models
%
anal_name = 'MM_fitlmeREML_Intercept_std_ssPE';
anal_folder = [mixedeffect_folder 'ConjPE_median/'];
m1 = load([anal_folder 'results/' anal_name '.mat']);
%
anal_name = 'MM_fitlmeREML_Intercept_std_sasPE';
anal_folder = [mixedeffect_folder 'ConjPE_median/'];
m2 = load([anal_folder 'results/' anal_name '.mat']);
%
anal_name = 'MM_fitlmeREML_Intercept_diffPE';
anal_folder = [mixedeffect_folder 'ConjPE_median/'];
m3 = load([anal_folder 'results/' anal_name '.mat']);
%  relevant regressors in each models
r1 = 2;
r2 = 2;
r3 = 2;

% aggregate the data
for r=1:length(m1.mixed.estimate)
    triple.estimate{r,1} = [m1.mixed.estimate{r,1}(r1,:);m2.mixed.estimate{r,1}(r2,:);m3.mixed.estimate{r,1}(r3,:)];
    triple.se{r,1} = [m1.mixed.se{r,1}(r1,:);m2.mixed.se{r,1}(r2,:);m3.mixed.se{r,1}(r3,:)];
    triple.roi_name{r,1} = m1.mixed.roi_name{r,1};
    triple.pValue{r,1} = [m1.mixed.pValue{r,1}(r1,:); m2.mixed.pValue{r,1}(r1,:); m3.mixed.pValue{r,1}(r3,:)];    
end

% do the plot
triple.time_axis = m1.mixed.time_axis;
color_map = [colstock.SSpe; colstock.SASpe; colstock.DIFFpe];
time2plot = [-3 12];
for r=1:length(triple.estimate)
    %
    bmat = triple.estimate{r};
    bmat(3,:)=bmat(3,:);
    emat = triple.se{r};
    pval = triple.pValue{r};
    h = figure('name', ['Panel 4a - ' triple.roi_name{r}], 'color', 'w');%, 'Units', 'inches','Position', [0.5 0.5 1.1 0.95],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]); 
    for reg=1:size(bmat,1)
        sigfilter = [zeros(1,sum(triple.time_axis<=0)) fdr_bh(pval(reg,triple.time_axis>0 & triple.time_axis<20), 0.05) zeros(1,sum(triple.time_axis>=20))];
        x = triple.time_axis';
        y = bmat(reg,:)';
        dy = emat(reg,:)';  % made-up error values
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.2, 'linestyle','none');
        hold on
        line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01, 'linestyle', ':');
        [cons_ind, cons_length, cons_value] = consecutiveN(sigfilter);
        cons_ind(cons_value==0)=[];
        cons_length(cons_value==0)=[];
        for ssig = 1:length(cons_ind)
            x = triple.time_axis(cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            y = bmat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            dy = emat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';  % made-up error values
            fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.3, 'linestyle','none');
            line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01);
        end
        hold on
    end
    xlim(time2plot);
    xlabel('time (s)')
    ylabel('beta (a.u)');
    set(gca, 'FontName', 'Myriad Pro', 'fontsize', basefontsize, 'xtick', [0 5 10 15], 'ytick', [-0.07 0 0.07], 'linewidth', 0.01);  ylim([-0.07 0.07])  ;
    line([time2plot], [0 0],'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    line([0 0], get(gca,'ylim'),'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    xh = get(gca,'xlabel') % handle to the label object
    p = get(xh,'position') % get the current position property
    p(2) = 0.95*p(2) ;        % double the distance,
    % negative values put the label below the axis
    set(xh,'position',p)   % set the new position
    yh = get(gca,'ylabel') % handle to the label object
    p = get(yh,'position') % get the current position property
    p(1) =0.7*p(1) ;        % double the distance,
    % negative values put the label below the axis
    set(yh,'position',p)   % set the new position
    box off
    expandaxes(h)
    drawnow

end
clear bmat triple

%% Panel 4b
mixedeffect_folder=[gitdir 'AnonymizedData/fmri/ROI/'];
% load mixed effects models
%
anal_name = 'MM_fitlmeREML_Intercept_std_ssPE';
anal_folder = [mixedeffect_folder 'DiffPE_median/'];
m1 = load([anal_folder 'results/' anal_name '.mat']);
%
anal_name = 'MM_fitlmeREML_Intercept_std_sasPE';
anal_folder = [mixedeffect_folder 'DiffPE_median/'];
m2 = load([anal_folder 'results/' anal_name '.mat']);
%
anal_name = 'MM_fitlmeREML_Intercept_diffPE';
anal_folder = [mixedeffect_folder 'DiffPE_median/'];
m3 = load([anal_folder 'results/' anal_name '.mat']);
%  relevant regressors in each models
r1 = 2;
r2 = 2;
r3 = 2;

% aggregate the data
for r=1:length(m1.mixed.estimate)
    triple.estimate{r,1} = [m1.mixed.estimate{r,1}(r1,:);m2.mixed.estimate{r,1}(r2,:);m3.mixed.estimate{r,1}(r3,:)];
    triple.se{r,1} = [m1.mixed.se{r,1}(r1,:);m2.mixed.se{r,1}(r2,:);m3.mixed.se{r,1}(r3,:)];
    triple.roi_name{r,1} = m1.mixed.roi_name{r,1};
    triple.pValue{r,1} = [m1.mixed.pValue{r,1}(r1,:); m2.mixed.pValue{r,1}(r1,:); m3.mixed.pValue{r,1}(r3,:)];    
end

% do the plot
triple.time_axis = m1.mixed.time_axis;
color_map = [colstock.SSpe; colstock.SASpe; colstock.DIFFpe];
time2plot = [-3 12];
for r=1:length(triple.estimate)
    %
    bmat = triple.estimate{r};
    bmat(3,:)=bmat(3,:);
    emat = triple.se{r};
    pval = triple.pValue{r};
    h = figure('name', ['Panel 4b - ' triple.roi_name{r}], 'color', 'w');%, 'Units', 'inches','Position', [0.5 0.5 1.1 0.95],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]); 
    for reg=1:size(bmat,1)
        sigfilter = [zeros(1,sum(triple.time_axis<=0)) fdr_bh(pval(reg,triple.time_axis>0 & triple.time_axis<20), 0.05) zeros(1,sum(triple.time_axis>=20))];
        x = triple.time_axis';
        y = bmat(reg,:)';
        dy = emat(reg,:)';  % made-up error values
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.2, 'linestyle','none');
        hold on
        line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01, 'linestyle', ':');
        [cons_ind, cons_length, cons_value] = consecutiveN(sigfilter);
        cons_ind(cons_value==0)=[];
        cons_length(cons_value==0)=[];
        for ssig = 1:length(cons_ind)
            x = triple.time_axis(cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            y = bmat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            dy = emat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';  % made-up error values
            fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.3, 'linestyle','none');
            line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01);
        end
        hold on
    end
    xlim(time2plot);
    xlabel('time (s)')
    ylabel('beta (a.u)');
    set(gca, 'FontName', 'Myriad Pro', 'fontsize', basefontsize, 'xtick', [0 5 10 15], 'ytick', [-0.07 0 0.07], 'linewidth', 0.01);  ylim([-0.07 0.07])  ;
    line([time2plot], [0 0],'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    line([0 0], get(gca,'ylim'),'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    xh = get(gca,'xlabel') % handle to the label object
    p = get(xh,'position') % get the current position property
    p(2) = 0.95*p(2) ;        % double the distance,
    % negative values put the label below the axis
    set(xh,'position',p)   % set the new position
    yh = get(gca,'ylabel') % handle to the label object
    p = get(yh,'position') % get the current position property
    p(1) =0.7*p(1) ;        % double the distance,
    % negative values put the label below the axis
    set(yh,'position',p)   % set the new position
    box off
    expandaxes(h)
    drawnow

end

clear bmat triple

%% Panel 4c
anal_name = 'MM_fitlmeREML_Intercept_std_omegaPE';
anal_folder = [mixedeffect_folder 'OmegaPE_median/'];
load([anal_folder 'results/' anal_name '.mat']);
color_map = [colstock.OMEGApe];

for r=1:length(mixed.estimate)

    bmat = mixed.estimate{r};
    emat = mixed.se{r};
    %
    h = figure('name', ['Panel 4c - ' mixed.roi_name{r}], 'color', 'w') %, 'Units', 'inches','Position', [0.5 0.5 1.1 0.95],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]);
    for reg=1:size(bmat,1)
        if ~ismember(reg, [2])
            continue
        end
        x = mixed.time_axis';
        sigfilter = mixed.pValue{r}(reg,:)<0.05;        
        y = bmat(reg,:)';
        dy = emat(reg,:)';  % made-up error values
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map,'facealpha', 0.2, 'linestyle','none');
        hold on
        line(x,y, 'color', color_map, 'linewidth', 0.01, 'linestyle', ':');
        [cons_ind, cons_length, cons_value] = consecutiveN(sigfilter);
        cons_ind(cons_value==0)=[];         
        cons_length(cons_value==0)=[];
        for ssig = 1:length(cons_ind)
            x = mixed.time_axis(cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            y = bmat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
            dy = emat(reg,cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';  % made-up error values
            fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map,'facealpha', 0.3, 'linestyle','none');
            line(x,y, 'color', color_map, 'linewidth', 0.01);
        end
        hold on
    end
    xlim(time2plot);
    xlabel('time (s)')
    ylabel('beta (a.u)');
    set(gca, 'FontName', 'Myriad Pro', 'fontsize', basefontsize, 'xtick', [0 5 10 15], 'ytick', [-0.05 0 0.05], 'linewidth', 0.01);  ylim([-0.05 0.05])  ;
    line([time2plot], [0 0],'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    line([0 0], get(gca,'ylim'),'linestyle', ':', 'color', 'k', 'linewidth', 0.01)
    xh = get(gca,'xlabel') % handle to the label object
    p = get(xh,'position') % get the current position property
    p(2) = 0.95*p(2) ;        % double the distance,
    % negative values put the label below the axis
    set(xh,'position',p)   % set the new position
    yh = get(gca,'ylabel') % handle to the label object
    p = get(yh,'position') % get the current position property
    p(1) =0.7*p(1) ;        % double the distance,
    set(yh,'position',p)   % set the new position
    box off
    expandaxes(h)
     drawnow

    
end

%% remove dependencies from path
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end

%% keep only stats in workspace
clearvars -except
