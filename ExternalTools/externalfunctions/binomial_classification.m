function [acc model ] = binomial_classification(X, y, constant)

model = glmfit(X, y, 'binomial', 'constant', constant);

y_hat = glmval(model, X, 'logit', 'constant', constant);

% From the model predictions we can figure out our best classification
% given this model by thresholding y_hat at 0.5.  This means that we assign
% values with a probability greater than 0.5 into the alive category.
class = y_hat > 0.5;

a_c = y == 1 & class ==1;
a_i = y == 1 & class ==0;
% Define which values were correct and incorrect classifications as dead
d_c = y == 0 & class ==0;
d_i = y == 0 & class ==1;

acc(1) = sum([a_c + d_c])/length(y);
acc(2) = sum([a_i + d_i])/length(y);
acc(3) = mean(a_c);
acc(4) = mean(d_c);
acc(5) = mean(a_i);
acc(6) = mean(d_i);

end