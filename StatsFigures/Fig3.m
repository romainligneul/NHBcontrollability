%% this script generates the plots corresponding to Fig. 3 of the paper
clear all;close all;

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

% load model space
model_space={'o_MBtype2_bDEC1_e_aSASSSSAS1',...
            'o_MBtype2_wOM2_bDEC1_H_e_aSASSSSAS1_aOMIntInf0_prior1',...
            'o_MBtype2_wOM2_bDEC1_JS_e_aSASSSSAS1_aOMIntInf0_prior1',...
            'o_MBtype2_wOM2_bDEC1_e_aSASSSSAS1_aOMIntInf1_prior1'};
for m=1:length(model_space)
    beh_mod{m}=load([gitdir datadir 'behavior/MODELS/' model_space{m} '/fitted_model.mat']);
    fmri_mod{m}=load([gitdir datadir 'fmri/MODELS/' model_space{m} '/fitted_model.mat']);
    stress_mod{m}=load([gitdir datadir 'stress/MODELS/' model_space{m} '/fitted_model.mat']);
end
     
% compute subjective controllability from data and from model



%% Panel 3a
% aggregate data
modelofinterest=[1:4];
perfmod_beh=control_related_multi([gitdir datadir 'behavior/ExplPred.mat'],beh_mod(modelofinterest), model_space(modelofinterest));
perfmod_stress=control_related_multi([gitdir datadir 'stress/ExplPred.mat'],stress_mod(modelofinterest), model_space(modelofinterest));
perfmod_fmri=control_related_multi([gitdir datadir 'fmri/ExplPred.mat'],fmri_mod(modelofinterest), model_space(modelofinterest));

% plot (the published figure integrate the right middle subplot of each figure
% generated below
concatF=[perfmod_beh.F perfmod_stress.F perfmod_fmri.F];
concatAIC=[perfmod_beh.AIC perfmod_stress.AIC perfmod_fmri.AIC];
concatBIC=[perfmod_beh.BIC perfmod_stress.BIC perfmod_fmri.BIC];
disp(model_space');
options.modelNames={'SAS','H','JS','Omega'}
options.figName='Panel 3a - BIC';
[oBIC pBIC]=VBA_groupBMC(concatBIC,options)
options.figName='Panel 3a - AIC';
[oAIC, pAIC]=VBA_groupBMC(concatAIC,options)
options.figName='Panel 3a - F';
[oF pF]=VBA_groupBMC(concatF,options)

%% Panel 3b
% plot
figure('Name', 'Panel 2b')
x=[0:0.2:1.2];
bar(x, sum(perfmod_beh.count_per_binnedOmega)/sum(sum(perfmod_beh.count_per_binnedOmega)),'facecolor',[0.7 0.7 0.7])
hold on
plot(x,nanmean(perfmod_beh.mean_per_binnedOmega(:,:)),'color',colstock.arbitrator,'linewidth',2);%, 'ro', 'markersize', 2)
errorbar(x,nanmean(perfmod_beh.mean_per_binnedOmega(:,:)),nanstd(perfmod_beh.mean_per_binnedOmega(:,:))./sqrt(sum(~isnan(perfmod_beh.mean_per_binnedOmega))), 'ro','markersize', 2,'color',colstock.arbitrator,'linewidth',2);%, 'ro', 'markersize', 2)
xlim([-0.2 1])
hold off
% 

%% Panel 3c
% aggregate the data
color_map = [colstock.UtoU; colstock.CtoC;colstock.UtoC;colstock.CtoU];
min_ind = -4;
max_ind = 8;
y = cat(4, perfmod_beh.revControlMeanData, perfmod_beh.revControlMeanModel{1},  perfmod_beh.revControlMeanModel{2});
id= y*0;
for i=1:size(y,1); id(i,:,:,:) = i;end;
condchange = y*0; condchange_str = {'UC to UC', 'C to C', 'UC to C', 'C to UC'};
for i=1:size(y,2); condchange(:,i,:,:) = i;end;
condchange_num=condchange;
condchange = condchange_str(condchange);
trialnumber = y*0;
for i=1:size(y,3); trialnumber(:,:,i,:) = i;end;
trialnumber=trialnumber+min_ind/2; trialnumber(trialnumber<=0)=trialnumber(trialnumber<=0)-1;
datatype = y*0; datatype_str = {'data', 'SAS''', 'SS-SAS''-Omega'};
for i=1:size(y,4); datatype(:,:,:,i) = i;end;
datatype = datatype_str(datatype);
currcond = (1+((ismember(condchange_num,[1 3]) & trialnumber<0) | (~ismember(condchange_num,[1 3]) & trialnumber>=0)))/2;

% plot
figure('name', 'Panel 3c', 'position',[379 485 1064 426]);
clear g;
g = gramm('x', trialnumber(:), 'y', y(:), 'color',condchange(:), 'column', datatype(:));%, 'linestyle', condchange(:));
g.stat_summary('geom', 'area', 'type', 'bootci', 'setylim', 'true');
% g.stat_summary('geom', 'line', 'type', 'bootci', 'setylim', 'true');
% g.stat_summary('geom', 'point', 'type', 'bootci', 'setylim', 'true');
g.set_names('x', 'trial (relative to reversal)', 'y', 'subjective controllability', 'column', '', 'color', '');
g.set_text_options('base_size', basefontsize, 'legend_scaling', 1, 'title_scaling', 1, 'big_title_scaling', 1, 'facet_scaling', 1, 'label_scaling', 1);
g.axe_property('xtick', min_ind/2:max_ind/2, 'ylim', [0.0 1.05]);
g.set_order_options('column', [3 1 2], 'color',condchange_str);
g.set_color_options('map',color_map)
g.geom_vline('xintercept', 0.5);
g.geom_hline('yintercept', 2/3);
g.draw();

