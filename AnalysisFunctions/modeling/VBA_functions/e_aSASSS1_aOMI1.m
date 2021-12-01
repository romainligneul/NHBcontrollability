function  [fx] = e_aSASSS1_aOMI1(x,P,u,in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameter transformation / should always be performed.

% raw parameters correspond to the x=x transformation.
for pp = 1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end

% report x's
fx = x;

alpha_order1=P(1);
alpha_omega=P(2);

%% update

%%%%% case where we should update transition matrices and controllability

if u(1)==1
    
    % previous state
    prv_s = u(2);
    prv_c = u(4);
    cur_s = u(11);
    
    % compute SS prediction error and update the corresponding row
    SS_pe = alpha_order1*(1-x(in.hs.map.SS(prv_s,cur_s)));
    SS_pe_toO = (1-x(in.hs.map.SS(prv_s,cur_s)));

    % compute AS prediction error and update the corresponding row;
    SAS_pe = alpha_order1*(1-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    SAS_pe_toO = (1-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    
    % update SS
    fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;%*(1-sig(x(in.hs.map.omega)));
    % update unrealized transitions
    nonT = in.hs.map.SS(prv_s,~ismember(1:3,cur_s));
    fx(nonT) = x(nonT)*(1-alpha_order1);%*(1-sig(x(in.hs.map.omega))));
    
    % SAS
    fx(in.hs.map.SAS{prv_c}(prv_s,cur_s)) = x(in.hs.map.SAS{prv_c}(prv_s,cur_s)) + SAS_pe;%*sig(x(in.hs.map.omega));    
    % update unrealized transitions
    nonT = in.hs.map.SAS{prv_c}(prv_s,~ismember(1:3,cur_s));
    fx(nonT) = x(nonT)*(1-alpha_order1);
 
%     % limit amplitude of SAS_PE (trick)
%     if SS_pe_toO<SAS_pe_toO;
%         SAS_pe_toO=SS_pe_toO;
%     end
    
    % compute controllability prediction error and update
    obs_diff = SS_pe_toO -  SAS_pe_toO;
    if obs_diff-x(in.hs.map.omega)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omega*(obs_diff-x(in.hs.map.omega));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omega*(obs_diff-x(in.hs.map.omega));        
    end

%%%%% case predictive trial

elseif u(1)==2 && ~isnan(u(22)) % case predictive trial
    
    prv_s = u(19);
    prv_c = u(20); % action tested
    cur_s = u(21); % choice performed (hypothetical cur_s)
    prv_rew = u(22); % reward or not

    % compute SS prediction error and update the corresponding row
    SS_pe = alpha_order1*(prv_rew-x(in.hs.map.SS(prv_s,cur_s)));
    SS_pe_toO = (prv_rew-x(in.hs.map.SS(prv_s,cur_s)));

    % compute AS prediction error update the corresponding row
    SAS_pe = alpha_order1*(prv_rew-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    SAS_pe_toO = prv_rew-x(in.hs.map.SAS{prv_c}(prv_s,cur_s));   
 
    % update SS
    fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;%*(1-sig(x(in.hs.map.omega)));
    % update unrealized transitions
    nonT = in.hs.map.SS(prv_s,~ismember(1:3,cur_s));
    if prv_rew<=0
        fx(nonT) = x(nonT)-SS_pe/2;%fx(nonT) = x(nonT)*(1-alpha_omega);%%*(1-sig(x(in.hs.map.omega))));
    else
        fx(nonT) = x(nonT)*(1-alpha_order1);%*sig(x(in.hs.map.omega)));    
    end
    
    % SAS - active state
    fx(in.hs.map.SAS{prv_c}(prv_s,cur_s)) = x(in.hs.map.SAS{prv_c}(prv_s,cur_s)) + SAS_pe;%*sig(x(in.hs.map.omega));    
    % update unrealized transition (active state only
    nonT = in.hs.map.SAS{prv_c}(prv_s,~ismember(1:3,cur_s));
    if prv_rew<=0
        fx(nonT) = x(nonT)-SAS_pe/2;%fx(nonT) = x(nonT)*(1-alpha_omega);%%*(1-sig(x(in.hs.map.omega))));
    else
        fx(nonT) = x(nonT)*(1-alpha_order1);%*sig(x(in.hs.map.omega)));    
    end

%     % limit amplitude of SAS_PE (trick)
%     if SS_pe_toO<SAS_pe_toO;
%         SAS_pe_toO=SS_pe_toO;
%     end

    % compute controllability prediction error and update
    obs_diff = SS_pe_toO -  SAS_pe_toO; %/(SS_pe_toO + SAS_pe_toO);
    if obs_diff-x(in.hs.map.omega)<0
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omega*(obs_diff-x(in.hs.map.omega));
    else
        fx(in.hs.map.omega) = x(in.hs.map.omega)+alpha_omega*(obs_diff-x(in.hs.map.omega));        
    end
    
    % compute interaction prediction error
    obs_IntInf = S_pe_toO - AS_pe_toO - SS_pe_toO + SAS_pe_toO; %/(SS_pe_toO + SAS_pe_toO);
    fx(in.hs.map.IntInf) = x(in.hs.map.IntInf)+alpha_IntInf*(obs_diff-x(in.hs.map.IntInf));
    
end

