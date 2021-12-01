function  [fx] = e_aSASSSSAS1_aOMIntInf1_prior1(x,P,u,in)
%%%% TEMPLATE 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specific comments:
% in first version of the evolution function:
% - one single learning rate for SAS & SS
% - one learning rate for controllability

%% parameter transformation / should always be performed.

% raw parameters correspond to the x=x transformation.
for pp = 1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end

% report x's
fx = x;

% forget
% all_ind = 1:48;
% 
% fx(all_ind) = fx(all_ind)*(1-P(3)) + (0.33+0*fx(all_ind))*P(3);

alpha_order1=mean(P(1));
alpha_orderSS = P(1);
alpha_orderSAS = P(1);

alpha_omegapos=P(2);
alpha_omeganeg=P(2);

% alpha_omegarepeat=P(3);

alpha_IntInf=mean(P(2));

%% update

%%%%% case where we should update transition matrices and controllability

if u(1)==1
    
    % previous state
    prv_s = u(2);
    prv_c = u(4);
    cur_s = u(11);
    
    % compute SS prediction error and update the corresponding row
    SS_pe = alpha_orderSS*(1-x(in.hs.map.SS(prv_s,cur_s)));
    SS_pe_toO = (1-x(in.hs.map.SS(prv_s,cur_s)));

    % compute AS prediction error and update the corresponding row;
    SAS_pe = alpha_orderSAS*(1-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    SAS_pe_toO = (1-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));

    % update SS
    fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;%*(1-sig(x(in.hs.map.omega)));
    % update unrealized transitions
    nonT = in.hs.map.SS(prv_s,~ismember(1:3,[cur_s]));
    fx(nonT) = x(nonT)*(1-alpha_orderSS);%*(1-sig(x(in.hs.map.omega))));
    %
    prior_injection=in.priors_muX0(in.hs.map.SS(prv_s,:));
    prior_injection(prior_injection==0)=P(3);
    prior_injection=prior_injection/sum(prior_injection);
    fx(in.hs.map.SS(prv_s,:))=prior_injection.*fx(in.hs.map.SS(prv_s,:));
    fx(in.hs.map.SS(prv_s,:))=fx(in.hs.map.SS(prv_s,:))/sum(fx(in.hs.map.SS(prv_s,:)));
    
    % update SAS
    fx(in.hs.map.SAS{prv_c}(prv_s,cur_s)) = x(in.hs.map.SAS{prv_c}(prv_s,cur_s)) + SAS_pe;%*sig(x(in.hs.map.omega));    
    % update unrealized transitions
    nonT = in.hs.map.SAS{prv_c}(prv_s,~ismember(1:3,cur_s));
    fx(nonT) = x(nonT)*(1-alpha_orderSAS);
    %
    prior_injection=in.priors_muX0(in.hs.map.SAS{prv_c}(prv_s,:));
    prior_injection(prior_injection==0)=P(3);
    prior_injection=prior_injection/sum(prior_injection);
    fx(in.hs.map.SAS{prv_c}(prv_s,:))=prior_injection.*fx(in.hs.map.SAS{prv_c}(prv_s,:));
    fx(in.hs.map.SAS{prv_c}(prv_s,:))=fx(in.hs.map.SAS{prv_c}(prv_s,:))/sum(fx(in.hs.map.SAS{prv_c}(prv_s,:)));
 
%     % limit amplitude of SAS_PE (trick)
%     if SS_pe_toO<SAS_pe_toO;
%         SAS_pe_toO=SS_pe_toO;
%     end
%     
    % compute controllability prediction error and update
    obs_diff = SS_pe_toO -  SAS_pe_toO;
    if obs_diff-x(in.hs.map.omega)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omeganeg*(obs_diff-x(in.hs.map.omega));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omegapos*(obs_diff-x(in.hs.map.omega));        
    end
    
%%%%% case predictive trial

