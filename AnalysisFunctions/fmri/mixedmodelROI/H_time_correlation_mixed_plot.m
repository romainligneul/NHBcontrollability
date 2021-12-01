clear all;
close all;
addpath('/project/3017049.01/Tools/functions/');
anal_name = 'MM_fitlmeREML_Intercept_std_sasPE_std_ssPE_std_RT_std_state_repeat';
 anal_name = 'MM_fitlmeREML_Intercept_std_omegaPE';

mainfolder = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/OmegaPE_median/';
load([mainfolder 'results/' anal_name '.mat'])
figfolder = [mainfolder 'figures/' anal_name '/'];
mkdir(figfolder);

CC.omegaPE = [20 55 90]/100;
CC.omegaPE_low = [30 35 90]/100;
CC.omegaPE_high = [10 75 90]/100;
CC.omegaPE_vhigh = [0 25 90]/100;
CC.omegaPE_vlow = [40 85 90]/100;
CC.ssPE = [30 80 30]/100;
CC.sasPE = [85 80 20]/100;
CC.omega = [80 35 80]/100;

CC.RT = [90 30 30]/100;
CC.main_effect = [45 45 45]/100;

color_map = [CC.main_effect; CC.omegaPE;CC.omega;CC.RT];
% color_map = [CC.main_effect; CC.omega;CC.RT];
%$ color_map = [CC.main_effect; CC.sasPE;CC.ssPE;CC.RT];

% color_map = [CC.main_effect; CC.omega; CC.omegaPE; CC.RT];
time2plot = [-3 12];

for r=1:length(mixed.estimate)
    
    %
    bmat = mixed.estimate{r};
    emat = mixed.se{r};
    
    %
    h = figure('name', mixed.roi_name{r}, 'color', 'w', 'Units', 'inches','Position', [0.5 0.5 1.1 0.95],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]);
    for reg=1:size(bmat,1)
        if ~ismember(reg, [2])
            continue
        end
        x = mixed.time_axis';
        sigfilter = mixed.pValue{r}(reg,:)<0.05;        
        y = bmat(reg,:)';
        dy = emat(reg,:)';  % made-up error values
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.2, 'linestyle','none');
        hold on
        line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01, 'linestyle', ':');
        [cons_ind, cons_length, cons_value] = consecutiveN(sigfilter);
        cons_ind(cons_value==0)=[];         
        cons_length(cons_value==0)=[];
        for ssig = 1:length(cons_ind)
            x = mixed.time_axis(cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
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
%     if r>1
%     set(gca, 'FontName', 'Myriad Pro', 'fontsize', 6, 'xtick', [0 5 10 15], 'ytick', [-0.15 0 0.15], 'linewidth', 0.01);  ylim([-0.15 0.15])  ;
    set(gca, 'FontName', 'Myriad Pro', 'fontsize', 6, 'xtick', [0 5 10 15], 'ytick', [-0.05 0 0.05], 'linewidth', 0.01);  ylim([-0.05 0.05])  ;

    %     else
%     set(gca, 'FontName', 'Myriad Pro', 'fontsize', 6, 'xtick', [0 5 10 15], 'ytick', [-0.25 0 0.25]); ylim([-0.1 0.1]);        
%     end
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
%     dump = get(gca, 'position')
%      set(gca, 'position', [dump(1)-0.02 dump(1)+0.1 dump(3) dump(4)])
%      InSet = get(gca, 'Position');
%     set(gca, 'OuterPosition',[0 0 1 1])
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% axes('Position', [0 0 1 1])

    hold off
    mixed.roi_name{r}(mixed.roi_name{r}=='*')='';
    saveas(h,[figfolder mixed.roi_name{r} '.fig']);
        saveas(h,[figfolder mixed.roi_name{r} '.svg']);
    
%     print(h, [figfolder mixed.roi_name{r}], '-dsvg');
    
end

%         x = mixed.time_axis';
%         sigfilter = mixed.pValue{r}(reg,:)<0.05;
%         xsig = x;
%         xsig(~sigfilter)=NaN;
% %         xsig = mixed.time_axis(sigfilter)';
%         
%         y = bmat(reg,:)';
%         ysig = y;
%         ysig(~sigfilter) = NaN;
% %         ysig = bmat(reg,sigfilter)';
%         dy = emat(reg,:)';  % made-up error values
%         dysig = dy;
%         dysig(~sigfilter) = NaN; %emat(reg,sigfilter)';  % made-up error values  
%         fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.4, 'linestyle','none');
% %         fill([xsig;flipud(xsig)],[ysig-dysig;flipud(ysig+dysig)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.3, 'linestyle','none');

