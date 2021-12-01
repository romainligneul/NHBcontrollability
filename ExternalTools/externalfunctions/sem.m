function sem  = sem(X)
% computes s.e.m column by column

for c = 1:size(X,2)
    
    sem(c) = nanstd(X(:,c))/sqrt(size(X,1)-1);
    
end

end