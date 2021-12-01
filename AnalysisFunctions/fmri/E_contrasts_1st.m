%% script used to compute first-level contrasts

clear all;close all;
%%%%%%%                          MAIN                               %%%%%%%
% This script has to be launched AFTER the GLMs ran COMPLETELY.

% analysis name should refer to the XXX.m of the model
analysis_name = 'SPM12_R6RETROICOR_2ROI_HP96_prior1_Diffunc';
%%%%%%%                     SPM12_GLM30abssigned_R6RETROICOR_2ROI_HP96_bis_rep3 CODE                          %%%%%%%

% load parameters  

base_directory = pwd;
load([base_directory '/LEVEL1/' analysis_name '/infos_FIPRT.mat']);
addpath(F.spmpath);

% add relevant paths 
addpath(genpath(F.homefunc));
addpath(genpath('/home/common/matlab/fieldtrip/qsub'))
%addpath(C.anaspecs);
 
% execute_contrasts_2016(F)
execute_contrasts_2016(F)
