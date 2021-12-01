%% this script generates the plots corresponding to Fig. 5 of the paper
clear all;close all;

% cosmetic parameters
basefontsize=14;

% directories
gitdir='/project/3017049.01/github_controllability/';
datadir='AnonymizedData/';

% add required dependencies to path
listpathdir={'StatsFigures/auxfiles/','AnalysisFunctions/behavior','AnalysisFunctions/other','ExternalTools/gramm', 'ExternalTools/VBA-toolbox', 'ExternalTools/effectsizes_toolbox','ExternalTools/externalfunctions'};
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end
run('colorstock_specification.m'); % load the custom color names

%% Panel 5b
load([gitdir datadir 'stress/Shock.mat'])
% expectancy time course
y=[];
x=repmat([1:6],size(controllable,1),1);
group={'U', 'C'};
color = repmat(group(controllable+1)',1,6);
% y = keep_expectancy;
ii=1;
for i=0:4:20
    y(:,ii) = mean(Shock.expectancy(:,i+1:i+4),2);
    ii=ii+1;
end

figure('Name', 'Panel 5b')
clear g
g = gramm('x', x(:), 'y', y(:), 'color', color(:));
% g.geom_jitter('dodge',0.7, 'width', 0.1)
g.stat_summary('geom', 'area', 'type', 'sem', 'setylim', true);%, 'dodge', 0.7, 'width', 0.7);
g.set_names('y', 'shock expectancy', 'x', 'trials', 'color', '');
% g.geom_hline('yintercept', 0);
g.no_legend();
% g.axe_property('xlim', [0.5 1.5])
g.set_color_options('map',[0.8*ones(1,3); 0.4*ones(1,3)])
g.set_text_options('font', 'Myriad Pro', 'base_size', basefontsize)
% g.set_color_options('map',[CC.omega; CC.omega]);
g.draw();

%% Panel 5c

% aggregate data
stress_mod{1}=load([gitdir datadir 'stress/MODELS/o_MBtype2_wOM2_bDEC1_e_aSASSSSAS1_aOMIntInf1_prior1/fitted_model.mat']);
perfmod_stress=control_related_multi([gitdir datadir 'stress/ExplPred.mat'],stress_mod, {'o_MBtype2_wOM2_bDEC1_e_aSASSSSAS1_aOMIntInf1_prior1'});

y = [stress_mod{1}.phiFitted(:,3) perfmod_stress.mean_arbitrator];
color = repmat(double(controllable)+1,1,size(y,2));

% plot
color_str = {'U', 'C'};
color = color_str(color);
x = {'OmBias','meanArb'};
x=repmat(x,size(y,1),1);
xx=1+y*0;
figure('Name', 'Panel 5c')
clear g
g = gramm('x', xx(:), 'y', y(:), 'color', color(:));
g.facet_grid([], x(:), 'scale', 'independent')
g.geom_jitter('dodge',0.7, 'width', 0.1)
g.stat_summary('geom', 'bar', 'type', 'sem', 'setylim', 'false', 'dodge', 0.7, 'width', 0.7);
g.stat_summary('geom', 'black_errorbar', 'type', 'sem', 'setylim', 'false', 'dodge', 0.7, 'width', 0.7);
g.set_names('y', 'estimates (a.u)', 'x', '', 'color', 'cond', 'column', '');
g.geom_hline('yintercept', 0);
g.no_legend();
g.axe_property('xlim', [0.5 1.5])
g.set_color_options('map',[0.8*ones(1,3); 0.4*ones(1,3)])
g.draw();
for ii=1:length(g.results.stat_summary)
g.results.stat_summary(ii).bar_handle.FaceAlpha = 0.5;
end
g.results.stat_summary(2).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(3).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(4).bar_handle.FaceAlpha = 0.5;

% do the stats

[h stats_stress.bias.p stats_stress.bias.ci stats_stress.bias.stats]=ttest2(stress_mod{1}.phiFitted(controllable==1,3),stress_mod{1}.phiFitted(controllable==0,3));
stats_stress.bias.cohen=computeCohen(stress_mod{1}.phiFitted(controllable==1,3), stress_mod{1}.phiFitted(controllable==0,3),'independent')

[stats_stress.meanarb.p hi stats_stress.meanarb.stats]=ranksum(perfmod_stress.mean_arbitrator(controllable==1),perfmod_stress.mean_arbitrator(controllable==0)) %, 'method', 'approximate');
stats_stress.meanarb.cohen=computeCohen(perfmod_stress.mean_arbitrator(controllable==1), perfmod_stress.mean_arbitrator(controllable==0),'independent')
[ci,bootstat1]=bootci(2000,@mean, perfmod_stress.mean_arbitrator(controllable==1));
[ci,bootstat0]=bootci(2000,@mean, perfmod_stress.mean_arbitrator(controllable==0));
stats_stress.meanarb.ci=prctile(bootstat1-bootstat0,[5 95]);

%% Panel 5d

% aggregate data
stai = demographics(:,7);
y = perfmod_stress.mean_arbitrator; %[mean(mean_acc,2)];
x = stai;

