%% this script generates the plots corresponding to Fig. 2 of the paper
clear all;close all;

% cosmetic parameters
basefontsize=14;

% directories
gitdir='/project/3017049.01/github_controllability/';
datadir='AnonymizedData/';

% add required dependencies to path
listpathdir={'StatsFigures/auxfiles/','AnalysisFunctions/behavior','AnalysisFunctions/other','ExternalTools/gramm'};
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end
run('colorstock_specification.m'); % load the custom color names

% load the behavioral data
beh_perf=prediction_performance_multi([gitdir datadir 'behavior/ExplPred.mat']);
fmri_perf=prediction_performance_multi([gitdir datadir 'fmri/ExplPred.mat']);
stress_perf=prediction_performance_multi([gitdir datadir 'stress/ExplPred.mat']);

% load the WM data
load([gitdir datadir 'behavior/WM_Q.mat'],'WM');

%% Panel 2a
% aggregate the data 
color_map = [colstock.C; colstock.U];
y=[beh_perf.acc_byblock_C; beh_perf.acc_byblock_U;fmri_perf.acc_byblock_C; fmri_perf.acc_byblock_U;stress_perf.acc_byblock_C; stress_perf.acc_byblock_U];
column = [repmat({'behavior'}, size(beh_perf.acc_byblock_C,1)*2,8);repmat({'mri'}, size(fmri_perf.acc_byblock_C,1)*2,8);repmat({'stress'}, size(stress_perf.acc_byblock_C,1)*2,8) ];
x=repmat([1:8], size(y,1), 1);
color = [repmat({'C'}, size(beh_perf.acc_byblock_C,1),8); repmat({'U'}, size(beh_perf.acc_byblock_C,1),8);repmat({'C'}, size(fmri_perf.acc_byblock_C,1),8); repmat({'U'}, size(fmri_perf.acc_byblock_C,1),8);repmat({'C'}, size(stress_perf.acc_byblock_C,1),8); repmat({'U'}, size(stress_perf.acc_byblock_C,1),8)];
% plot the data
figure('Name', 'Panel 2c')
g = gramm('x',x(:), 'y', y(:), 'color', color(:), 'column', column(:));
g.stat_summary('geom', 'area', 'type', 'sem', 'setylim', true);
g.set_color_options('map', color_map);g.geom_hline('yintercept', 1/3);
g.axe_property('ylim', [0 1]);
g.no_legend()
g.set_names('x', 'blocks','y', 'accuracy', 'color', '', 'column', '');
g.draw();

%%% do the corresponding stats

% behavior
stats_beh.acc.normal=1-lillietest(beh_perf.acc-mean(beh_perf.permuted_chance,2));
[h stats_beh.acc.p stats_beh.acc.ci stats_beh.acc.stats]=ttest(beh_perf.acc-mean(beh_perf.permuted_chance,2));
stats_beh.acc.cohen=mean(beh_perf.acc-mean(beh_perf.permuted_chance,2))/std(beh_perf.acc-mean(beh_perf.permuted_chance,2))

