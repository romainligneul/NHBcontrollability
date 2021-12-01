function [perf] = prediction_performance(ExplPredFile, ModStruct, ModName)
% This function computes the various indicators of prediction performance
% ExplPredFile=[gitdir datadir 'behavior/ExplPred.mat'];
%% load data
load(ExplPredFile)
load('E_Transitions.mat') % it should be in the path

%% process

if exist('plog', 'var')==1 % fmri stress
    
    for s=1:size(Log,1)
        
        for m=1:length(ModStruct)
            S2A_map = {[1,2],[1,3],[2,3]};

            ModStruct{m}.obsf=str2func(ModName{m}(1:strfind(ModName{m},'_e_')-1));

            perf.F(m,:)=ModStruct{m}.GoF(:,1);
            perf.BIC(m,:)=ModStruct{m}.GoF(:,2);
            perf.AIC(m,:)=ModStruct{m}.GoF(:,3);
            
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
            
            tested_states=u{s}(19,:);
            tested_actions=u{s}(20,:);
            muXprd=ModStruct{m}.muX{s}(:,~isnan(tested_states));
            tested_states(isnan(tested_states))=[];
            tested_actions(isnan(tested_actions))=[];
           
            for t=1:length(tested_states)
                
                trial_u(10)=2;
                trial_u(11)=tested_states(t);
                trial_u(12)=tested_actions(t);
                trial_u(13)=NaN;
                prd_prob(:,t)=ModStruct{m}.obsf(muXprd(:,t),rawphi(s,:)',trial_u,ModStruct{m}.options.inG);
                
                if strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1_H')
                    pSAS=muXprd(ModStruct{m}.options.inF.hs.map.SAS{u{s}(12)}(tested_states(t),:),t);
                    pSAS(pSAS<eps)=eps;
                    pSAS=pSAS/(sum(pSAS));
                    hSAS=0;
                    for ii=1:3
                        hSAS=hSAS-pSAS(ii)*log2(pSAS(ii));
                    end
                    keep_hSAS(t)=hSAS;
                    sigomega(t) = VBA_sigmoid((1.5850-hSAS)/1.5850, 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1_JS')
                    cntf=S2A_map{tested_states(t)};
                    pVect1=muXprd(ModStruct{m}.options.inF.hs.map.SAS{cntf(1)}(tested_states(t),:),t);
                    pVect2=muXprd(ModStruct{m}.options.inF.hs.map.SAS{cntf(2)}(tested_states(t),:),t);
                    pVect1(pVect1<eps)=eps;
                    pVect1=pVect1/(sum(pVect1));
                    pVect2(pVect2<eps)=eps;
                    pVect2=pVect2/(sum(pVect2));
                    logQvect = log2((pVect2+pVect1)/2);
                    JS = .5 * (sum(pVect1.*(log2(pVect1)-logQvect)) + ...
                        sum(pVect2.*(log2(pVect2)-logQvect)));
                    sigomega(t)=VBA_sigmoid(JS, 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                    keepJS(t)=JS;
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1')
                    sigomega(t)=VBA_sigmoid(muXprd(49,t), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM0_SSonly_bDEC1')
                    sigomega(t)=0;
                else strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_bDEC1')
                    sigomega(t)=1;
                end
            end
            
            try
                perf.mean_arbitrator(s,1)=nanmean(VBA_sigmoid(ModStruct{m}.muX{s}(49,:), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3)));
            end%           
            
        end
        
    end
    
else % behavior only
    
    % initialize variables
    noise=0;
    
    for s=1:length(v)
        
        % collect/compute useful variables
        prd_cond = v{s}.curr_cond(v{s}.curr_type==2);
        prd_acc = v{s}.curr_acc(v{s}.curr_type==2);
        prd_choice = v{s}.curr_c(v{s}.curr_type==2);
        prd_control = prd_choice(1:2:end)~=prd_choice(2:2:end);
        
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
        
        % subjective controllability around reversals
        pastT=-2;
        futureT=3;
        revControl=nan(sum(cond_change_half~=0),length(pastT:futureT));
        for r=1:size(revControl,1)
            if r==1
                actual_start=max([cc_ind(r)+pastT,2]);
            else
                actual_start=max([cc_ind(r)+pastT,cc_ind(r-1)]);
            end
            shift=actual_start-cc_ind(r)-pastT;
            if r==size(revControl,1)
                actual_end=min([cc_ind(r)+futureT,length(prd_cond)/2]);
            else
                actual_end=min([cc_ind(r)+futureT,cc_ind(r+1)+1]);
            end
            actual_length=actual_end-actual_start;
            revControl(r,1+shift:actual_length+1)=control_resp(shift+actual_start:actual_start+actual_length);
        end
        for cc=1:4
            perf.revControlMeanData(s,cc,:)=nanmean(revControl(cond_change_half(cc_ind)'==cc,:));
        end
        
        % process model-derived variables
        for m=1:length(ModStruct)
            
            sigomega=[];
            %
            if s==1
                perf.F(m,:)=ModStruct{m}.GoF(:,1);
                perf.BIC(m,:)=ModStruct{m}.GoF(:,2);
                perf.AIC(m,:)=ModStruct{m}.GoF(:,3);
            end
            
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
            
            
            % get hidden states
            muXprd=ModStruct{m}.muX{s}(:,v{s}.curr_type==2);
            S2A_map = {[1,2],[1,3],[2,3]};
            
            % reobtain tested states and actions
            tested_states = v{s}.curr_tested_s(v{s}.curr_type==2);
            tested_actions = v{s}.curr_tested_a(v{s}.curr_type==2);
            
            % recompute choice probabilities and arbitrator value
            for t=1:length(tested_states)
                
                trial_u(10)=2;
                trial_u(11)=tested_states(t);
                trial_u(12)=tested_actions(t);
                trial_u(13)=NaN;
                prd_prob(:,t)=ModStruct{m}.obsf(muXprd(:,t),rawphi(s,:)',trial_u,ModStruct{m}.options.inG);
                
                if strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1_H')
                    pSAS=muXprd(ModStruct{m}.options.inF.hs.map.SAS{u{s}(12)}(tested_states(t),:),t);
                    pSAS(pSAS<eps)=eps;
                    pSAS=pSAS/(sum(pSAS));
                    hSAS=0;
                    for ii=1:3
                        hSAS=hSAS-pSAS(ii)*log2(pSAS(ii));
                    end
                    keep_hSAS(t)=hSAS;
                    sigomega(t) = VBA_sigmoid((1.5850-hSAS)/1.5850, 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1_JS')
                    cntf=S2A_map{tested_states(t)};
                    pVect1=muXprd(ModStruct{m}.options.inF.hs.map.SAS{cntf(1)}(tested_states(t),:),t);
                    pVect2=muXprd(ModStruct{m}.options.inF.hs.map.SAS{cntf(2)}(tested_states(t),:),t);
                    pVect1(pVect1<eps)=eps;
                    pVect1=pVect1/(sum(pVect1));
                    pVect2(pVect2<eps)=eps;
                    pVect2=pVect2/(sum(pVect2));
                    logQvect = log2((pVect2+pVect1)/2);
                    JS = .5 * (sum(pVect1.*(log2(pVect1)-logQvect)) + ...
                        sum(pVect2.*(log2(pVect2)-logQvect)));
                    sigomega(t)=VBA_sigmoid(JS, 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                    keepJS(t)=JS;
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM2_bDEC1')
                    sigomega(t)=VBA_sigmoid(muXprd(49,t), 'slope', ModStruct{m}.phiFitted(s,2), 'center', ModStruct{m}.phiFitted(s,3));
                elseif strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_wOM0_SSonly_bDEC1')
                    sigomega(t)=0;
                else strcmp(func2str(ModStruct{m}.obsf),'o_MBtype2_bDEC1')
                    sigomega(t)=1;
                end
            end
            
            perf.mean_arbitrator(s,1)=nanmean(sigomega);
            
            Cprob = 0*prd_prob(1,:);
            Cprob(1:2:end) = (sum(prd_prob(:,1:2:end).*prd_prob(:,2:2:end)));
            Cprob(2:2:end) = Cprob(1:2:end);
            half_Cprob=Cprob(1:2:end);
            Cprob=Cprob(1:2:end)<=median(Cprob); % median-split
            prd_omega=(sigomega(1:2:end)'+sigomega(2:2:end)')/2;
            cc_ind=find(cond_change(1:2:end)~=0);
            
            revControl=nan(sum(cond_change_half~=0),length(pastT:futureT));
            for r=1:size(revControl,1)
                if r==1
                    actual_start=max([cc_ind(r)+pastT,2]);
                else
                    actual_start=max([cc_ind(r)+pastT,cc_ind(r-1)]);
                end
                shift=actual_start-cc_ind(r)-pastT;
                if r==size(revControl,1)
                    actual_end=min([cc_ind(r)+futureT,length(prd_cond)/2]);
                else
                    actual_end=min([cc_ind(r)+futureT,cc_ind(r+1)+1]);
                end
                actual_length=actual_end-actual_start;
                revControl(r,1+shift:actual_length+1)=Cprob(shift+actual_start:actual_start+actual_length);
            end
            for cc=1:4
                perf.revControlMeanModel{m}(s,cc,:)=nanmean(revControl(cond_change_half(cc_ind)'==cc,:));
                perf.revControlMeanModel{m}(s,cc,:)=nanmean(revControl(cond_change_half(cc_ind)'==cc,:));
            end
            control_y=double(prd_choice(1:2:end)~=prd_choice(2:2:end))';

            % model acc
            model_acc_bin = [];
            model_acc = [];
            modeldata_acc = [];
            modeldata_cont = [];
            tt=0;
            for t=1:length(prd_cond)
                model_guess = find(prd_prob(:,t)==max(prd_prob(:,t)));
                if numel(model_guess)==1
                    model_acc_bin(t,1) = double(model_guess==good_resp_prd{s}(t,1));
                    modeldata_acc(t,1) = double(model_guess==prd_choice(t));
                else
                    model_acc_bin(t,1) = 1/numel(model_guess); % if more than
                    modeldata_acc(t,1) =  1/numel(model_guess); % if more than
                end
                model_acc(t,1) = prd_prob(good_resp_prd{s}(t,1),t);
                if mod(t,2)==0
                    tt=tt+1;
                    model_guess_min1 = find(prd_prob(:,t-1)==max(prd_prob(:,t-1)));
                    if numel(model_guess)==1 && numel(model_guess_min1)==1
                        modeldata_cont(tt,1) = double(control_y(tt)==(half_Cprob(tt)<0.5));%(model_guess~=model_guess_min1));
                    else
                        modeldata_cont(tt,1)=NaN;
                    end
                end
            end
            
            perf.modeldata_acc_mean(s,m) = nanmean(modeldata_acc);
            perf.modeldata_cont_mean(s,m) = nanmean(modeldata_cont);
            
            x=[0:0.2:1.2];
            [Nperbin, ~, binID] = histcounts(prd_omega, x);
            unique(binID);
            for b=1:length(x)
                if sum(binID==b)>0
                    perf.mean_per_binnedOmega(s,b) = nanmean(prd_control(binID==b));
                    perf.mean_per_binnedOmega_model{m}(s,b) = mean(prd_omega(binID==b));
                    
                else
                    perf.mean_per_binnedOmega(s,b) = NaN;
                    perf.mean_per_binnedOmega_model{m}(s,b)=NaN;
                end
                perf.count_per_binnedOmega(s,b) = sum(binID==b);
            end
            
            
        end
        
        
    end
    
end

end