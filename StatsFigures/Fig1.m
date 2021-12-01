%% this script generates the plots corresponding to Fig. 2 of the paper
clear all;close all;

% cosmetic parameters
basefontsize=14;

% directories
gitdir='/project/3017049.01/github_controllability/';

% add required dependencies to path
listpathdir={'StatsFigures/auxfiles/','AnalysisFunctions/behavior','AnalysisFunctions/other','ExternalTools/gramm', 'ExternalTools/MIToolbox'};
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end
% note that the MIToolbox must be compiled by executing:
% ExternalTools/MIToolbox/matlab/CompileMIToolbox.m

run('colorstock_specification.m'); % load the custom color names

%% Panels 1e and 1f
%%% simulate an agent in the explore and predict task

% get transition matrices used in the study
load('auxfiles/behavior/E_Transitions.mat');
noise=0;
for c=1:4
    for a=1:3
        T{c}{a}=eval(tmat{c}{a});
    end
end
asmap={[1 2], [1 3], [2 3]};
% specify simulation 
exploration_levels=[0 0.25 0.5 1];
ruleordering=repmat([1 2 3 4],1,100); % the sequence of conditions does not matter
rulelength=repmat([50 50 50 50],1,100); % the length of each streak does not matter (we only need enough to estimate MI and TE accurately)
changepoints=cumsum(rulelength);
pseudovalues=[0 0.5 1];
for e=1:length(exploration_levels)
    exploration_cutoff=exploration_levels(e);
    rev=1;
    actrule=T{1};
    s(1,e)=1;
    for t=1:changepoints(end)
        if ismember(t,changepoints)
            if t==changepoints(end)
                break
            end
            rev=rev+1;
            actrule=T{ruleordering(rev)};
        end
        % action selection (action availability identical to the actual behavioural task)
        a(t,e)=asmap{s(t,e)}(find(pseudovalues(asmap{s(t,e)})==max(pseudovalues(asmap{s(t,e)}))));
        if rand<exploration_cutoff
            dumind=randi(2);
            a(t,e)=asmap{s(t,e)}(dumind);
        end
        % define next state
        s(t+1,e)=find(actrule{a(t,e)}(s(t,e),:)==max(actrule{a(t,e)}(s(t,e),:)));
        % log rule and exploration level
        rule(t,e)=ruleordering(rev);
        expl(t,e)=exploration_levels(e);
    end
end

% plot 1d (all rules under random exploration)
pr=rule(:,exploration_levels==1);
ps=s(:,exploration_levels==1);
pa=a(:,exploration_levels==1);
for r=1:4
    TE1d(1,r)=cmi(pa(pr==r),ps(find(pr==r)+1),ps(pr==r));
    MI1d(1,r)=mi([pa(pr==r),ps(pr==r)],ps(find(pr==r)+1));
end
x=repmat({'UC1', 'UC2','C1','C2'},2,1);
color=repmat({'MI';'TE'},1,4);
y=[MI1d;TE1d];
figure('Name', 'Panel 1d')
g=gramm('x',x(:),'y',y(:),'color',color(:));
g.geom_bar('dodge',0.7,'width',0.7);
g.set_order_options('x',{'C1','C2','UC1', 'UC2'});
g.axe_property('ylim',[0 1.7]);
g.set_color_options('map',[255, 212, 42;51, 140, 230]./255);
g.set_names('x','','y','TE & MI (bits)');
g.no_legend();
g.draw();
g.results.geom_bar_handle(1).EdgeAlpha=0;
g.results.geom_bar_handle(2).EdgeAlpha=0;

% plot 1e (rule C2 under various exploration)
ps=s(rule(:,1)==4,:);
pa=a(rule(:,1)==4,:);
psn=s(find(rule(:,1)==4)+1,:);
for e=1:4
    TE1e(1,e)=cmi(pa(:,e),psn(:,e),ps(:,e));
    MI1e(1,e)=mi([pa(:,e),ps(:,e)],psn(:,e));
end
x=repmat({'0', '0.25','0.5','1'},2,1);
color=repmat({'MI';'TE'},1,4);
y=[MI1e;TE1e];
figure('Name', 'Panel 1e')
g=gramm('x',x(:),'y',y(:),'color',color(:));
g.geom_bar('dodge',0.7,'width',0.7);
g.set_order_options('x',{'0', '0.25','0.5','1'});
g.axe_property('ylim',[0 1.7]);
g.set_color_options('map',[255, 212, 42;51, 140, 230]./255);
g.set_names('x','','y','TE & MI (bits)');
g.no_legend();
g.draw();
g.results.geom_bar_handle(1).EdgeAlpha=0;
g.results.geom_bar_handle(2).EdgeAlpha=0;


%% remove dependencies from path
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end

%% keep only stats in workspace
clearvars -except TE1d TE1e MI1d MI1e 
