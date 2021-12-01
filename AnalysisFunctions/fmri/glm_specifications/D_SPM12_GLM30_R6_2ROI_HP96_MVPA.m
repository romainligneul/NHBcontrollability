%%%%%%%%%%%%%%%%%%%%% SPECIFICATIONS OF THE ANALYSIS %%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION
% GLM 3 uses the computational model
% high pass filter is relaxed to 360s to allow the capture of some omega
% variations
clear all;
F.name = 'SPM12_GLM30_R6_2ROI_HP96_MVPA'; % name of the GLM - first level

%% preliminaries
if strcmp(computer, 'GLNXA64')
else 
end
run('BEHAVIOR/all_subject_info.m');
load('BEHAVIOR/modeling_seq/o_MBtype2_wOM2_bDEC1_max_nobound_e_aSASSSSAS1_aOMIntInf1_nobound_08-Oct-2019_1/fitted_model.mat');
load('generic_out');

%% Global definition

F.subjnames = B.subjnames;
F.subjnames = sort(F.subjnames); % alphabetical order

%%%%%%% FIRST LEVEL

F.iterations = 0; % 0 = no iteration / 1 = iterations
F.runid = [1 2 3 4]; % runs to be analyzed
F.prprcpref = 'wau'; % prefix of epidata
F.prprcsuf = '.nii'; % suffix of epidata (.img or .nii)
F.mvtpref = 'R6_2ROI_';     % prefix of the motion txt file simplest: rp_
F.mvtsuff = '.mat'; % simplest .txt
F.mvtind = 2;
F.mask = '';%cellstr(spm_select('FPList', '/home/control/romlig/SASSS_fMRI1/LEVEL0', ['.*brainmask_binarized'])); % mask used for analysis (optional )
F.brainmask = '';
F.implicit_threshold = 0.3;
F.hpf = 96; % high pass filter period
F.hrf_derivs = [0 0]; % 1 or 0 [temporal dispersion]

