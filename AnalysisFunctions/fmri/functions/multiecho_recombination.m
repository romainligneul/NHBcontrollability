function multiecho_recombination(P)

%% realign functionals

spm('defaults', 'FMRI');
spm_jobman('initcfg');

% 3.1. Realign : Estimate (TE1)
% =================================================================

% Load job
% -----------------------------------------------------------------
moduleIx    = 1;
nRun        = size(P.allrun.folder,1);

jobTemplate = fullfile(P.function_path,'realign_estimate_job.m');
jobId       = cfg_util('initjob', jobTemplate);

for i = 1:(nRun- 1)
    cfg_util('replicate', jobId,1,i,-1);
end

% Select first TE scans of all functional runs
% -----------------------------------------------------------------

% Replicate session
for i = 1:(nRun - 1)
    item_mod_id(1) = struct('type','.','subs','val');
    item_mod_id(2) = struct('type','{}','subs',[]);
    item_mod_id(2).subs = num2cell(1);
    cfg_util('setval',jobId,1,item_mod_id,[1 i+1]);
end

for iRun = 1:nRun
    
    % Select files
    % .............................................................
    
    funcFiles   = spm_select('FPListRec', P.allrun.folder{iRun,1},['^fMX.*nii'])
    
    
    
    % Fill in batch
    % .............................................................
    % P. Realign: Estimate: Session i
    
    inputs{iRun, moduleIx} = cellstr(funcFiles);
    
end

% Save and run realignment job
% =================================================================
[~,nm,ext] = fileparts(jobTemplate);
jobFile = fullfile(P.dir_output,[nm,'_',datestr(now,'yyyymmddTHHMMSS'),ext]);

sts = cfg_util('filljob', jobId, inputs{:});
if sts
    cfg_util('savejob', jobId, jobFile);
    
    % Go to report dir, so any graphical output will be written there
    cd(P.dir_output)
    
    spm_jobman('run', jobFile, inputs{:});
end

%%

% 3.2. Apply transformations from TE1 to other TE volumes
% =================================================================

%     fprintf(1,[repmat('-',1,72),'\n'])
%     fprintf(1,'Running ''Apply realignment parameters of TE1 to other TE volumes'' \n')
%
for iRun = 1:size(P.allrun.folder,1)
    
    funcFiles = [];
    
    % Select volumes and group according to TE
    % -------------------------------------------------------------
    for iEcho = 1:P.recombine.n_echoes
        funcFiles{iEcho} = spm_select('FPListRec', P.allrun.folder{iRun,iEcho},['^fMX.*nii'])
    end
    
    funcFiles = cellfun(@(in1) cellstr(in1), funcFiles, 'Uni',0);
    
    % Assert equal number of volumes for each TE
    assert(all(cell2mat(cellfun(@(in1) size(in1,1),funcFiles,'Uni',0))));
    
    % Apply transformation matrix of TE1 to other TE volumes
    % -------------------------------------------------------------
    nFile = size(funcFiles{1},1);
    
    %         spm_progress_bar('Init',nFile, ...
    %             sprintf('Applying realignment parameters of TE1 to other TE volumes for %s ...',settings.subj(iSubject).data.func.name{iRun}), ...
    %             'Volumes Complete');
    
    for iFile = 1:nFile
        
        % Read header of TE1 volume
        V       = cell(1,P.recombine.n_echoes);
        V{1}    = spm_vol(funcFiles{1}{iFile});
        
        % For remaining TE volumes
        for iEcho = 2:numel(P.recombine.n_echoes)
            
            % Read header and the volume
            V{iEcho}        = spm_vol(funcFiles{iEcho}{iFile});
            I               = spm_read_vols(V{iEcho});
            
            % Set transformation matrix equal to TE1 volume
            V{iEcho}.mat    = V{1}.mat;
            
            % Write changes to disk
            spm_write_vol(V{iEcho},I);
        end
        
        %  spm_progress_bar('Set',iFile);
    end
    %    spm_progress_bar('Clear');
end

% 3.3. Realign : Reslice
% =================================================================
%
%
%

inputs      = cell(1,1);

moduleIx    = 1;
nRun        = size(P.allrun.folder,1);

jobTemplate = fullfile(P.function_path,'realign_reslice_job.m');
jobId       = cfg_util('initjob', jobTemplate);

% Select files
% -----------------------------------------------------------------
filt        = '.*.nii$';
funcFiles   = '';

for iRun = 1:size(P.allrun.folder,1)
    
    for iEcho = 1:P.recombine.n_echoes
        % Select files
        
        % .............................................................
        funcFiles   = strvcat(funcFiles, ...
            spm_select('FPListRec', P.allrun.folder{iRun,iEcho},['^fMX.*nii']));
    end
    
end

% Fill in batch
% -----------------------------------------------------------------
% 1. Realign: Reslice: Images
inputs{1, moduleIx} = cellstr(funcFiles);
inputs{1, 2} = P.str_resliced;

% Save and run Realign: Reslice
% -----------------------------------------------------------------
[~,nm,ext] = fileparts(jobTemplate);
jobFile = fullfile(P.dir_output,[nm,'_',datestr(now,'yyyymmddTHHMMSS'),ext]);

sts = cfg_util('filljob', jobId, inputs{:});
if sts
    cfg_util('savejob', jobId, jobFile);
    
    % Go to report dir, so any graphical output will be written there
    cd(P.dir_output)
    
    spm_jobman('run', jobFile, inputs{:});
end

% 3.4. Combine multiple echo volumes into one volume
% =================================================================

MECombineMethod = 'paid';
TE              = P.recombine.echo_times;


