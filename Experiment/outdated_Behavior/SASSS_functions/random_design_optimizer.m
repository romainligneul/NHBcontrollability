% generates random designs for the SSSAS experiment and pick the best ones

clear all

% param�tres du g�n�rateur:
n_sequences = 1;
smoothing_bool = 1;
HPlength = [60];
LPsmooth = 2;
eval(['load ' 'myscannerxc']);  
xc = myscannerxc;
nonlinthreshold = 2;
TR = 0.7;
hrf_est = 1;
dflag = 0 % compute d-optimality rather than a-optimality ([0]): better for HRF estimation but
% less powerful for contrast detection.
priorities = [1 1] % priorities(1) = cnt / priorities(2) = hrf;
contrasts = [-1 1 0 0 0] % 0 pour DM, -1 pour Lose, +1 pour win / 0 final pour la baseline
contrastweights = [1];

% forme de la HRF
HRF = spm_hrf(.1);						% SPM HRF sampled at .1 s
HRF = HRF/ max(HRF);

% % smoothing matrix
% S = [];
% if smoothing_bool
% [S,Vi,svi] = getSmoothing(HPlength,LPsmooth,TR,numsamps,xc);
% clear Vi
% end;

% PARAMETRES ET VARIABLES DU DESIGN
n_rep = 60;
n_cond = 4;
Seqlength = 540;
n_sublocks = 1;
inter_block_length = 25;
Seqlength = Seqlength + (n_sublocks -1)*25;
numsamps = ceil(Seqlength/TR);
% compteur
compteur=zeros(1,n_cond);
limite = 60;

% longueur des events:
DMlength = 1;
    DMcolumn = ones(n_rep,1);
Outlength = 2;
    Outcolumn = 2*ones(n_rep,1);
    
jit1 = repmat([2 2.5 3 3.5 4], 1, n_rep/5)'; % jitter1 centr� sur 3s
jit2 = repmat([2 2.5 3 3.5 4], 1, n_rep/5)'; % jitter2 centr� sur 3s
Dir_DM = repmat([3 4], 1, n_rep/2)';

% build TR_vectorbined_TR = zeros(1,2500);
bined_TR = zeros(1,TR*1000);
bined_TR(:,[1 501 1001 1501 2001]) = [1 2 3 4 5];
TR_vector = repmat(bined_TR, 1, Seqlength/TR);


%mod�lisation des pauses, ou de la s�paration en blocs (custom)
%non inclus dans le fichier de sortie
jit3 = zeros(n_rep,1);
for u=1:(n_sublocks-1)
    jit3(n_rep*(u/n_sublocks)) = inter_block_length;
end
    

% fr�quence des outcomes (2 = victoire / 1 = d�faite)
def_vict{1} = repmat([2 1 1 1], 1, n_rep/4)';
def_vict{2} = repmat([2 2 1 1], 1, n_rep/4)';
def_vict{3} = repmat([2 2 2 1], 1, n_rep/4)';
def_vict{4} = repmat([2 2 1 1], 1, n_rep/4)';

xtxitx = [];
svi = [];
S = [];
if smoothing_bool
[S,Vi,svi] = getSmoothing(HPlength,LPsmooth,TR,numsamps,xc);
clear Vi
end;

% MAIN LOOP

for k = 1:n_cond % on r�p�te l'op�ration pour les 3 conditions
    sortie = 0;
    j = 0;
    hrf_fitness = [];
    cnt_fitness = [];
    fitness = [];
    
%     if k <4, continue, end
    
    while  sortie == 0
        % initialisation
        model = [];
        model = zeros(Seqlength*10,1);
        
        % randomisation des ordres vict / d�f
        df = def_vict{k}(randperm(n_rep));

        % controle moyenne roulante
        rool_mean = cumsum(df-1)./cumsum(ones(1,n_rep))';
        if isempty([find(rool_mean(10:end) > rool_mean(end) + 0.05) ; find(rool_mean(10:end) < rool_mean(end) - 0.05)]);
        else
            continue
        end        
        
        % randomisation des jitters
        jit1 = jit1(randperm(n_rep));
        jit2 = jit2(randperm(n_rep));
        
        % randomization gauche/droite
        Dir_DM = Dir_DM(randperm(n_rep));
        
        % construction du "model" from jit vecteurs -> 1 = DM phases /
        % 2 = d�faites / 3 = victoires :).
        trial_onsets = [0; cumsum(jit1(1:end-1) + DMcolumn(1:end-1) + jit2(1:end-1) + Outcolumn(1:end-1) + jit3(1:end-1))]*10;
        trial_offsets = [cumsum(jit1(1:end) + DMcolumn(1:end) + jit2(1:end) + Outcolumn(1:end) + jit3(1:end))]*10;
        model = zeros(Seqlength*10,1);