elseif u(1)==2 && ~isnan(u(22)) % case predictive trial and feedback
    
    prv_s = u(19);
    prv_c = u(20); % action tested
    cur_s = u(21); % choice performed (hypothetical cur_s)
    prv_rew = u(22); % reward or not

    % compute SS prediction error and update the corresponding row
    SS_pe = alpha_orderSS*(prv_rew-x(in.hs.map.SS(prv_s,cur_s)));
    SS_pe_toO = (prv_rew-x(in.hs.map.SS(prv_s,cur_s)));

    % compute AS prediction error update the corresponding row
    SAS_pe = alpha_orderSAS*(prv_rew-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    SAS_pe_toO = prv_rew-x(in.hs.map.SAS{prv_c}(prv_s,cur_s));
    % actually AS learner...
    
    % compute AS prediction error and update the corresponding row;
    AS_pe = alpha_order1*(1-x(in.hs.map.AS(prv_c,cur_s)));
    AS_pe_toO = (1-x(in.hs.map.AS(prv_c,cur_s)));
     % AS
    fx(in.hs.map.AS(prv_c,cur_s)) = x(in.hs.map.AS(prv_c,cur_s)) + AS_pe;%*sig(x(in.hs.map.omega));    
    % update unrealized transitions
    nonT = in.hs.map.AS(prv_c,~ismember(1:3,cur_s));
    fx(nonT) = x(nonT)*(1-alpha_order1);   
    
    % compute AS prediction error and update the corresponding row;
    S_pe = alpha_order1*(1-x(in.hs.map.S(cur_s)));
    S_pe_toO = (1-x(in.hs.map.S(cur_s)));
     % AS
    fx(in.hs.map.S(cur_s)) = x(in.hs.map.S(cur_s)) + S_pe;%*sig(x(in.hs.map.omega));    
    % update unrealized transitions
    nonT = in.hs.map.S(~ismember(1:3,cur_s));
    fx(nonT) = x(nonT)*(1-alpha_order1);
    
    % update based on prior controllability
    % SS
    fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;
    % update unrealized transitions
    nonT = in.hs.map.SS(prv_s,~ismember(1:3,[cur_s]));
    if prv_rew<=0
        fx(nonT) = x(nonT)-SS_pe/2;
    else
        fx(nonT) = x(nonT)*(1-alpha_orderSS);
    end
    %
    prior_injection=in.priors_muX0(in.hs.map.SS(prv_s,:));
    prior_injection(prior_injection==0)=P(3);
    prior_injection=prior_injection/sum(prior_injection);
    fx(in.hs.map.SS(prv_s,:))=prior_injection.*fx(in.hs.map.SS(prv_s,:));
    fx(in.hs.map.SS(prv_s,:))=fx(in.hs.map.SS(prv_s,:))/sum(fx(in.hs.map.SS(prv_s,:)));
    
    % SAS - active state
    fx(in.hs.map.SAS{prv_c}(prv_s,cur_s)) = x(in.hs.map.SAS{prv_c}(prv_s,cur_s)) + SAS_pe;
    % update unrealized transition (active state only
    nonT = in.hs.map.SAS{prv_c}(prv_s,~ismember(1:3,cur_s));
    if prv_rew<=0
        fx(nonT) = x(nonT)-SAS_pe/2;
    else
        fx(nonT) = x(nonT)*(1-alpha_orderSAS);
    end
    
    prior_injection=in.priors_muX0(in.hs.map.SAS{prv_c}(prv_s,:));
    prior_injection(prior_injection==0)=P(3);
    prior_injection=prior_injection/sum(prior_injection);
    fx(in.hs.map.SAS{prv_c}(prv_s,:))=prior_injection.*fx(in.hs.map.SAS{prv_c}(prv_s,:));
    fx(in.hs.map.SAS{prv_c}(prv_s,:))=fx(in.hs.map.SAS{prv_c}(prv_s,:))/sum(fx(in.hs.map.SAS{prv_c}(prv_s,:)));

    % compute controllability prediction error and update
    obs_diff = SS_pe_toO -  SAS_pe_toO;
    if obs_diff-x(in.hs.map.omega)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omeganeg*(obs_diff-x(in.hs.map.omega));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omegapos*(obs_diff-x(in.hs.map.omega));        
    end

end
% 
if isnan(u(1)) || u(1)==0
    
   fx(1:in.hs.map.omega-1)=in.priors_muX0(1:in.hs.map.omega-1);
   fx(in.hs.map.omega+1:end)=in.priors_muX0(in.hs.map.omega+1:end);

end;
