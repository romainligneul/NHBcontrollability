function  [gx] = o_MBtype2_wOM2_bDEC1(x,P,u,in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameter transformation / should always be performed.
% raw parameters correspond to the x=x transformation.
for pp =1:length(P)  
    P(pp) = in.param_transform{pp}(P(pp));   
end;

%% do

if u(10) <= 1  %%%%%%%%%% EXPLORATORY TRIAL
    gx = ones(3,1)*1/3; % is ignored anyway
        
else          %%%%%%%%%% PREDICTION TRIAL
    cur_s = u(11);
    cur_a = u(12);
    cur_c = u(13);
    
    % SS 
    mixedSS = x(in.hs.map.SS(cur_s,:));
    
    % SAS 
    mixedSAS = x(in.hs.map.SAS{cur_a}(cur_s,:));

    sigomega = VBA_sigmoid(x(in.hs.map.omega), 'slope', P(2), 'center', P(3));

    mixed_values = (1-sigomega)*mixedSS + sigomega*mixedSAS;

    gx = flex_softmax_single(mixed_values, P(1));
        
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