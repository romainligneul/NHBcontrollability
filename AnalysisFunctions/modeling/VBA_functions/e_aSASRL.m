function  [fx] = e_aSASRL(x,P,u,in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameter transformation / should always be performed.

% raw parameters correspond to the x=x transformation.
for pp = 1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end

% report x's
fx = x;

alpha_order1=P(1);

%% update

%%%%% case where we should update transition matrices and controllability

if u(1)==1

%%%%% case predictive trial

elseif u(1)==2  && ~isnan(u(22))% case predictive trial
    
    prv_s = u(19);
    prv_c = u(20); % action tested
    cur_s = u(21); % choice performed (hypothetical cur_s)
    prv_rew = u(22); % reward or not

    % compute AS prediction error update the corresponding row
    SAS_pe = alpha_order1*(prv_rew-x(in.hs.map.SAS{prv_c}(prv_s,cur_s)));
    % actually AS learner...

    % SAS - active state
    fx(in.hs.map.SAS{prv_c}(prv_s,cur_s)) = x(in.hs.map.SAS{prv_c}(prv_s,cur_s)) + SAS_pe;
    fx(in.hs.map.SAS{prv_c}(prv_s,:))=fx(in.hs.map.SAS{prv_c}(prv_s,:))/sum(fx(in.hs.map.SAS{prv_c}(prv_s,:)));

end
% 
if isnan(u(1)) || u(1)==0
    
    fx=in.priors_muX0;
    
end;
