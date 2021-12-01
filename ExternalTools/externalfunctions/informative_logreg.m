function [b dev stats BIC AIC LL acc classif] = informative_logreg(X, y, constant, offset)
%%%% INPUT: same as for glmfit. By default, include a constant term to the
%%%% model

if nargin < 3
    constant = 'on';
end;

if nargin == 4;
    offset = repmat(offset, length(y), 1); 
    [b dev stats] = glmfit(X, y, 'binomial', 'offset', offset, 'constant',constant);
    y_hat = glmval(b, X, 'logit', 'offset', offset, 'constant', constant);
else
     [b dev stats] = glmfit(X, y, 'binomial', 'constant',constant);
    y_hat = glmval(b, X, 'logit', 'constant', constant);   
end;



%%% compute additional goodness of fit indicators?
if nargout>3
    
    class = y_hat > 0.5;
    a_c = y == 1 & class ==1;
    a_i = y == 1 & class ==0;
    d_c = y == 0 & class ==0;
    d_i = y == 0 & class ==1;
    
    acc = sum(a_c + d_c)/length(y);
    
    LL = sum(log(binopdf(y,ones(length(y),1),y_hat)));
    BIC = -2*LL + size(X,2)*log(length(y));
    AIC = -2*LL + size(X,2)*2;
    
end

%%% cross-validate using a leave one out procedure
if nargout > 7
    
    nullvec = zeros(1,length(y_hat));
    for j = 1:length(y_hat)
        test = nullvec; test(j) = 1;
        train = ~test;
        if nargin < 4
            dumb = glmfit(X(train,:),y(train),'binomial', 'constant', constant); % Logistic regression
            dum_y_hat = glmval(dumb,X(find(test),:),'logit', 'constant', constant);
        else
            dumb = glmfit(X(train,:),y(train),'binomial', 'offset', offset, 'constant',constant); % Logistic regression
            dum_y_hat = glmval(dumb,X(find(test),:),'logit', 'offset', offset, 'constant',constant);
        end;
        dumacc(j) = round(dum_y_hat)==y(find(test));
    end
    
    classif = mean(dumacc);
    
end;

    