y = [beh_perf.acc_byblock_U(:,1:6) beh_perf.acc_byblock_C(:,1:6)]; % most subjects only experienced 6 blocks per control condition in the behavioral experiment so we computed stats using 6 blocks
y(sum(isnan(y),2)>0,:)=[];                                         % two subjects who experienced less than 6 blocks (task aborted to their demand) are removed from this analysis
subj= repmat([1:size(y,1)]', 1, size(y,2));
time_factor = repmat([1:6 1:6],size(y,1), 1);
rule_factor = repmat([ones(1,6) 2*ones(1,6)], size(y,1),1);
stats_beh.rm_anova.cc=rm_anova2(y(:), subj(:), rule_factor(:), time_factor(:), {'rule', 'time'})

% fmri
stats_fmri.acc.normal=1-lillietest(fmri_perf.acc-mean(fmri_perf.permuted_chance,2));
[h stats_fmri.acc.p stats_fmri.acc.ci stats_fmri.acc.stats]=ttest(fmri_perf.acc-mean(fmri_perf.permuted_chance,2));
stats_fmri.acc.cohen=mean(fmri_perf.acc-mean(fmri_perf.permuted_chance,2))/std(fmri_perf.acc-mean(fmri_perf.permuted_chance,2))
y = [fmri_perf.acc_byblock_U fmri_perf.acc_byblock_C];
y(sum(isnan(y),2)>0,:)=[];
subj= repmat([1:size(y,1)]', 1, size(y,2));
time_factor = repmat([1:8 1:8],size(y,1), 1);
rule_factor = repmat([ones(1,8) 2*ones(1,8)], size(y,1),1);
stats_fmri.acc.rm_anova=rm_anova2(y(:), subj(:), rule_factor(:), time_factor(:), {'rule', 'time'});

% stress
stats_stress.global_acc_normal=1-lillietest(stress_perf.acc-mean(stress_perf.permuted_chance,2));
[h stats_stress.acc.p stats_stress.acc.ci stats_stress.acc.stats]=ttest(stress_perf.acc-mean(stress_perf.permuted_chance,2));
stats_stress.acc.cohen=mean(stress_perf.acc-mean(stress_perf.permuted_chance,2))/std(stress_perf.acc-mean(stress_perf.permuted_chance,2))

%
y = [stress_perf.acc_byblock_U stress_perf.acc_byblock_C];
y(sum(isnan(y),2)>0,:)=[];
subj= repmat([1:size(y,1)]', 1, size(y,2));
time_factor = repmat([1:8 1:8],size(y,1), 1);
rule_factor = repmat([ones(1,8) 2*ones(1,8)], size(y,1),1);
stats_stress.acc.rm_anova=rm_anova2(y(:), subj(:), rule_factor(:), time_factor(:), {'rule', 'time'});

%% Panel 2b
color_map = [colstock.UtoU; colstock.CtoC;colstock.UtoC;colstock.CtoU];
% aggregate the data
min_ind = -4;
max_ind = 8;
y = beh_perf.revAccMeanData;
id= y*0;
for i=1:size(y,1); id(i,:,:) = i;end;
condchange = y*0; condchange_str = {'UC to UC', 'C to C', 'UC to C', 'C to UC'};
for i=1:size(y,2); condchange(:,i,:) = i;end;
condchange_num=condchange;
condchange = condchange_str(condchange);
trialnumber = y*0;
for i=1:size(y,3); trialnumber(:,:,i) = i;end;
trialnumber=trialnumber+min_ind/2; trialnumber(trialnumber<=0)=trialnumber(trialnumber<=0)-1;
currcond = (1+((ismember(condchange_num,[1 3]) & trialnumber<0) | (~ismember(condchange_num,[1 3]) & trialnumber>=0)))/2;
% plot
figure('name', 'Panel 2b');%, 'position', [600 721 427 222]);
clear g;
g = gramm('x', trialnumber(:), 'y', y(:), 'color',condchange(:));%, 'linestyle', condchange(:));
g.stat_summary('geom', 'area', 'type', 'bootci', 'setylim', 'true');
% g.stat_summary('geom', 'line', 'type', 'bootci', 'setylim', 'true');
% g.stat_summary('geom', 'point', 'type', 'bootci', 'setylim', 'true');
g.set_names('x', 'trial (relative to reversal)', 'y', 'subjective controllability', 'column', '', 'color', '');
g.set_text_options('base_size', basefontsize, 'legend_scaling', 1, 'title_scaling', 1, 'big_title_scaling', 1, 'facet_scaling', 1, 'label_scaling', 1);
g.axe_property('xtick', min_ind/2:max_ind/2, 'ylim', [0.0 1.05]);
g.set_color_options('map',color_map)
g.geom_vline('xintercept', 0.5);
g.geom_hline('yintercept', 1/3);
g.geom_hline('yintercept', mean2(beh_perf.permuted_chance), 'style', 'k:');
g.set_order_options('color', condchange_str);
% g.no_legend();
g.draw();

%%% do the corresponding stats

% behavior
for cc=1:4
    stats_beh.firstpair.normal(cc,1)=1-lillietest(squeeze(beh_perf.revAccMeanData(:,cc,3))-mean(beh_perf.permuted_chance,2));
    [h stats_beh.firstpair.p(cc,1) stats_beh.firstpair.ci(cc,:) stats_beh.firstpair.stats{cc,1}]=ttest(squeeze(beh_perf.revAccMeanData(:,cc,3))-mean(beh_perf.permuted_chance,2));
    stats_beh.firstpair.cohen(cc,1)=nanmean(squeeze(beh_perf.revAccMeanData(:,cc,3))-nanmean(beh_perf.permuted_chance,2))/nanstd(squeeze(beh_perf.revAccMeanData(:,cc,3))-nanmean(beh_perf.permuted_chance,2))
end
accminuschance=nanmean(squeeze(beh_perf.revAccMeanData(:,:,3)),2)-mean(beh_perf.permuted_chance,2)
stats_beh.firstpair_merged.normal=1-lillietest(accminuschance);
[h stats_beh.firstpair_merged.p stats_beh.firstpair_merged.ci stats_beh.firstpair_merged.stats]=ttest(accminuschance);
stats_beh.firstpair_merged.cohen=nanmean(accminuschance)/nanstd(accminuschance)

%% Panel 2c
% aggregate the data
x = [WM.dprime_bycond(:,3) WM.dprime_bycond(:,3)];% FULL.WM.dprime_bycond(:,3)];
y = [beh_perf.acc_bycontrol];%SD AD];%FULL.Q.mat(:,end-1:end)];
color_map = [colstock.U; colstock.C;];
color = repmat({'U', 'C'}, 50,1);
% plot
figure('Name','Panel 2c')
g=gramm('x', x(:), 'y', y(:), 'color', color(:), 'subset', x(:)~=0);
g.set_color_options('map', color_map);
g.set_text_options('base_size', basefontsize, 'legend_scaling', 1, 'title_scaling', 1, 'big_title_scaling', 1, 'facet_scaling', 1, 'label_scaling', 1);
g.set_names('x', 'd'' (2-back WM)', 'y', 'predictive accuracy', 'color', '');
g.set_order_options('color', {'U', 'C'});
g.stat_glm();
g.geom_point();
g.draw();
% do the corresponding stats
[r p] = corr([x(x(:,1)~=0,1) y(x(:,1)~=0,:)], 'rows', 'pairwise', 'type', 'spearman');
stats_beh.WM_accU_r=r(1,2);
stats_beh.WM_accU_p=p(1,2);
stats_beh.WM_accC_r=r(1,3);
stats_beh.WM_accC_p=p(1,3);


