function  [gx ] = o_MBtype2_wOM2_bDEC1_JS(x,P,u,in)

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
    
    % SS arbitration
    mixedSS = x(in.hs.map.SS(cur_s,:));
    
    % SAS arbitration
    mixedSAS = x(in.hs.map.SAS{cur_a}(cur_s,:));

    % compute Jensen Shannon Divergence
    S2A_map = {[1,2],[1,3],[2,3]};
    cntf=S2A_map{cur_a};
    pVect1=x(in.hs.map.SAS{cntf(1)}(cur_s,:));
    pVect1(pVect1<eps)=eps;
    pVect1=pVect1/(sum(pVect1));
    pVect2=x(in.hs.map.SAS{cntf(2)}(cur_s,:));
    pVect2(pVect2<eps)=eps;   
    pVect2=pVect2/(sum(pVect2));
    logQvect = log2((pVect2+pVect1)/2);
    JS = .5 * (sum(pVect1.*(log2(pVect1)-logQvect)) + ...
        sum(pVect2.*(log2(pVect2)-logQvect)));
    JS = VBA_sigmoid(JS, 'slope', P(2), 'center', P(3));    
   
    mixed_values = (1-JS)*mixedSS + JS*mixedSAS;

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