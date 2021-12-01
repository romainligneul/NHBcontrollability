function [binX bincount prcvalues] = binvariable(X,nbins)
% binvariable: transform a variable into discrete/categorial bincodes which
% follow an ascending order (i.e. binX = 1 <=> lowest values).

prcbins = 0:100/nbins:100;
prcvalues = prctile(X,prcbins);
bincount = zeros(1,length(prcvalues)-1);

for i = 1:length(X)
    
    for b = 2:length(prcvalues)
        
        if X(i)<=prcvalues(b)
            
            binX(i) = b-1;
            bincount(b-1) =  bincount(b-1) + 1;
            break
            
        end;
        
    end;
    
end