[r p] = corr([x(x(:,1)~=0,1) y(x(:,1)~=0,:)], 'rows', 'pairwise', 'type', 'spearman');
[R,Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr([x(x(:,1)~=0,1) y(x(:,1)~=0,1)],1,2000,0.95,1,1)
[R,Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr([x(x(:,1)~=0,2) y(x(:,1)~=0,1)],1,2000,0.95,1,1)


%% additional stats: subjective controllability across controllable rules

% behaviour
subjcont_Crules=beh_perf.subjcontrolbycond(:,4)-beh_perf.subjcontrolbycond(:,3);
stats_beh.subjcont_Crules.normal=1-lillietest(subjcont_Crules);
[h stats_beh.subjcont_Crules.p stats_beh.subjcont_Crules.ci stats_beh.subjcont_Crules.stats]=ttest(subjcont_Crules);
stats_beh.subjcont_Crules.cohen=nanmean(subjcont_Crules)/nanstd(subjcont_Crules)

% fmri
subjcont_Crules=fmri_perf.subjcontrolbycond(:,4)-fmri_perf.subjcontrolbycond(:,3);
stats_fmri.subjcont_Crules.normal=1-lillietest(subjcont_Crules);
[h stats_fmri.subjcont_Crules.p stats_fmri.subjcont_Crules.ci stats_fmri.subjcont_Crules.stats]=ttest(subjcont_Crules);
stats_fmri.subjcont_Crules.cohen=nanmean(subjcont_Crules)/nanstd(subjcont_Crules)

% stress
subjcont_Crules=stress_perf.subjcontrolbycond(:,4)-stress_perf.subjcontrolbycond(:,3);
stats_stress.subjcont_Crules.normal=1-lillietest(subjcont_Crules);
[h stats_stress.subjcont_Crules.p stats_stress.subjcont_Crules.ci stats_stress.subjcont_Crules.stats]=ttest(subjcont_Crules);
stats_stress.subjcont_Crules.cohen=nanmean(subjcont_Crules)/nanstd(subjcont_Crules)

%% diagnostic exploration

diagnostic_exp=beh_perf.diagnostic_exp-0.5;
stats_beh.diagnostic_exp.normal=1-lillietest(diagnostic_exp);
[h stats_beh.diagnostic_exp.p stats_beh.diagnostic_exp.ci stats_beh.diagnostic_exp.stats]=ttest(diagnostic_exp);
stats_beh.diagnostic_exp.cohen=nanmean(diagnostic_exp)/nanstd(diagnostic_exp);

diagnostic_exp=fmri_perf.diagnostic_exp-0.5;
stats_fmri.diagnostic_exp.normal=1-lillietest(diagnostic_exp);
[h stats_fmri.diagnostic_exp.p stats_fmri.diagnostic_exp.ci stats_fmri.diagnostic_exp.stats]=ttest(diagnostic_exp);
stats_fmri.diagnostic_exp.cohen=nanmean(diagnostic_exp)/nanstd(diagnostic_exp);

diagnostic_exp=stress_perf.diagnostic_exp-0.5;
stats_stress.diagnostic_exp.normal=1-lillietest(diagnostic_exp);
[h stats_stress.diagnostic_exp.p stats_stress.diagnostic_exp.ci stats_stress.diagnostic_exp.stats]=ttest(diagnostic_exp);
stats_stress.diagnostic_exp.cohen=nanmean(diagnostic_exp)/nanstd(diagnostic_exp);


%% remove dependencies from path
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end

%% keep only stats in workspace
clearvars -except stats_beh stats_stress stats_fmri