%        model2 = zeros(Seqlength*1000, 1);
        model(trial_onsets + jit1*10) = Dir_DM;
%        model2(trial_onsets*100 + jit1*1000) = Dir_DM;
        model(trial_onsets + jit1*10 + Outcolumn*10 + jit2*10) = df; 
%        model2(trial_onsets*100 + jit1*1000 + Outcolumn*1000 + jit2*1000) = df;
        
%         out = false;
%         
%         for bin = 1:5
%             % check binning for DM
%             if length(find(TR_vector(find(model2 == 3 | model2 == 4)+1) == bin)) < 7 % si y'en a un suppérieur à 14, c'est mort..
%                 out = true;
%                 break
%             end;
%             if length(find(TR_vector(find(model2 == 1)+1) == bin)) ~= ((length(find(df == 1)) / 5) - (length(find(df == 1))/15))
%                 out = true;
%                 break
%             end;
%             if length(find(TR_vector(find(model2 == 2)+1) == bin)) ~= (length(find(df == 2)) / 5 - (length(find(df == 2))/15))
%                 out = true;
%                 break
%             end
%         end
%         
%         if out == true
%             continue
%         end
        
        stimlist = model(find(model));
        
         % calcul contrebalancement Direction / victoire
%          [cBal,dummy,maxDev] = getCounterBal(stimlist, 1,[1 2 3 4],[0.5*(1-(mean(df)-1)) 0.5*(mean(df)-1) 0.25 0.25]);
%          CheckBal(end+1) = cBal;
        bal = mean(stimlist(find(stimlist == 2)-1));
        
        if bal < 3.4 || bal > 3.6 % mauvais contrebalancement
            continue;
        end
        
        trial_onsets = [0; cumsum(jit1(1:end-1) + DMcolumn(1:end-1) + jit2(1:end-1) + Outcolumn(1:end-1))]*10;
        trial_offsets = [cumsum(jit1(1:end) + DMcolumn(1:end) + jit2(1:end) + Outcolumn(1:end))]*10;
        
        % borne pour attente du prochain TR (avant DM)
        
        index = find(TR_vector(find(model2 == 3 | model2 == 4)+1) == 1)
        
        borne = zeros(60,1);
        borne(index,1) = 1;
        
        % ESTIMATION DE L'EFFICIENCE DU MODELE
        
        % whitening svi (???)
        if dflag, svi = pinv(svi);  end
        
        [model,delta] = getPredictors(model,HRF);
        hires_model = model;
        model = resample(model,1,TR*10);
        if ~isempty(nonlinthreshold),model = modelSaturation(model,nonlinthreshold);,end
        if ~isempty(S)
		model = S * model; % temporal smoothing and HP/LP filter
        end
        model(:,end+1) = 1;
        
        % calcule la fitness du mod�le pour la d�tection de contraste
        if dflag
            xtxitx = model'*svi*model;  % d-optimality
            cnt_fitness(j) = calcEfficiency(contrastweights,contrasts,xtxitx,[],dflag);
        else
            xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
            [cnt_fitness(end + 1)] = calcEfficiency(contrastweights,contrasts,xtxitx,svi,dflag);
            j = j + 1;
        end

%        deltaWIN = downsample_delta(delta(:,2:3), TR*10)
        
        
        % calcule la fitness pour l'estimation de la HRF
%        [hrf_fitnessWIN(j)] = hrf_power(TR,12,deltaWIN,[1 0; 0 1]);
        
        % fitness globale
%         fitness(j) = priorities(1) * cnt_fitness(j) + priorities(2)* hrf_fitness(j);
        
        % �criture si n�cessaire
        if j > n_sequences
            if cnt_fitness(j) > 0.95*max(cnt_fitness(1:n_sequences))
                    compteur(k) = compteur(k) +1;
                    if compteur(k) > limite, sortie = 1, end
                    fid = fopen(sprintf('%s%d%s%d%s', 'Op_RandDesign_', k,'_', compteur(k),'.txt'), 'w');
                    for p = 1:n_rep
                    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', num2str(jit1(p)),num2str(jit2(p)),num2str(k),num2str(df(p)), num2str(Dir_DM(p)), num2str(trial_onsets(p)), num2str(trial_offsets(p)), num2str(borne(p)), num2str(cnt_fitness(j)));
                    end;
                    fclose(fid);
                    
            end;
        end
                
    end
end
        
%         jit1 = jit1(randperm(n_rep));
%         jit2 = jit2(randperm(n_rep));
        
            

