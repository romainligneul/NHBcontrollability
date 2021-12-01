function [R,Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt]=bbcorr(X,reps1,reps2,p,bL,silent)
% This function computes a double block bootstrap percentile confidence
% interval and bootstrap standard error for the Pearson correlation
% coefficient r and Fisher's z = atanh(r). No Matlab toolboxes are
% required.
%
% References: 
% - Efron, B. and R.J. Tibshirani (1993): An Introduction to the
%   Bootstrap, Chapman & Hall
% - B�hlmann, P. and M. M�chler (2008): Computational Statistics, Lecture
%   Notes, ETH Zurich.
%
% Written by Thomas Maag, maag@mtec.ethz.ch
% VERSION 0.1, APRIL 2009
% THIS IS A PRELIMINARY VERSION, COMMENTS AND QUESTIONS ARE WELCOME.
%
% Input:
%   X         Tx2 data matrix 
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
%   R         correlation coefficient
%   Rpc       bootstrap percentile confidence interval for r
%             (=[q(p),q(1-p)], where q(p) is the p-percentile of the
%             bootstrap distribution)
%   Rsd       bootstrap standard error of r
%   Rpt       alternative bootstrap confidence interval for Zd
%             (=[2*R-q(1-p), 2*R-q(p)], see Efron and Tibshirani, 1993,
%             p. 174)
%   Z         Fisher's z
%   Zpc       bootstrap percentile confidence interval for z
%   Zsd       bootstrap standard error of z
%   Zpt       alternative bootstrap confidence interval for z
%
% Example
%  [R,Rpc,Rsd,Rpt,Z,Zpc,Zsd,Zpt] = bbcorrdiff(X,1,5000,0.9,1,0) computes a standard
%  IID bootstrap (block size = 1) to obtain a 90% percentile confidence
%  interval based on 5000 bootstrap replications (no double bootstrap
%  since reps1=1).
%
[T,K] = size(X);
if K  ~= 2, error('Error: Input matrix X has invalid number of columns.'); end
%Define blocks
bN = ceil(T/bL);
bT = bN*bL;
%Compute summary stats
Rtemp = corr(X, 'type', 'spearman', 'rows', 'pairwise');
R = Rtemp(2,1);
Z = 0.5*log((1+R)/(1-R));
%Define grid for double boostrap evaluation of coverage (pgrid=0.1,
%grid=100 means that effective coverage is evaluated for a grid of
%confidence intervals ranging from 0.998 to 0.8 in steps of 0.002
grid = 100;
pgrid = 0.1;
if reps1 > 1
    plr = [pgrid/grid:pgrid/grid:pgrid];
    phr = [1-pgrid:pgrid/grid:1-pgrid/grid];
    Rdin = zeros(reps1,grid);
    Rdrc = NaN(reps1,2*grid);
    Zdin = zeros(reps1,grid);
    Zdrc = NaN(reps1,2*grid);
    Rdint = zeros(reps1,grid);
    Rdrt = NaN(reps1,2*grid);
    Zdint = zeros(reps1,grid);
    Zdrt = NaN(reps1,2*grid);
else
    grid = 1;
    plr = (1-p)*0.5;
    phr = 1-(1-p)*0.5;
    Rdin = 0;
    Rdrc = NaN(1,2);
    Zdin = 0;
    Zdrc = NaN(1,2);
    Rdint = 0;
    Rdrt = NaN(1,2);
    Zdint = 0;
    Zdrt = NaN(1,2);
end

Xd = NaN(bT,K);
Xr = NaN(bT,K);
Rr = NaN(1,reps2);
Zr = NaN(1,reps2);

if silent == 0
    if reps1 == 1, bar1 = waitbar(0,['Please wait for ' num2str(reps2) ' bootstrap replications...']); end
    if reps1 > 1, bar1 = waitbar(0,['Please wait for ' num2str(reps1) 'x' num2str(reps2) ' = ' num2str(reps1*reps2) ' bootstrap replications...']); end
    disp(['bbcorr0.1 is computing bootstrap statistics for r and z = atanh(r)'])
    disp(['r = ' num2str(R)]);
    disp(['z = ' num2str(Z)]);
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
        Rtemp = corr(Xr, 'type', 'Spearman', 'rows', 'pairwise');
        Rr(1,i) = Rtemp(2,1);
        Zr(1,i) = 0.5*log((1+Rtemp(2,1))/(1-Rtemp(2,1)));
    end
    Rsd = std(Rr)*((bT/T)^0.5);
    Zsd = std(Zr)*((bT/T)^0.5);
    %Standard percentile confidence interval: [q(p), q(1-p)], where q(p) is
    %the p-percentile of the bootstrap distribution
    Rdrc(h,:) = quantl(Rr',[plr phr]')';
    Zdrc(h,:) = quantl(Zr',[plr phr]')';
    %Alternative percentile confidence interval: [2*R-q(1-p), 2*R-q(p)],
    %see Efron and Tibshirani, 1993, p. 174
    Rdrt(h,:) = ones(1,2*grid).*2*R - fliplr(Rdrc(h,:));
    Zdrt(h,:) = ones(1,2*grid).*2*Z - fliplr(Zdrc(h,:));
    if reps1 > 1
        %Check whether R is in percentile confidence interval for all
        %nominal levels over the grid
        for k = 1:grid
            if (R>Rdrc(h,k))&&(R<Rdrc(h,2*grid+1-k))
                Rdin(h,k) = 1;
            end
            if (Z>Zdrc(h,k))&&(Z<Zdrc(h,2*grid+1-k))
                Zdin(h,k) = 1;
            end
            if (R>Rdrt(h,k))&&(R<Rdrt(h,2*grid+1-k))
                Rdint(h,k) = 1;
            end
            if (Z>Zdrt(h,k))&&(Z<Zdrt(h,2*grid+1-k))
                Zdint(h,k) = 1;
            end
        end
    end %End of second level iteration
end %End of first level iteration

%Compute double bootstrap coverage
if reps1 > 1
    %Select percentile for which bootstrap coverage corresponds to the
    %desired nominal coverage
    %Pearson's r
    meanrc = mean(Rdrc);
    Rpin = sum(Rdin).*(1/reps1);
    k = 1;
    while (Rpin(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Rpc = [meanrc(k-1) meanrc(2*grid-k+2)];
    else
        Rpc = [NaN NaN];
    end
    meanrt = mean(Rdrt);
    Rpint = sum(Rdint).*(1/reps1);
    k = 1;
    while (Rpint(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Rpt = [meanrt(k-1) meanrt(2*grid-k+2)];
    else
        Rpt = [NaN NaN];
    end
    %Fisher's z
    meanzc = mean(Zdrc);
    Zpin = sum(Zdin).*(1/reps1);
    k = 1;
    while (Zpin(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Zpc = [meanzc(k-1) meanzc(2*grid-k+2)];
    else
        Zpc = [NaN NaN];
    end
    meanzt = mean(Zdrt);
    Zpint = sum(Zdint).*(1/reps1);
    k = 1;
    while (Zpint(1,k)>=p)&&(k<grid)
        k = k+1;
    end
    if k > 1
        Zpt = [meanzt(k-1) meanzt(2*grid-k+2)];
    else
        Zpt = [NaN NaN];
    end
    if silent == 0
        disp(['Bootstrap standard error of r:']);
        disp(Rsd);
        disp(['Double bootstrap ' num2str(p*100) '% percentile confidence interval for r:']);
        disp(Rpc);
        disp(['Bootstrap standard error of z:']);
        disp(Zsd);
        disp(['Double bootstrap ' num2str(p*100) '% percentile confidence interval for z:']);
        disp(Zpc);
        close(bar1);
    end
else
    Rpc = Rdrc(1,:);
    Zpc = Zdrc(1,:);
    Rpt = Rdrt(1,:);
    Zpt = Zdrt(1,:);
    if silent == 0
        disp(['Bootstrap standard error of r:']);
        disp(Rsd);
        disp(['Bootstrap ' num2str(p*100) '% percentile confidence interval for r:']);
        disp(Rpc);
        disp(['Bootstrap standard error of z:']);
        disp(Zsd);
        disp(['Bootstrap ' num2str(p*100) '% percentile confidence interval for z:']);
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