% recap nuisance regressors
% {1} = 'R6_' 
% {2} = ['R6_2ROI_'
% {3} = ['R6RETROICOR_'
% {4} = ['R6RETROICOR_2ROI_' 
% {5} = ['R12_'
% {6} = ['R12_2ROI_'
% {7} = ['R12RETROICOR_'
% {8} = ['R12RETROICOR_2ROI_'
% {9} = ['R12_2ROI_' 
% {10} = ['R24_2ROI_' 
% {11} = ['R24RETROICOR_'
% {12} = ['R24RETROICOR_2ROI_' 
        
F.units = 'secs'; % ('secs' or 'scans')        %       
F.RT = 0.7; % in secs ('secs' or scans)
F.fmri_t = 64; % number of slices (cermep = 26)
F.fmri_t0 = 2; % microtime onset / first slice (cermep = 13)
F.FIR.do = 0;
% if exist('estimate_firstlev_step', 'var')
% F.doest = estimate_firstlev_step;
% else
%     F.doest = 1;
% end;

F.contrastleft = {};%, 'QUEST_HIT_curiosity^1', 'QUEST_HIT_curiosity^1', 'QUEST_CR_curiosity^1', 'RESP_HIT_surprise^1','RESP_HIT_surprise^1', 'RESP_CR_surprise^1'}; %'seen', 'unseen', 'seen', 'unseen'};
F.contrastright = {};%, 'QUEST_CR_curiosity^1', 'QUEST_MISS_curiosity^1', 'QUEST_MISS_curiosity^1', 'RESP_CR_surprise^1', 'RESP_MISS_surprise^1', 'RESP_MISS_surprise^1'};% 'unknown_quest', 'unknownquest_curiosity^1 '};%'hashtag', 'hashtag', 'unseen', 'seen'};

F.estfunc = 'spm_spm'; % or spm_spm_Bayes or spm_spm_quickest
% F.check_imgsuf =['.*ResMS.img'];
% F.check_roidir = '';
% F.check_roisuf = ['.*img'];

%%%%% COMMON INFO

F.mpath = '/project/3017049.01/SASSS_fMRI1/';
F.prprcpath = 'fMRI_NII/';
F.prprcspec = 'LEVEL0/preprocess_relocate_23-Jul-2019_32s.mat';
F.nuisancepath = 'LEVEL0/final_regressors/';
F.behavpath = 'LEVEL1/converted_logfiles/';
F.anaspecs =  'LEVEL1/GLM_specifications/';
F.firstlevpath = [F.mpath 'LEVEL1/' F.name '/'];
F.secondlevpath = [F.mpath 'LEVEL2/' F.name '/']; % all these path are subpaths from mpath
F.spmpath =  '/project/3017049.01/Tools/spm12/'; % full spm path
F.homefunc = '/project/3017049.01/SASSS_fMRI1/Pipelines/functions'; % full path to homemade functions.
F.vbapath = '/project/3017049.01/Tools/VBA-toolbox/';
F.marsbarpath = []; %'toolbox/marsbar/'; % puzzling with spm8 estimation
% if exist([F.firstlevpath 'RUN_MAT/'], 'dir') ==0; mkdir([F.firstlevpath 'RUN_MAT/']);end;
% if exist([F.firstlevpath 'BEHAV_ANALYSIS/'], 'dir') ==0; mkdir([F.firstlevpath 'BEHAV_ANALYSIS/']);end;

load([F.mpath F.prprcspec], 'I');
addpath(genpath(F.vbapath))

%% header stuff
shead = { 't' 'L.streak(r)' 'r' 'E.cond(r)' 'noise1' 'noise2', 'noise3', 'state' 'snext' 'smax' 'violation' 'side' 'resp_side' 'resp_RT' 'resp_choice' 'warning' 'post_jitter' 'trial_onset' 'resp_onset' 'fade_onset' 'fade_offset'}';
phead = { 't' 'tt' 'ttt' 'L.streak(r)' 'r' 'E.cond(r)' 'noise1', 'noise2', 'noise3', 'p','state','hyp_LR' 'resp_side' 'resp_RT' 'resp_choice' 'correct_resp' 'resp_acc' 'feedback' 'warning' 'post_jitter' 'trial_onset' 'resp_onset' 'post_onset' 'post_offset'}';
display('%%%%%% standard header / shead %%%%%%')
shead = strcat(num2str([1:numel(shead)]'), '-', shead)
display('%%%%%% predictive header / phead %%%%%%')
phead = strcat(num2str([1:numel(phead)]'), '-', phead)


%% Do the job
% try rmdir(F.firstlevpath, 's');end
summed_r = zeros(4);

% add mi to path
omega_ind = 49;
intInf_ind = 52;

for s = 1:32;
    
    sdir = [F.firstlevpath sprintf('%03d',s) '/'];mkdir(sdir);
        
    for r = 1:4
        
        dummat = [];
        clear pmod onsets names orth durations
        
        %%% build model-based regressors
        % omega is directly extracted from hidden states
        % it is therefore as long as the 'cond' 
        block_ind = [find(isnan(out{s}.u(1,:)) | out{s}.u(1,:)==0) length(out{s}.u(1,:))+1];
        block_idx = block_ind(r):block_ind(r+1);
        omegaraw = posterior{s}.muX(omega_ind,block_ind(r):block_ind(r+1)-1);
        omega = posterior{s}.muX(omega_ind,block_ind(r):block_ind(r+1)-1);
        intInf = posterior{s}.muX(intInf_ind,block_ind(r):block_ind(r+1)-1);
        
        omega_prv = [0 posterior{s}.muX(omega_ind,block_ind(r):block_ind(r+1)-2)];
        
        % decision omega
        P_obsf = posterior{s}.muPhi;
        in_obsf = out{s}.options.inG;
        u_obsf = out{s}.u(:,block_ind(r):block_ind(r+1)-1);
        x_obsf = posterior{s}.muX(:,block_ind(r):block_ind(r+1)-1);
        f_obsf = out{s}.options.g_fname;
        % 
        sigomega = VBA_sigmoid(omegaraw, 'slope', in_obsf.param_transform{2}(P_obsf(2)), 'center', in_obsf.param_transform{3}(P_obsf(3)));       
        
        omegaPE = [0 diff(omegaraw)];
        
        SSpe= 0;
        SASpe = 0;
        SSalpha = thetaFitted(s,1);
        SASalpha = thetaFitted(s,1);
        SSexp = thetaFitted(s,2);
        SASexp = thetaFitted(s,2);
        state_repeat=0;
        t = 0;
        for tt = block_ind(r):block_ind(r+1)-1
            t = t+1;
            if out{s}.u(1,tt)==1 && tt~=block_ind(r)
                % previous state
                prv_s = out{s}.u(2,tt);
                prv_c = out{s}.u(4,tt);
                cur_s = out{s}.u(11,tt);
                state_repeat(t)=double(prv_s==cur_s);
                SSpe(t) = (1-posterior{s}.muX(in_obsf.hs.map.SS(prv_s,cur_s),tt-1));
                SASpe(t) = (1-posterior{s}.muX(in_obsf.hs.map.SAS{prv_c}(prv_s,cur_s),tt-1));
            else
                SSpe(t) = NaN;
                SASpe(t) = NaN;
                state_repeat(t)=NaN;
            end  
        end
        
        cond_ind = out{s}.u(10,block_ind(r):block_ind(r+1)-1);        
        cond_ind(1:8:end)=3;
        state = out{s}.u(10,block_ind(r):block_ind(r+1)-1);
        [choice dum]=find(out{s}.y(:,block_ind(r):block_ind(r+1)-1));
        muX = x_obsf;
        
        % for the other model variables, we need to perform other
        % computations; it could be done by using the u matrix too, but we adopt
        % a different approach based on logfile info.
        load([B.mdir 'task_DATA/' B.SSAS{r}{s,1}],'L', 'E');
        side_std = L.explore.log(:,13);
        
        %%%%%%%%%%%% define all possible onsets
        %
        T.std_onset = L.explore.log(:,18)-L.start_time; 
        R.run_durations(s,r)=T.std_onset(end)/60;
        R.run_trials(s,r) = numel(T.std_onset);
        %
        T.warn_onset = T.std_onset(find(L.explore.log(:,16)));
        % 
        T.stdresp_onset = L.explore.log(:,19)-L.start_time;
        %
        T.prd_onset = L.predict.log(:,21)-L.start_time; 
        T.prdfb_onset = L.predict.log(L.predict.log(:,18)==1,24)-1-L.start_time; 
        % 
        T.prdresp_onset = L.predict.log(:,22)-L.start_time; 
        
        %%%%%% categorical splits
        
        %%% feedbacks
        prd_fb = [];
        for t = 1:size(L.predict.log,1)
            if L.predict.log(t,18)==1
                if L.predict.log(t,17)==1
                    prd_fb(t,1) = 1;
                else
                    prd_fb(t,1) = -1;
                end
            else
                prd_fb(t,1) = 0;
            end
        end
                   
        T.prdfb_onset_pos = L.predict.log(prd_fb==1,24)-1-L.start_time; 
        R.fb_pos(s,r) = numel(T.prdfb_onset_pos);
        T.prdfb_onset_neg = L.predict.log(prd_fb==-1,24)-1-L.start_time; 
        R.fb_neg(s,r) = numel(T.prdfb_onset_neg);
        T.prdfb_onset_neutral = L.predict.log(prd_fb==0,24)-1-L.start_time;
        T.prdfb_onset = L.predict.log(:,24)-1-L.start_time;
        
        %R.fb_neg(s,r) = numel(T.prdfb_onset_neg);
                
        
        %%% standard trials by devL.explore.log(:,11)<2iants & condition for categorical analysis
        deviant = 0;
        for t = 2:size(L.explore.log,1)
            deviant(t,1) = double(L.explore.log(t,8)~= L.explore.log(t-1,10));
        end

        %%% determine the control representations in predictive trials
        prd_control = [];
        ppt = 0;
        for t = 1:2:size(L.predict.log)
            prd_control(t:t+1) = (L.predict.log(t,15)==L.predict.log(t+1,15));
            ppt=ppt+1;
            prdpair_control(ppt,1) = (L.predict.log(t,15)==L.predict.log(t+1,15));
        end
        
        R.deviant_freq(s,r) = nanmean(deviant);       
        R.deviant_freq_C(s,r) = nanmean(deviant(L.explore.log(:,4)>2));       
        R.deviant_freq_UC(s,r) = nanmean(deviant(L.explore.log(:,4)<3));       
        % 
        normal_C_ind = L.explore.log(:,11)<2 & deviant(:,1)==0 & L.explore.log(:,4)>2;
        normal_UC_ind = L.explore.log(:,11)<2 & deviant(:,1)==0 & L.explore.log(:,4)<3;
        deviant_C_ind = L.explore.log(:,11)<2 & deviant(:,1)==1 & L.explore.log(:,4)>2;
        deviant_UC_ind = L.explore.log(:,11)<2 & deviant(:,1)==1 & L.explore.log(:,4)<3;
        
        T.std_onset5_normal_C = T.std_onset(normal_C_ind);
        T.std_onset5_normal_UC = T.std_onset(normal_UC_ind);
        T.std_onset5_deviant_C = T.std_onset(deviant_C_ind);
        T.std_onset5_deviant_UC = T.std_onset(deviant_UC_ind);
        T.std_onset1 = T.std_onset(1:6:end);
       
            
        %%% pred trial by condition
        T.prd_onset_C = T.prd_onset(L.predict.log(:,6)>2);
        T.prd_onset_UC = T.prd_onset(L.predict.log(:,6)<3);
            
        %%% all motor resp
        T.motor = [T.stdresp_onset; T.prdresp_onset];
        
        %%%%%%%% Define parametric regressors
        %%% RT
        std_RT = log(L.explore.log(:,14));
        prd_RT = log(L.predict.log(:,14));
        std_cond_ind = cond_ind(cond_ind~=2);
        std1_RT = std_RT(std_cond_ind==3);
        std_RT = std_RT(std_cond_ind==1);

        std_omega = omega(cond_ind<2)';
        
        
        std_omega_prv = omega_prv(cond_ind<2)';

        std_intInf = intInf(cond_ind<2)';
        
        std1_omega = omega(cond_ind==3)';

        std_SSpe = SSpe(cond_ind<2);
        std_SASpe = SASpe(cond_ind<2);
        std_state_repeat = state_repeat(cond_ind<2);

        std_omegaPE = omegaPE(cond_ind<2)';
      
        prd_omega = omega(cond_ind==2);
        prd_sigomega = sigomega(cond_ind==2);

        prd_intInf = intInf(cond_ind==2)';

        state = L.explore.log(:,8);
        std_muX = muX(:,cond_ind<2);
        
%             

        n=0;

        pmod(1).name{2} = 'prd_feedback';
        pmod(1).param{2} = zscore(prd_fb');
        pmod(1).poly{2} = 1;        
        
        %
        allRT = [log(L.explore.log(:,14)); prd_RT];
        [sorted_motor_onset sort_ind] = sort(T.motor);
        sorted_RT = allRT(sort_ind);
        
        pmod(2).name{1} = 'all_RT';
        pmod(2).param{1} = zscore(sorted_RT);
        pmod(2).poly{1} = 1;      
        
        %%%%%%%%% Create RUN_MAT file

        %%% names
        names{1} = 'prd';       
        names{2} = 'motor';
        
        %%% onsets
        onsets{1} = T.prd_onset;
        onsets{2} = sorted_motor_onset;
        
        %%% orthogonalizations
        orth{1} = false;
        orth{2} = false;
        
        %%% durations
        durations(1:length(names)) = {0};
        
        nmbl = numel(T.std_onset)/6;
        
        n=length(names);
%         prdpair_control = L.predict.log(1:2:end,6)<3;
        
        n=n+1;
        if prdpair_control(1)==0
            names{n} = [sprintf('stdC_%i_%0.2d_pos',r, 1)];
%             pmod(n).name{1} = [sprintf('std_order%0.2d_pos', 1)];
        else
            names{n} = [sprintf('stdU_%i_%0.2d_neg',r, 1)];
%             pmod(n).name{1} = [sprintf('std_order%0.2d_neg', 1)];
            
        end
        
        onsets{n} = T.std_onset(1:6);
        orth{n} = false;

        for mbl = 2:nmbl
            n=n+1;
            if prdpair_control(mbl)==0 && prdpair_control(mbl-1)==0
                names{n} = [sprintf('stdC_%i_%0.2d_sta',r, mbl)];
%                 pmod(n).name{1} = [sprintf('std_order%0.2d_sta', mbl)];
            elseif prdpair_control(mbl)==0 && prdpair_control(mbl-1)==1
                names{n} = [sprintf('stdC_%i_%0.2d_pos',r, mbl)];
%                 pmod(n).name{1} = [sprintf('std_order%0.2d_pos', mbl)];
            elseif prdpair_control(mbl)==1 && prdpair_control(mbl-1)==1
                names{n} = [sprintf('stdU_%i_%0.2d_sta',r, mbl)];
%                 pmod(n).name{1} = [sprintf('std_order%0.2d_sta', mbl)];
            else
                names{n} = [sprintf('stdU_%i_%0.2d_neg',r, mbl)];
%                 pmod(n).name{1} = [sprintf('std_order%0.2d_neg', mbl)];                
            end    
            onsets{n} = T.std_onset(6*(mbl-1)+1:6*mbl);
            orth{n} = false;
%             pmod(n).param{1} = [-5 -3 -1 1 3 5];
%             pmod(n).poly{1} = 1;
        end           
            
        durations(1:length(names)) = {0};
        
%         dummat = [];
%         for ppp = 1:length(pmod(1).param)
%             dummat = [dummat,pmod(1).param{ppp}];
%         end
%         dumr = corrcoef(dummat);
% %         summed_r = summed_r+dumr;
        
       % names{10} = 'warn';
       % names{11} = 'motor';
       
        %%% specify orthogonalization per condition

        
        %%% durations
        durations(1:length(names)) = {0};
%         durations(7) = {std1_RT'};
%         durations(1) = {std_RT'};
%         durations(2) = {prd_RT'};
        

       % onsets{10} = T.warn_onset;
       % onsets{11} = T.motor;
       
%        if numel(onsets{1})~=numel(pmod(1).param{1})
%            error('problem with regressor length')
%        end
%        if numel(onsets{2})~=numel(pmod(2).param{1})
%            error('problem with regressor length')
%        end
% 
%         %%% screen and remove empty regressors
%         exclude_reg = [];
%         for o = 1:length(onsets)
%             if isempty(onsets{o});
%                 exclude_reg(end+1)=o;
%                 disp(['subject ' num2str(s) ': ' names{o} ' missing in run ' num2str(r) '!'])
%             end
%         end
%         onsets(exclude_reg)=[];names(exclude_reg)=[];durations(exclude_reg)=[];
%         orth(exclude_reg) = [];
%         try
%             pmod(exclude_reg) = [];
%         end
%         
        %%% save GLM
        save([sdir sprintf('%03d',s) '_runmat_b' num2str(r) '.mat'], 'names', 'onsets', 'durations', 'orth', 'pmod');
%         warning('pmod excluded from mat file!')
        F.run_mat{s}{r} = [sdir sprintf('%03d',s) '_runmat_b' num2str(r) '.mat'];

    end
end

% summed_r/(32*4)

save([F.firstlevpath 'infos_FIPRT.mat'], 'F', 'I', 'R', 'T');