% Identify which run contains the prescans
iPrescanRun = P.recombine.indices(1);

%     % Select realigned and resliced prescans
funcFiles   = [];%cell(1,numel(P.allrun.folder{iPrescanRun}));
%
% Step 1 - Select prescan volumes and group according to TE
% -----------------------------------------------------------------
for iEcho = 1:P.recombine.n_echoes
    funcFiles{iEcho} = spm_select('FPListRec', P.allrun.folder{iPrescanRun,iEcho},['^rfMX.*nii']);
    funcFiles{iEcho} = funcFiles{iEcho}(P.recombine.n_weighting,:)
end

funcFiles = cellfun(@(in1) cellstr(in1), funcFiles, 'Uni',0);

nFile = size(funcFiles{1},1);

% Step 2 - Read prescan headers and image data
% -----------------------------------------------------------------

% Get image dimensions of one of the images for pre-allocation
% purposes
V1_1 = spm_vol(funcFiles{1}{1});

% Pre-allocate matrices for headers and image data
V   = cell(1,P.recombine.n_echoes);
Y   = nan([V1_1.dim,nFile,P.recombine.n_echoes]);

% Read pre-scan headers and image data
for iFile = 1:nFile
    for iEcho = 1:P.recombine.n_echoes
        V{iEcho} = spm_vol(funcFiles{iEcho}{iFile});
        Y(:,:,:,iFile,iEcho) = spm_read_vols(V{iEcho});
    end
end

% Step 3 - Compute the weighting of each TE
% -----------------------------------------------------------------
switch lower(MECombineMethod)
    case 'paid'
        
        % For each TE, compute temporal signal-to-noise ratio
        % and contrast-to-noise ratio
        for iEcho=1:P.recombine.n_echoes
            tSNR(:,:,:,iEcho) = mean(Y(:,:,:,:,iEcho),4)./std(Y(:,:,:,:,iEcho),0,4);
            CNR(:,:,:,iEcho) = tSNR(:,:,:,iEcho) * TE(1,iEcho); %% assuming all runs have the same TEs!!
        end
        
        % Sum contrast to noise ratios across TEs
        CNRTotal = sum(CNR,4);
        
        % Determine the weighting
        for iEcho=1:size(TE,2)
            weight(:,:,:,iEcho) = CNR(:,:,:,iEcho) ./ CNRTotal;
        end
        
    case 'te'
        for iEcho=1:size(TE,2)
            weight(:,:,:,i) = TE(i)/sum(TE);
        end
end

% Step 4 - Write the weighting images (for reference only)
% -----------------------------------------------------------------

for iEcho=1:size(TE,2)
    
    VWeights{iEcho} = V{iEcho};
    VWeights{iEcho}.dt = [spm_type('float64'),0];
    
    % New file name
    % .............................................................
    [pth,nme,ext] = fileparts(VWeights{iEcho}.fname);
    VWeights{iEcho}.fname = fullfile(pth,[sprintf('MultiEchoWeights_%smethod_TE%.2d',upper(MECombineMethod),iEcho),ext]);
    
    % Write header of the multi-echo combined volume
    % .........................................................
    spm_create_vol(VWeights{iEcho});
    
    % Write image data of the multi-echo combined volume
    % .........................................................
    spm_write_vol(VWeights{iEcho},weight(:,:,:,iEcho));
    
end

% Step 5 - Apply the weights to the other functional runs
% -----------------------------------------------------------------

allFuncRunIx = 1:size(P.allrun.folder,1);
if P.recombine.id ~= P.resting.id
    run2combine = setdiff(allFuncRunIx,iPrescanRun);
else
    run2combine = allFuncRunIx;
end

for iRun = run2combine
    
    % Select other functional volumes and group according to TE
    % .............................................................
    funcFiles   = cell(1,P.recombine.n_echoes);
    
    for iEcho = 1:P.recombine.n_echoes
        funcFiles{iEcho} = spm_select('FPListRec', P.allrun.folder{iPrescanRun,iEcho},['^rfMX.*nii']);
    end
    
    funcFiles = cellfun(@(in1) cellstr(in1), funcFiles, 'Uni',0);
    
    % Assert equal number of volumes for each TE
    assert(all(cell2mat(cellfun(@(in1) size(in1,1),funcFiles,'Uni',0))));
    
    nFile = size(funcFiles{1},1);
    
    for iFile = 1:nFile
        
        V = cell(1,P.recombine.n_echoes);
        
        % Read functional volumes headers for all echos
        % .........................................................
        for iEcho = 1:P.recombine.n_echoes
            V{iEcho} = spm_vol(funcFiles{iEcho}{iFile});
        end
        
        % Make new filename for combined functional volumes
        % .........................................................
        [pth, nme, ext] = fileparts(funcFiles{1}{iFile});
        
        % combine (c) prefix is added, echo index suffix is removed
        newName         = ['c',nme];
        
        % Create header of the multi-echo combined volume
        % .........................................................
        VNew = V{1};
        VNew.fname = fullfile(pth,[newName,ext]);
        
        % Do the actual weighting
        % .........................................................
        YWeighted = zeros(VNew.dim);
        
        for iEcho = 1:P.recombine.n_echoes
            Y(:,:,:,iEcho) = spm_read_vols(V{iEcho});
            YWeighted = YWeighted + Y(:,:,:,iEcho) .* weight(:,:,:,iEcho);
        end
        
        % Write header of the multi-echo combined volume
        % .........................................................
        spm_create_vol(VNew);
        
        % Write image data of the multi-echo combined volume
        % .........................................................
        spm_write_vol(VNew,YWeighted);
        
    end
end


%%



end