% plot
color_str={'U','C'};
color = repmat(double(controllable)+1,1,size(y,2));
color = color_str(color);
figure('Name', 'Panel 5d')
g = gramm('x', x(:), 'y', y(:), 'color', color(:));
g.stat_glm();
g.geom_point();
g.set_names('y', 'Mean arbitrator', 'x', 'stai', 'color', 'cond');
g.set_color_options('map', [colstock.light_arbitrator; colstock.dark_arbitrator])
g.draw();

% do the stats
stats_beh.staiarb.normal=[1-lillietest(y) 1-lillietest(x)];
[stats_stress.staiarb.r stats_stress.staiarb.p]= corr([y(controllable==1),x(controllable==1)])
[R,stats_stress.staiarb.Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr([y(controllable==1),x(controllable==1)],1,2000,0.95,1,1)
[R,stats_stress.staiarb.Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr([y(controllable==0),x(controllable==0)],1,2000,0.95,1,1)
[R,Z,Zd,stats_stress.staiarb.Zpc,Zsd,Zpt]=bbcorrdiff([y(controllable==0),x(controllable==0) y(controllable==1),x(controllable==1)],1,2000,0.95,1,1)


%% Panel 5e

% aggregate the data
perfmod_stress=RTregressions_multi([gitdir datadir 'stress/ExplPred.mat'],stress_mod, {'o_MBtype2_wOM2_bDEC1_e_aSASSSSAS1_aOMIntInf1_prior1'});
color_str = {'U', 'C'};
y = [perfmod_stress.betas_RTmod];
x = repmat({'Arbitrator', 'deltaSAS', 'deltaSS'},size(y,1),1);
color = repmat(double(controllable)+1,1,size(y,2));
color = color_str(color);

% plot
figure('Name','Panel 5e')
set(0, 'DefaultFigureRenderer', 'opengl');
clear g
g = gramm('x', x(:), 'y', y(:), 'color', color(:));
g.geom_jitter('dodge',0.7, 'width', 0.1)
g.stat_summary('geom', 'bar', 'type', 'sem', 'setylim', 'false', 'dodge', 0.7, 'width', 0.7);
g.stat_summary('geom', 'black_errorbar', 'type', 'sem', 'setylim', 'false', 'dodge', 0.7, 'width', 0.7);
g.geom_hline('yintercept', 0)
g.axe_property('ylim', [-1 1]);
g.set_names('y', 'estimates (a.u)', 'x', '');
g.set_point_options('markers', {'o'}, 'base_size', 8)
g.set_color_options('map', [colstock.light_arbitrator; colstock.dark_arbitrator]);
g.set_order_options('x', {'Arbitrator', 'deltaSS','deltaSAS'})
g.draw();
g.results.stat_summary(1).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(2).bar_handle.FaceAlpha = 0.5;
g.results.stat_summary(3).bar_handle.FaceAlpha = 0.5;

% do the stats;
depvar = perfmod_stress.betas_RTmod(:,2:3);
groupvar = repmat(controllable+1,1,2);
withinvar = repmat([1 2], size(depvar,1),1);
subjvar = [1:54; 1:54]';
sortedmat=sortrows([depvar(:) groupvar(:) withinvar(:)],2);

[stats_stress.RTmod.CIstats stats_stress.RTmod.table]=mes2way(sortedmat(:,1),[sortedmat(:,2) sortedmat(:,3)],'eta2', 'isDep',[0 1],'nBoot',2000);
[h stats_stress.RTSS.p stats_stress.RTSS.ci stats_stress.RTSS.stats]=ttest2(perfmod_stress.betas_RTmod(controllable==1,2),perfmod_stress.betas_RTmod(controllable==0,2));
stats_stress.RTSS.cohen=computeCohen(perfmod_stress.betas_RTmod(controllable==1,2), perfmod_stress.betas_RTmod(controllable==0,2),'independent');
[h stats_stress.RTSAS.p stats_stress.RTSAS.ci stats_stress.RTSAS.stats]=ttest2(perfmod_stress.betas_RTmod(controllable==1,3),perfmod_stress.betas_RTmod(controllable==0,3));
stats_stress.RTSAS.cohen=computeCohen(perfmod_stress.betas_RTmod(controllable==1,3), perfmod_stress.betas_RTmod(controllable==0,3),'independent');


%% other stats
stress_perf=prediction_performance_multi([gitdir datadir 'stress/ExplPred.mat']);

% subjective controllability 
[stats_stress.subjcont.p hi stats_stress.subjcont.stats]=ranksum(stress_perf.subjcont(controllable==1),stress_perf.subjcont(controllable==0)); 
stats_stress.subjcont.cohen=computeCohen(stress_perf.subjcont(controllable==1), stress_perf.subjcont(controllable==0),'independent');

% Acc 
[h stats_stress.acc.p stats_stress.acc.ci stats_stress.acc.stats]=ttest2(stress_perf.acc(controllable==1),stress_perf.acc(controllable==0));
stats_stress.acc.cohen=computeCohen(stress_perf.acc(controllable==1), stress_perf.acc(controllable==0),'independent');

% RT 
[h stats_stress.rt.p stats_stress.rt.ci stats_stress.rt.stats]=ttest2(stress_perf.RT(controllable==1),stress_perf.RT(controllable==0));
stats_stress.rt.cohen=computeCohen(stress_perf.RT(controllable==1), stress_perf.RT(controllable==0),'independent')


%% remove dependencies from path
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end

%% keep only stats in workspace
clearvars -except stats_stress