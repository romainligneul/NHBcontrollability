%% script used to launch model fit
% in order to run this script you need to download the anonymized data
% from the Donders repository
% note that model fitting takes very long if not parallelized. The qsub
% functions provided by fieldtrip were used for this purpose (by default,
% parallel processing is deactivated)
clear all; close all;
%% general specifications
use_dccn_cluster=0;
gitdir='/project/3017049.01/github_controllability/';
experiment='fmri';
experiment_priors='behavior';
outputname='MODELS_RERUN';
% note to inform prior parameter distribution obtained in another experiment,
% the corresponding model must have been fitted in that experiment and
% regrouped using B_regroup_fitdata

%% model specifications

% evolution function
evof=@e_aSASSS1_aOM1_prior1;

% observation function
obsf=@o_MBtype2_wOM2_bDEC1;

% set of transformation functions for parameters (do not touch)
Traw = @(x) x; Tsig = @(x) VBA_sigmoid(x); Texp = @exp;
Texp5 = @(x) exp(x)*5; Texp10 = @(x) exp(x)*10;
TsigMin1to1 = @(x) -1+2*VBA_sigmoid(x);
TsigMin0to025 = @(x) 0.25*VBA_sigmoid(x);
TsigMin0to01 = @(x) 0.1*VBA_sigmoid(x);
TsigMin0to05 = @(x) 0.5*VBA_sigmoid(x);

% evolution parameters
options.priors.muTheta = [0 0 0]';
options.priors.SigmaTheta = 3*eye(size(options.priors.muTheta,1)); % variance of 3 approximates uniform on [0,1] interval after sigmoid transformation
options.inF.param_transform={Tsig,Tsig,Tsig}; % transformations (inF stores all info related to evolution function)

% evolution parameters
options.priors.muPhi = [0 0 0]';
options.priors.SigmaPhi = 3*eye(size(options.priors.muPhi,1));
options.priors.SigmaPhi(1,1)=10;
options.priors.SigmaPhi(2,2)=10;
options.inG.param_transform={Traw,Texp5,TsigMin1to1};

%% paths
% add required dependencies to path
listpathdir={'StatsFigures/auxfiles/','AnalysisFunctions/modeling','AnalysisFunctions/other','ExternalTools/VBA-toolbox', 'ExternalTools/qsub_fromfieldtrip'};
for d=1:length(listpathdir)
    addpath(genpath([gitdir listpathdir{d}]));
end
% output folder (where model fits will be stored)
% subfolders are created automatically for each model fitted
main_outfolder = [gitdir 'AnonymizedData/' experiment '/' outputname '/'];
mkdir(main_outfolder);

%% load u, y and else
load([gitdir 'AnonymizedData/' experiment '/ExplPred.mat'])
load('E_Transitions.mat')
%% % priors over hidden states and other information required for the fit (constant accross models)
% dimensions of the model
dim.n_theta=size(options.priors.muTheta,1);
dim.n_phi=size(options.priors.muPhi,1);
dim.n = 52;

% mappings of hidden states (most mappings are not used)
hs.map.SS = [1 2 3; 4 5 6; 7 8 9];    % states to states transitions.
hs.map.SAS{1} = [10 11 12; 13 14 15; 16 17 18]; % state 1 to outcome-action
hs.map.SAS{2} = [19 20 21; 22 23 24; 25 26 27]; % state 2 to outcome-action
hs.map.SAS{3} = [28 29 30; 31 32 33; 34 35 36]; % state 3 to outcome-action
hs.map.AS = [37 38 39; 40 41 42; 43 44 45]; % state to action
hs.map.S = [46 47 48]; % state to action
hs.map.omega = [49]; % controllability estimate.
hs.map.SS_variance = [50];
hs.map.SAS_variance = [51];
hs.map.IntInf = 52;

% initial values of hidden states
hs.val.AS = ones(size(hs.map.AS))*0.33;
hs.val.S = ones(size(hs.map.S))*0.33;
noise=0;
hs.val.SS = (eval(tmat{1}{1})+eval(tmat{2}{1}))/2;
options.priors.muX0(hs.map.SS) = hs.val.SS;
for i = 1:3
    hs.val.SAS{i} = (eval(tmat{3}{i})+eval(tmat{4}{i}))/2;
    options.priors.muX0(hs.map.SAS{i}) = hs.val.SAS{i};
