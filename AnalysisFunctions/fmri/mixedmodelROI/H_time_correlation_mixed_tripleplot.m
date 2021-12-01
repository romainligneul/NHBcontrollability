
clear all;
close all;

anal_name = 'MM_fitlmeREML_Intercept_std_ssPE';
mainfolder = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/DiffPE_SNVTAfunc_median/';
m1 = load([mainfolder 'results/' anal_name '.mat']);

anal_name = 'MM_fitlmeREML_Intercept_std_sasPE';
mainfolder = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/DiffPE_SNVTAfunc_median/';
m2 = load([mainfolder 'results/' anal_name '.mat']);

anal_name = 'MM_fitlmeREML_Intercept_diffPE';
mainfolder = '/project/3017049.01/SASSS_fMRI1/VOI_analysis/DiffPE_SNVTAfunc_median/';
m3 = load([mainfolder 'results/' anal_name '.mat']);


figfolder = [mainfolder 'figures/' anal_name '_dual' '/'];
mkdir(figfolder);



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

color_map = [CC.ssPE; CC.sasPE; CC.sasminssPE];%; CC.RT];

% points towards relevant regressors in each models
r1 = 2;
r2 = 2;
r3 = 2;

for r=1:length(m1.mixed.estimate)
    dual.estimate{r,1} = [m1.mixed.estimate{r,1}(r1,:);m2.mixed.estimate{r,1}(r2,:);m3.mixed.estimate{r,1}(r3,:)];
    dual.se{r,1} = [m1.mixed.se{r,1}(r1,:);m2.mixed.se{r,1}(r2,:);m3.mixed.se{r,1}(r3,:)];
    dual.roi_name{r,1} = m1.mixed.roi_name{r,1};
    dual.pValue{r,1} = [m1.mixed.pValue{r,1}(r1,:); m2.mixed.pValue{r,1}(r1,:); m3.mixed.pValue{r,1}(r3,:)];    
%     dual.GoF{r,1} = [mean(m1.mixed.ModelCriterion{1}(:,m1.mixed.time_axis>0 & m1.mixed.time_axis<16),2),...
%         mean(m2.mixed.ModelCriterion{1}(:,m2.mixed.time_axis>0 & m2.mixed.time_axis<16),2),...
%         mean(m3.mixed.ModelCriterion{1}(:,m3.mixed.time_axis>0 & m3.mixed.time_axis<16),2)];
end

dual.time_axis = m1.mixed.time_axis;

    

% color_map = [CC.main_effect; CC.omegaPE; CC.omega; CC.RT];
time2plot = [-3 12];
for r=1:length(dual.estimate)
    
    %
    bmat = dual.estimate{r};
    bmat(3,:)=bmat(3,:);
    emat = dual.se{r};
    pval = dual.pValue{r};
   
%     y = bmat(reg,:)';
%     dy = emat(reg,:)';  % made-up error values

    %
    h = figure('name', dual.roi_name{r}, 'color', 'w', 'Units', 'inches','Position', [0.5 0.5 1.1 0.95],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]);
    
    for reg=1:size(bmat,1)
%         if ~ismember(reg, [1 2])H_time_correlation_mixed_dualplot.m
%             continue
%         end
%         x = mixed.time_axis';
%         sigfilter = [fdr_bh(pval(reg,:), 0.05)];
        sigfilter = [zeros(1,sum(dual.time_axis<=0)) fdr_bh(pval(reg,dual.time_axis>0 & dual.time_axis<20), 0.05) zeros(1,sum(dual.time_axis>=20))];
        x = dual.time_axis';
        y = bmat(reg,:)';
        dy = emat(reg,:)';  % made-up error values
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.9 .9 .9],'facecolor', color_map(reg,:),'facealpha', 0.2, 'linestyle','none');
        hold on
        line(x,y, 'color', color_map(reg,:), 'linewidth', 0.01, 'linestyle', ':');
        [cons_ind, cons_length, cons_value] = consecutiveN(sigfilter);
        cons_ind(cons_value==0)=[];
        cons_length(cons_value==0)=[];
        for ssig = 1:length(cons_ind)
            x = dual.time_axis(cons_ind(ssig):cons_ind(ssig)+cons_length(ssig)-1)';
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
    set(gca, 'FontName', 'Myriad Pro', 'fontsize', 6, 'xtick', [0 5 10 15], 'ytick', [-0.07 0 0.07], 'linewidth', 0.01);  ylim([-0.07 0.07])  ;
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
    dual.roi_name{r}(dual.roi_name{r}=='*')='';
    saveas(h,[figfolder dual.roi_name{r} '.fig']);
    saveas(h,[figfolder dual.roi_name{r} '.svg']);
    
    saveas(h,[figfolder dual.roi_name{r} '.fig']);
    saveas(h,[figfolder dual.roi_name{r} '.svg']);
    
    %     print(h, [figfolder mixed.roi_name{r}], '-dsvg');
%     h = figure('name', dual.roi_name{r}, 'color', 'w', 'Units', 'inches','Position', [0.5 0.5 1.1 0.2],  'PaperUnits', 'inches', 'PaperPositionMode','auto');%, 'position', [50 50 100 80]);
%     
%     bar(dual.GoF{r}(2,:)-dual.GoF{r}(2,3))
end

