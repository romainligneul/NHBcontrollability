function [perf] = prediction_performance(ExplPredFile)
% This function computes the various indicators of prediction performance
% ExplPredFile=[gitdir datadir 'behavior/ExplPred.mat'];
%% load data
load(ExplPredFile)
load('E_Transitions.mat') % it should be in the path

%% process

if exist('plog', 'var')==1 % fmri stress
    
    for s=1:length(plog)
        
        
        % collect/compute useful variables
        alltestedstates=[];
        for r=1:4
            alltestedstates=[alltestedstates Exp{s,r}.testedstates(1:Log{s,r}.predict.log(end,3))];
        end
        tested_states=[];
        ii=1;
        for t=1:size( plog{s},1)
            tested_states(t)=alltestedstates(ii);
            if mod(t,2)==0
                ii=ii+1;
            end
        end
        resp_choice=plog{s}(:,15);
       
        % overall accuracy
        perf.acc(s,1) = mean(plog{s}(:,17));
        
        % accuracy split by control condition
        perf.acc_bycontrol(s,:) = meanbycond(plog{s}(:,17), plog{s}(1:2:end,6)>2,[]);
        
        % diagnostic choices
        perf.diagnostic_exp(s,1)=nanmean((elog{s}(:,8)==1 & elog{s}(:,15)==1) | (elog{s}(:,8)==2 & elog{s}(:,15)==3) | (elog{s}(:,8)==3 & elog{s}(:,15)==2));
        perf.RT(s,1)=nanmean(plog{s}(:,14));
        
        % accuracies split by block
        block_num = cumsum([1; diff(plog{s}(:,5))~=0]);
        perf.acc_byblock_U(s,:) = meanbycond(plog{s}(plog{s}(:,6)<=2,17),block_num(plog{s}(:,6)<=2) ,[] );
        perf.acc_byblock_C(s,:) = meanbycond(plog{s}(plog{s}(:,6)>2,17),block_num(plog{s}(:,6)>2) ,[] );
               
        %%% permuted chance levels - state specific;
        perm_good=[];
        npermut=1000;
        for pr=1:npermut
            perm_good=nan(size(plog{s}(:,16)));
            good_resp_prd=plog{s}(:,16);
            for st=1:3
                permstate = good_resp_prd(tested_states==st);
                permstate = permstate(randperm(length(permstate)));
                perm_good(tested_states==st)=permstate;
            end
            perf.permuted_chance(s,pr)=mean(resp_choice==perm_good);
        end
        
        all_subjcont = resp_choice(1:2:end)~=resp_choice(2:2:end);
        perf.subjcontrolbycond(s,:)=meanbycond(all_subjcont,plog{s}(1:2:end,6),[]);
        
        
        % diagnostic choices
        perf.subjcont(s,1)=nanmean(all_subjcont);

%         
    end
    
else % behavior only
    
    % initialize variables
    perf.acc_byblock_U = nan(length(v),16);
    perf.acc_byblock_C = nan(length(v),16);
    noise=0;
    
    for s=1:length(v)
        
        % collect/compute useful variables
        prd_cond = v{s}.curr_cond(v{s}.curr_type==2);
        prd_acc = v{s}.curr_acc(v{s}.curr_type==2);
        prd_choice = v{s}.curr_c(v{s}.curr_type==2);
        control_cond = v{s}.curr_control(v{s}.curr_type==2);
        tested_states = v{s}.curr_tested_s(v{s}.curr_type==2);
        tested_actions = v{s}.curr_tested_a(v{s}.curr_type==2);
        good_resp_prd=[];
        for t=1:length(prd_cond)
            treal = eval(tmat{prd_cond(t)}{tested_actions(t)});
            good_resp_prd(t,1) = find(treal(tested_states(t),:));
        end
        resp_choice = v{s}.curr_c(v{s}.curr_type==2);
        control_resp=1-double(resp_choice(1:2:end)==resp_choice(2:2:end)); % 1 = subjective control / 0 lack of subjective control
        prd_acc_half=0.5*(prd_acc(1:2:end)+prd_acc(2:2:end)); % mean prediction accuracy over counterfactual pairs
        
        % overall accuracy
        perf.acc(s,1) = mean(v{s}.curr_acc(v{s}.curr_type==2));
        
        % accuracy by control
        perf.acc_bycontrol(s,:) = meanbycond(v{s}.curr_acc, v{s}.curr_control,v{s}.curr_type==2);
         
        % subjective controllability by condition
        all_subjcont = prd_choice(1:2:end)~=prd_choice(2:2:end);
        perf.subjcontrolbycond(s,:)=meanbycond(all_subjcont,prd_cond(1:2:end),[]);
        
        % subj controllability
        perf.subjcont(s,1)=nanmean(all_subjcont);
        
        % "diagnostic" exploration choices
        perf.diagnostic_exp(s,1)=nanmean((v{s}.curr_s(v{s}.curr_type==1)==1 & v{s}.curr_c(v{s}.curr_type==1)==1) | (v{s}.curr_s(v{s}.curr_type==1)==2 & v{s}.curr_c(v{s}.curr_type==1)==3) | (v{s}.curr_s(v{s}.curr_type==1)==3 & v{s}.curr_c(v{s}.curr_type==1)==2));

        
        % permuted chance levels
        npermut=1000;
        for pr=1:npermut
            perm_good=nan(size(good_resp_prd));
            for st=1:3
                permstate = good_resp_prd(tested_states==st);
                permstate = permstate(randperm(length(permstate)));
                perm_good(tested_states==st)=permstate;
            end
            perf.permuted_chance(s,pr)=mean(resp_choice==perm_good');
        end;
        
        % accuracies split by block
        dum = meanbycond(v{s}.curr_acc(v{s}.curr_cond>2), v{s}.block(v{s}.curr_cond>2),v{s}.curr_type(v{s}.curr_cond>2)==2);
        perf.acc_byblock_C(s,1:length(dum)) = dum;
        dum = meanbycond(v{s}.curr_acc(v{s}.curr_cond<=2),v{s}.block(v{s}.curr_cond<=2),v{s}.curr_type(v{s}.curr_cond<=2)==2);
        perf.acc_byblock_U(s,1:length(dum)) = dum;
        
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
        cond_change=cond_change(1:2:end);
        cc_ind=find(cond_change~=0);
        
        % accuracy and subjective controllability around reversals
        pastT=-2;
        futureT=3;
        revAccuracy=nan(sum(cond_change~=0),length(pastT:futureT));
        for r=1:size(revAccuracy,1)
            if r==1
                actual_start=max([cc_ind(r)+pastT,2]);
            else
                actual_start=max([cc_ind(r)+pastT,cc_ind(r-1)]);
            end
            shift=actual_start-cc_ind(r)-pastT;
            if r==size(revAccuracy,1)
                actual_end=min([cc_ind(r)+futureT,length(prd_cond)/2]);
            else
                actual_end=min([cc_ind(r)+futureT,cc_ind(r+1)+1]);
            end
            actual_length=actual_end-actual_start;
            revAccuracy(r,1+shift:actual_length+1)=prd_acc_half(shift+actual_start:actual_start+actual_length);
        end
        for cc=1:4
            perf.revAccMeanData(s,cc,:)=nanmean(revAccuracy(cond_change(cc_ind)'==cc,:));
        end
        
    end
    
    % in some case (early participants), the number of blocks was 16.
    % but we only analyze the first 8 for consistency with the other experiments
    perf.acc_byblock_C(:,9:16)=[];
    perf.acc_byblock_U(:,9:16)=[];
    
    
end

end