end
%
options.priors.muX0 = options.priors.muX0';
options.priors.muX0(hs.map.omega) = 0;
options.priors.muX0(hs.map.IntInf) = 0;
options.priors.muX0(hs.map.SAS_variance) = 0;
options.priors.muX0(hs.map.SS_variance) = 0;
options.inF.priors_muX0 = options.priors.muX0; % log prior in inF for reset between blocks
options.inF.hs=hs;
options.inG.hs=hs;

%% subfolder corresponding to model
output_dir = [main_outfolder '/' char(obsf) '_' char(evof) '/'];
mkdir(output_dir);

%% load informative priors if needed
if ~isempty(experiment_priors)
    priordata=load([gitdir 'AnonymizedData/' experiment_priors '/MODELS/' char(obsf) '_' char(evof) '/' 'fitted_model.mat']);
    clear rawtheta
    clear rawphi
    if isfield(priordata,'rawphi')==0 % tedious recalculation of raw parameter values if not available
        for s=1:size(priordata.phiFitted,1)
            for ppp=1:size(priordata.thetaFitted,2)
                if strcmp(func2str(options.inF.param_transform{ppp}),'@(x)VBA_sigmoid(x)')
                    rawtheta(s,ppp) = VBA_sigmoid(priordata.thetaFitted(s,ppp),'inverse', true);
                elseif strcmp(func2str(options.inF.param_transform{ppp}),'@(x)-5+10*VBA_sigmoid(x)')
                    rawtheta(s,ppp) = VBA_sigmoid((priordata.thetaFitted(s,ppp)+5)/10,'inverse', true);
                else
                    error();
                end
            end
            for ppp=1:size(priordata.phiFitted,2)
                if strcmp(func2str(options.inG.param_transform{ppp}),'@(x)x')
                    rawphi(s,ppp) = priordata.phiFitted(s,ppp);
                elseif strcmp(func2str(options.inG.param_transform{ppp}),'@(x)exp(x)*5');
                    rawphi(s,ppp)=log(priordata.phiFitted(s,ppp)/5);
                elseif strcmp(func2str(options.inG.param_transform{ppp}),'@(x)-1+2*VBA_sigmoid(x)');
                    rawphi(s,ppp)=VBA_sigmoid((priordata.phiFitted(s,ppp)+1)/2,'inverse', true);
                else
                    error();
                end
            end
        end
    else
        rawphi=priordata.rawphi;
        rawtheta=priordata.rawphi;
    end
    options.priors.muPhi = mean(rawphi)';
    options.priors.muTheta = mean(rawtheta)';
    options.priors.SigmaPhi = eye(size(rawphi,2));
    options.priors.SigmaPhi(options.priors.SigmaPhi==1) = std(rawphi).^2;
    options.priors.SigmaTheta = eye(size(rawtheta,2));
    options.priors.SigmaTheta(options.priors.SigmaTheta==1) = std(rawtheta).^2;
end

%% options of VBA toolbox 
options.DisplayWin = 1; % display window?
options.updateX0 = 0; % fixed starting values
options.sources.type = 2;
options.sources.out = 1:3;

for s = 1:length(u)
    options.isYout = zeros(3,size(u{s},2));
    options.isYout(1:3,u{s}(10,:)<2) = 1;
    %
    ss = ss+1;
    output_file = [output_dir sprintf('%0.3i.mat', s)];
    
    if use_dccn_cluster==1
        qsubfeval('qsub_VBA', y{s}, u{s}, evof, obsf, dim, options, output_file,'memreq', 4*(1024^3), 'timreq', 1900, 'display', 'no')
    else
        qsub_VBA(y{s}, u{s}, evof, obsf, dim, options, output_file);
    end
    % native fit call: VBA_NLStateSpaceModel( y{s}, u{s}, evof, obsf, dim, options);
    
end

