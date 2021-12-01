function [R,Z,Zd,Zpc,Zsd,Zpt] = bbcorrdiff(X,reps1,reps2,p,bL,silent)
% This function computes a double block bootstrap percentile confidence
% interval and bootstrap standard error for the difference of two
% z-transformed Pearson correlation coefficients. No Matlab toolboxes are
% required.
%
% The z-statistic is defined as Zd = z1-z2 = atanh(r1)-atanh(r2),
% where r1 is the Pearson correlation coefficient between columns 1 and 2
% of the input matrix X and r2 is the correlation coefficient between
% columns 3 and 4.
%
% References: 
% - Efron, B. and R.J. Tibshirani (1993): An Introduction to the
%   Bootstrap, Chapman & Hall.
% - Bühlmann, P. and M. Mächler (2008): Computational Statistics, Lecture
%   Notes, ETH Zurich.
%
% Written by Thomas Maag, maag@mtec.ethz.ch
% VERSION 0.1, APRIL 2009
% THIS IS A PRELIMINARY VERSION, COMMENTS AND QUESTIONS ARE WELCOME.
%
% Input:
%   X         Tx4 data matrix
%   reps1     number of first level bootstrap replications
%               if reps1=1 a single bootstrap is computed
%               if reps1>1 a double bootstrap is computed
%   reps2     number of second level (single) bootstrap replications
%   p         coverage of the confidence interval
%   bL        block size
%               if bL=1 the ordinary bootstrap is computed
%               if bL>1 the moving block bootstrap is computed
%   silent    status messages
%               if silent=1 no progress information is displayed
%               if silent=0 progress information is displayed
%
% Output:
%   R         1x2 vector of correlation coefficients
%   Z         1x2 vector of z-transformed correlation coefficients
%   Zd        difference of z-transformed correlation coefficients
%   Zpc       bootstrap percentile confidence interval for Zd 
%             (=[q(p),q(1-p)], where q(p) is the p-percentile of the
%             bootstrap distribution)
%   Zsd       bootstrap standard error of Zd
%   Zpt       alternative bootstrap confidence interval for Zd
%             (=[2*Zd-q(1-p), 2*Zd-q(p)], see Efron and Tibshirani, 1993,
%             p. 174)
%
% Example
%  [R,Z,Zd,Zpc,Zsd,Zpt] = bbcorrdiff(X,1,5000,0.9,1,0) computes a standard IID
%  bootstrap (block size = 1) to obtain a 90% percentile confidence
%  interval based on 5000 bootstrap replications (no double bootstrap
%  since reps1=1).
%
[T,K] = size(X);
if K  ~= 4, error('Error: Input matrix X has invalid number of columns.'); end
%Define blocks
bN = ceil(T/bL);
bT = bN*bL;
%Compute summary stats
Rtemp = corrcoef(X);
R = [Rtemp(1,2) Rtemp(3,4)];
Z = [0.5*log((1+R(1,1))/(1-R(1,1))) 0.5*log((1+R(1,2))/(1-R(1,2)))];
Zd = Z(1,1)-Z(1,2);
%Define grid for double boostrap evaluation of coverage (pgrid=0.1,
%grid=100 means that effective coverage is evaluated for a grid of
%confidence intervals ranging from 0.998 to 0.8 in steps of 0.002
grid = 100;
pgrid = 0.1;
if reps1 > 1
    plr = [pgrid/grid:pgrid/grid:pgrid];
    phr = [1-pgrid:pgrid/grid:1-pgrid/grid];
    Zdin = zeros(reps1,grid);
    Zdint = zeros(reps1,grid);
    Zdrc = NaN(reps1,2*grid);
    Zdrt = NaN(reps1,2*grid);
else
    grid = 1;
    plr = (1-p)*0.5;
    phr = 1-(1-p)*0.5;
    Zdin = 0;
    Zdrc = NaN(1,2);
    Zdrt = NaN(1,2);
end

Xd = NaN(bT,K);
Xr = NaN(bT,K);
Zr = NaN(1,reps2);

if silent == 0
    if reps1 == 1, bar1 = waitbar(0,['Please wait for ' num2str(reps2) ' bootstrap replications...']); end
    if reps1 > 1, bar1 = waitbar(0,['Please wait for ' num2str(reps1) 'x' num2str(reps2) ' = ' num2str(reps1*reps2) ' bootstrap replications...']); end
    disp(['bbcorrdiff0.1 is computing bootstrap statistics for z1-z2 = atanh(r1)-atanh(r2)'])
    disp(['z1 =    ' num2str(Z(1,1)) '    (r1 = ' num2str(R(1,1)) ')']);
    disp(['z2 =    ' num2str(Z(1,2)) '    (r2 = ' num2str(R(1,2)) ')']);
    disp(['z1-z2 = ' num2str(Zd) ' ~ normal with standard deviation (2/(T-3))^0.5 = ' num2str((2/(T-3))^0.5)]);
    disp(['Sample size: ' num2str(T) '    Block size: ' num2str(bL) '    Bootstrap sample size: ' num2str(bT)]);
    disp(['Number of first level iterations:  ' num2str(reps1)]);
    disp(['Number of second level iterations: ' num2str(reps2)]);
    disp(['(CRTL-C interrupts the bootstrapping process.)']);
end

%First level iteration (double bootstrap)
U1 = fix(rand(reps1,bN).*(T-bL+1));
for h = 1:reps1
    if (silent == 0)&&(reps1 > 1), waitbar(h/reps1); end
    if reps1 > 1
        for j = 1:bN
            %Generate a new first level bootstrap sample as input for the
            %seond level bootstrap
            Xd(1+(j-1)*bL:j*bL,:) = X(1+U1(h,j):U1(h,j)+bL,:);
        end
    else
        %Use original data matrix if no double bootstrap
        Xd = X;
    end
    
    %Second level iteration (actual bootstrap) based on input matrix Xd
    U2 = fix(rand(reps2,bN).*(T-bL+1));
    for i = 1:reps2
        if (silent == 0)&&(reps1 == 1), waitbar(i/reps2); end
        for j = 1:bN
            %Generate second level bootstrap sample
            Xr(1+(j-1)*bL:j*bL,:) = Xd(1+U2(i,j):U2(i,j)+bL,:);
        end
        Rtemp = corrcoef(Xr);
        Zr(1,i) = 0.5*log((1+Rtemp(1,2))/(1-Rtemp(1,2))) - 0.5*log((1+Rtemp(3,4))/(1-Rtemp(3,4)));
    end
    Zsd = std(Zr)*((bT/T)^0.5);
    %Standard percentile confidence interval: [q(p), q(1-p)], where q(p) is
    %the p-percentile of the bootstrap distribution
    Zdrc(h,:) = quantl(Zr',[plr phr]')';
    %Alternative percentile confidence interval: [2*Zd-q(1-p), 2*Zd-q(p)],
    %see Efron and Tibshirani, 1993, p. 174
    Zdrt(h,:) = ones(1,2*grid).*2*Zd - fliplr(Zdrc(h,:));
    if reps1 > 1
        %Check whether R is in percentile confidence interval for all
        %nominal levels over the grid
        for k = 1:grid
            if (Zd>Zdrc(h,k))&&(Zd<Zdrc(h,2*grid+1-k))
                Zdin(h,k) = 1;
            end
            if (Zd>Zdrt(h,k))&&(Zd<Zdrt(h,2*grid+1-k))
                Zdint(h,k) = 1;
            end
        end
    end %End of second level iteration
end %End of first level iteration

%Compute double bootstrap coverage and select percentile for which
%bootstrap coverage corresponds to the desired nominal coverage
if reps1 > 1
    meanrc = mean(Zdrc);
    Zpin = sum(Zdin).*(1/reps1);
    k = 1;
    while (Zpin(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Zpc = [meanrc(k-1) meanrc(2*grid-k+2)];
    else
        Zpc = [NaN NaN];
    end
    meanrt = mean(Zdrt);
    Zpint = sum(Zdint).*(1/reps1);
    k = 1;
    while (Zpint(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Zpt = [meanrt(k-1) meanrt(2*grid-k+2)];
    else
        Zpt = [NaN NaN];
    end
    if silent == 0
        disp(['Bootstrap standard error of z1-z2:']);
        disp(Zsd);
        disp(['Double bootstrap ' num2str(p*100) '% percentile confidence interval for z1-z2:'])
        disp(Zpc);
        close(bar1);
    end
else
    Zpc = Zdrc(1,:);
    Zpt = Zdrt(1,:);
    if silent == 0
        disp(['Bootstrap standard error of z1-z2:']);
        disp(Zsd);
        disp(['Bootstrap ' num2str(p*100) '% percentile confidence interval for z1-z2:'])
        disp(Zpc);
        close(bar1);
    end
end
end

function [Q] = quantl(X,P)
%Computes quantiles of column vector X specified in column vector P
[T] = size(X,1);
[k] = size(P,1);
Q = NaN(k,1);
Y = sort(X);
Z = [Y(1); Y; Y(T)];
for i = 1:k
    it = fix(P(i,1)*T+0.5);
    rt = P(i,1)*T+0.5-it;
    Q(i,1) = Z(it+1)+rt*(Z(it+2)-Z(it+1));
end
end