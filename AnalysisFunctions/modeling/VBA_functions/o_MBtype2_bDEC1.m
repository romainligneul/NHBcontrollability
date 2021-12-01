function  [gx] = o_MBtype2_bDEC1(x,P,u,in)

%% parameter transformation / should always be performed.
for pp =1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end;


if u(10) <= 1  %%%%%%%%%% EXPLORATORY TRIAL
    gx = ones(3,1)*1/3; % is ignored anyway
        
else          %%%%%%%%%% PREDICTION TRIAL
    cur_s = u(11);
    cur_a = u(12);
    cur_c = u(13);
    
    % SAS arbitration
    mixedSAS = x(in.hs.map.SAS{cur_a}(cur_s,:));
    
    % final prob
    gx = flex_softmax_single(mixedSAS, P(1));
        
end

%
%% softmax subfunction
function p = flex_softmax_single(values, consistency)
    ff = @(x) exp(x*consistency);
    denom = ff(values);
    p=0*denom;
    for i = 1:length(values)
      p(i,1) = ff(values(i))./sum(denom);
    end
end

function p = flex_softmax_double(values, consistency)
    if size(values,1)~=2; error('''values'' vector is not formatted correctly');end
    fff = @(x,y) exp(x(1,:)*consistency(1) + x(2,:)*consistency(2));
    denom = fff(values);
    p=0*denom';
    for i = 1:length(values)
      p(i,1) = fff(values(:,i))./sum(denom);
    end
end

end