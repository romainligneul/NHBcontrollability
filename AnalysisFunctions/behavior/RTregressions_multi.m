function [perf] = RTregressions_multi(ExplPredFile, ModStruct, ModName)
% This function computes the various indicators of prediction performance
% ExplPredFile=[gitdir datadir 'behavior/ExplPred.mat'];
%% load data
load(ExplPredFile)
load('E_Transitions.mat') % it should be in the path

%% process

if exist('plog', 'var')==1 % fmri stress
    
    
    for s=1:size(Log,1)
        
        for m=1:length(ModStruct)
            ModStruct{m}.obsf=str2func(ModName{m}(1:strfind(ModName{m},'_e_')-1));
            
            muX_std=ModStruct{m}.muX{s}(:,u{s}(10,:)==1 & u{s}(1,:)==1);
            
            % reconstruct arbitrator
            assert(strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1'), 'RT regression only implemented for the best-fitting model')
            std_sigomega=VBA_sigmoid(muX_std(49,:), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
            
            RT = u{s}(15, u{s}(10,:)==1 & u{s}(1,:)==1);
            %     RT(RT>15)=NaN;
            remove_RT = RT>nanmean(RT)+3*nanstd(RT);
            mean_RT_global(s,1)=nanmean(RT(~remove_RT));
            
            RT(~remove_RT) = zscore(log(RT(~remove_RT)));
            binomialRT = RT;
            binomialRT(~remove_RT) = double(RT(~remove_RT)>nanmedian(RT(~remove_RT)));
            binomialRT(remove_RT)=NaN;
            RT(remove_RT)=NaN;
            
            % estimate change in matrices
            absPE_SS = 0;
            absPE_SAS = 0;
            
            prev_states = u{s}(2,u{s}(10,:)==1 & u{s}(1,:)==1);
            action = u{s}(4,u{s}(10,:)==1 & u{s}(1,:)==1);
            states = u{s}(11,u{s}(10,:)==1 & u{s}(1,:)==1);
            for t = 2:size(muX_std,2)
                absPE_SAS(end+1,1) = 1-muX_std(ModStruct{m}.options.inF.hs.map.SAS{action(t)}(prev_states(t),states(t)),t-1)';
                absPE_SS(end+1,1) = 1-muX_std(ModStruct{m}.options.inF.hs.map.SS(prev_states(t),states(t)),t-1)';
            end
            
            X1 = zscore([std_sigomega' absPE_SAS absPE_SS]);
            
            %             [modelfit] = glmfit(zscore(X1),RT, 'normal', 'constant', 'on');
            %             perf.betas_RTmod(s,:) = modelfit(2:4);
            
            [modelfit] = robustfit(zscore(X1),RT);
            perf.betas_RTmod(s,:) = modelfit(2:4);
            
            % correlation of PE terms
            r_regs = corrcoef(X1(:,2:3));
            keep_coeff(s,1)=r_regs(2);
            
            
        end
        
    end
    
else % behavior only
    
    % initialize variables
    noise=0;
    
    for s=1:length(v)
        
        %
        std_RT = v{s}.curr_rt(v{s}.curr_type==1 & v{s}.prev_type==1);
        std_state=v{s}.curr_s(v{s}.curr_type==1 & v{s}.prev_type==1);
        std_action=v{s}.curr_c(v{s}.curr_type==1 & v{s}.prev_type==1);
        
        
        % collect/compute useful variables
        prd_cond = v{s}.curr_cond(v{s}.curr_type==2);
        prd_acc = v{s}.curr_acc(v{s}.curr_type==2);
        prd_choice = v{s}.curr_c(v{s}.curr_type==2);
        prd_control = prd_choice(1:2:end)~=prd_choice(2:2:end);
        
        perf.global_acc_normal(s,1)=nanmean(prd_acc);
        
        control_cond = v{s}.curr_control(v{s}.curr_type==2);
        tested_states = v{s}.curr_tested_s(v{s}.curr_type==2);
        tested_actions = v{s}.curr_tested_a(v{s}.curr_type==2);
        for t=1:length(prd_cond)
            treal = eval(tmat{prd_cond(t)}{tested_actions(t)});
            good_resp_prd{s}(t,1) = find(treal(tested_states(t),:));
        end
        resp_choice = v{s}.curr_c(v{s}.curr_type==2);
        control_resp=1-double(resp_choice(1:2:end)==resp_choice(2:2:end)); % 1 = subjective control / 0 lack of subjective control
        
        % detect rule reversal
        cond_change = 0;
        for t = 2:length(prd_cond)
            if prd_cond(t-1)==prd_cond(t);
                cond_change(t)=0;
            elseif prd_cond(t-1)<3 && prd_cond(t)<3
                cond_change(t)=1; % UC->UC
            elseif prd_cond(t-1)>2 && prd_cond(t)>2
                cond_change(t)=2; % C->C
            elseif prd_cond(t-1)<3 && prd_cond(t)>2
                cond_change(t)=3; % UC->C
            elseif prd_cond(t-1)>2 && prd_cond(t)<3
                cond_change(t)=4; % C-UC
            else
                error('Unexpected transition type');
            end
        end
        cond_change_half=cond_change(1:2:end);
        cc_ind=find(cond_change(1:2:end)~=0);
        
        %         % subjective controllability around reversals
        %         pastT=-2;
        %         futureT=3;
        %         revControl=nan(sum(cond_change_half~=0),length(pastT:futureT));
        %         for r=1:size(revControl,1)
        %             if r==1
        %                 actual_start=max([cc_ind(r)+pastT,2]);
        %             else
        %                 actual_start=max([cc_ind(r)+pastT,cc_ind(r-1)]);
        %             end
        %             shift=actual_start-cc_ind(r)-pastT;
        %             if r==size(revControl,1)
        %                 actual_end=min([cc_ind(r)+futureT,length(prd_cond)/2]);
        %             else
        %                 actual_end=min([cc_ind(r)+futureT,cc_ind(r+1)+1]);
        %             end
        %             actual_length=actual_end-actual_start;
        %             revControl(r,1+shift:actual_length+1)=control_resp(shift+actual_start:actual_start+actual_length);
        %         end
        %         for cc=1:4
        %             perf.revControlMeanData(s,cc,:)=nanmean(revControl(cond_change_half(cc_ind)'==cc,:));
        %         end
        %
        % process model-derived variables
        for m=1:length(ModStruct)
            
            sigomega=[];
            
            ModStruct{m}.obsf=str2func(ModName{m}(1:strfind(ModName{m},'_e_')-1));
            
            % add model name to perf structure
            perf.modelNames{m}=ModName{m};
            
            % get raw parameters if needed
            rawphi=[];rawtheta=[];
            if isfield(ModStruct{m},'phiRaw')==0
                for ppp=1:size(ModStruct{m}.thetaFitted,2)
                    if strcmp(func2str(ModStruct{m}.options.inF.param_transform{ppp}),'@(x)VBA_sigmoid(x)')
                        rawtheta(s,ppp) = VBA_sigmoid(ModStruct{m}.thetaFitted(s,ppp),'inverse', true);
                    elseif strcmp(func2str(ModStruct{m}.options.inF.param_transform{ppp}),'@(x)-5+10*VBA_sigmoid(x)')
                        rawtheta(s,ppp)=VBA_sigmoid((ModStruct{m}.thetaFitted(s,ppp)+5)/10,'inverse', true);
                    elseif strcmp(func2str(ModStruct{m}.options.inF.param_transform{ppp}),'@(x)0.5*VBA_sigmoid(x)')
                        rawtheta(s,ppp)=VBA_sigmoid((ModStruct{m}.thetaFitted(s,ppp))*2,'inverse', true);
                    else
                        error();
                    end
                end
                for ppp=1:size(ModStruct{m}.phiFitted,2)
                    if strcmp(func2str(ModStruct{m}.options.inG.param_transform{ppp}),'@(x)VBA_sigmoid(x)')
                        rawphi(s,ppp) = VBA_sigmoid(ModStruct{m}.phiFitted(s,ppp),'inverse', true);
                    elseif strcmp(func2str(ModStruct{m}.options.inG.param_transform{ppp}),'@(x)x')
                        rawphi(s,ppp) = ModStruct{m}.phiFitted(s,ppp);
                    elseif strcmp(func2str(ModStruct{m}.options.inG.param_transform{ppp}),'@(x)exp(x)*5');
                        rawphi(s,ppp)=log(ModStruct{m}.phiFitted(s,ppp)/5);
                    elseif strcmp(func2str(ModStruct{m}.options.inG.param_transform{ppp}),'@(x)-1+2*VBA_sigmoid(x)');
                        rawphi(s,ppp)=VBA_sigmoid((ModStruct{m}.phiFitted(s,ppp)+1)/2,'inverse', true);
                    else
                        error();
                    end
                end
            else
                rawphi=ModStruct{m}.phiRaw;
                rawtheta=ModStruct{m}.thetaRaw;
            end
            
            muX_std=ModStruct{m}.muX{s}(:,v{s}.curr_type==1 & v{s}.prev_type==1);
            
            sigomega=VBA_sigmoid(muX_std(ModStruct{m}.options.inF.hs.map.omega,:), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
            
            % reconstruct arbitrator
            assert(strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1'), 'RT regression only implemented for the best-fitting model')
            sigomega=VBA_sigmoid(ModStruct{m}.muX{s}(49,:), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
            std_sigomega=sigomega(v{s}.curr_type==1 & v{s}.prev_type==1);
            
            % reconstruct prediction errors
            absPE_SAS=0;
            absPE_SS=0;
            for t = 2:size(muX_std,2)
                absPE_SAS(end+1,1) = 1-muX_std(ModStruct{m}.options.inF.hs.map.SAS{std_action(t-1)}(std_state(t-1),std_state(t)),t-1)';
                absPE_SS(end+1,1) = 1-muX_std(ModStruct{m}.options.inF.hs.map.SS(std_state(t-1),std_state(t)),t-1)';
            end
            
            % preprocess RTs
            RT = v{s}.curr_rt(v{s}.curr_type==1 & v{s}.prev_type==1);
            remove_RT = RT>nanmean(RT)+3*nanstd(RT);
            meanRT(s,1)=nanmean(log(RT(~remove_RT)));
            
            RT(~remove_RT) = zscore(log(RT(~remove_RT)));
            RT(~remove_RT) = RT(~remove_RT);
            
            X1 = zscore([std_sigomega' absPE_SAS absPE_SS]); %-repmat(mean([sigomega_std' absPE_SS, absPE_SAS]),length(absPE_SAS),1);% state_repeat]);%, entropy_SS', entropy_SAS'];
            
            %             [modelfit] = fitglm(zscore(X1),RT, 'distribution', 'normal', 'intercept', false);
            %             perf.betas_RTmod(s,:) = modelfit.Coefficients.Estimate;
            [modelfit] = robustfit(zscore(X1),RT);
            perf.betas_RTmod(s,:) = modelfit(2:4);
            
        end
        
        
    end
    
end
