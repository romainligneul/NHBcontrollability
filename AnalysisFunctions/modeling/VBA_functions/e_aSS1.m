function  [fx] = e_aSS1(x,P,u,in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw parameters transform 
for pp = 1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end

% report x's
fx = x;

alpha_order1=P(1);


%% update

%%%%% case where we should update transition matrices and controllability

if u(1)==1
    
    % previous state
    prv_s = u(2);
    prv_c = u(4);
    cur_s = u(11);
    
%     % compute SS prediction error and update the corresponding row
     SS_pe = alpha_order1*(1-x(in.hs.map.SS(prv_s,cur_s)));
     SS_pe_toO = (1-x(in.hs.map.SS(prv_s,cur_s)));

%     update SS
     fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;%*(1-sig(x(in.hs.map.omega)));
%     % update unrealized transitions
     nonT = in.hs.map.SS(prv_s,~ismember(1:3,cur_s));
     fx(nonT) = x(nonT)*(1-alpha_order1);%*(1-sig(x(in.hs.map.omega))));

%%%%% case predictive trial

elseif u(1)==2  && ~isnan(u(22))% case predictive trial
    
    prv_s = u(19);
    prv_c = u(20); % action tested
    cur_s = u(21); % choice performed (hypothetical cur_s)
    prv_rew = u(22); % reward or not

%     % compute SS prediction error and update the corresponding row
     SS_pe = alpha_order1*(prv_rew-x(in.hs.map.SS(prv_s,cur_s)));
     SS_pe_toO = (prv_rew-x(in.hs.map.SS(prv_s,cur_s)));

     % update SS
     fx(in.hs.map.SS(prv_s,cur_s)) = x(in.hs.map.SS(prv_s,cur_s)) + SS_pe;%*(1-sig(x(in.hs.map.omega)));
     % update unrealized transitions
     nonT = in.hs.map.SS(prv_s,~ismember(1:3,cur_s));
     if prv_rew<=0
        fx(nonT) = x(nonT)-SS_pe/2;%fx(nonT) = x(nonT)*(1-alpha_omega);%%*(1-sig(x(in.hs.map.omega))));
     else
         fx(nonT) = x(nonT)*(1-alpha_order1);%*sig(x(in.hs.map.omega)));    
     end

end
% 
if isnan(u(1)) || u(1)==0
    
    fx=in.priors_muX0;
    
end;