%% Panel 3d
% aggregate the data
modelofinterest=[4];
perfRT_beh=RTregressions_multi([gitdir datadir 'behavior/ExplPred.mat'],beh_mod(modelofinterest), model_space(modelofinterest));

% plot
y = [perfRT_beh.betas_RTmod];
x = repmat({'Arbitrator', 'deltaSAS', 'deltaSS'},size(y,1),1);
figure('name', 'Panel 3d')%, 'position',[379 485 1064 426]);
set(0, 'DefaultFigureRenderer', 'opengl');
clear g
g = gramm('x', x(:), 'y', y(:), 'color', x(:));
g.geom_jitter('dodge',0.7, 'width', 0.3,'alpha',0.7)
g.stat_summary('geom', 'bar', 'type', 'sem', 'setylim', 'true', 'dodge', 1.5, 'width', 1.5);
g.stat_summary('geom', 'black_errorbar', 'type', 'sem', 'setylim', 'true', 'dodge', 1.5, 'width', 1.5);
% g.stat_boxplot( 'dodge', 0.7, 'width', 0.7);
g.geom_hline('yintercept', 0)
g.axe_property('ylim', [-1.5 2.5]);
g.set_names('y', 'estimates (a.u)', 'x', '');
g.set_color_options('map',[colstock.arbitrator;colstock.SASpe; colstock.SSpe])
g.set_order_options('x', {'Arbitrator', 'deltaSS','deltaSAS'})
g.set_point_options('markers', {'o'}, 'base_size', 5)
g.axe_property('ylim', [-0.5 1]);
g.draw();
g.results.stat_summary(1).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(2).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(3).bar_handle.FaceAlpha = 0.5;

% do the corresponding stats
for reg=1:3
    stats_beh.RT.normal(reg)=1-lillietest(perfRT_beh.betas_RTmod(:,reg));

end
[h stats_beh.RT_3d.p stats_beh.RT_3d.ci stats_beh.RT_3d.stats]=ttest(perfRT_beh.betas_RTmod);
notnormal=find(stats_beh.RT.normal==0);
stats_beh.RT_3d.p_np=nan(1,3);
stats_beh.RT3d.d=nanmean(perfRT_beh.betas_RTmod)./nanstd(perfRT_beh.betas_RTmod);
for reg=notnormal
    [stats_beh.RT_3d.p_np(reg), ~, dumstats]=signtest(perfRT_beh.betas_RTmod(:,reg),0,'method','approximate');
    stats_beh.RT_3d.stats.zval=dumstats.zval;
    stats_beh.RT_3d.stats.sign=dumstats.sign;
    stats_beh.RT_3d.stats.bootci=bootci(2000,@mean,perfRT_beh.betas_RTmod(:,reg));  
end

%% Panel 3e
x=perfRT_beh.betas_RTmod(:,1);
y=perfRT_beh.global_acc_normal;

% plot
figure('Name', 'Panel 3e', 'position', [200 200 300 200])
set(0, 'DefaultFigureRenderer', 'opengl');
clear g
g = gramm('x', x(:), 'y', y(:));%, 'color', color(:));
g.stat_glm();
g.geom_jitter('dodge',0.7, 'width', 0.1, 'alpha', 0.7)
% g.geom_hline('yintercept', 0)
% g.axe_property('ylim', [-1.5 2.5]);
g.set_names('y', 'estimates (a.u)', 'x', '');
g.set_point_options('markers', {'o'}, 'base_size', 5)
g.set_color_options('map', colstock.arbitrator);
g.draw();

% do the stats
stats_beh.acc.normal=1-lillietest(perfRT_beh.global_acc_normal);
stats_beh.RT.normal=1-lillietest(perfRT_beh.betas_RTmod(:,1));

[stats_beh.RTarb.r stats_beh.RTarb.p]=corr(perfRT_beh.betas_RTmod(:,1),perfRT_beh.global_acc_normal,'type','spearman')
[R,stats_beh.RTarb.rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr_rho([perfRT_beh.betas_RTmod(:,1),perfRT_beh.global_acc_normal],1,2000,0.95,1,1)

%% additional statistics

% control prediction accuracy for SAS versus Omega models
[stats_beh.accmodcomp.p h stats_beh.accmodcomp.stats]=signrank(perfmod_beh.modeldata_cont_mean(:,1), perfmod_beh.modeldata_cont_mean(:,4), 'method', 'approximate')
stats_beh.accmodcomp.cohen=computeCohen(perfmod_beh.modeldata_cont_mean(:,1), perfmod_beh.modeldata_cont_mean(:,4),'paired')
stats_beh.accmodcomp.ci=bootci(2000,@mean,perfmod_beh.modeldata_cont_mean(:,4)-perfmod_beh.modeldata_cont_mean(:,2))    

%% remove dependencies from path
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end

%% keep only stats in workspace
clearvars -except stats_beh stats_stress stats_fmri

