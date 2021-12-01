% REX (Roi Extraction) Extracts values from the selected data files at the specified ROI(s).
%
% REX; Interactive parameter definition
%
% MEANS=REX(SOURCES, ROIS);
% where SOURCES is a list of M source volume files (image files to extract from)
% and ROIS is list of N roi files (image or .tal files)
% returns the mean values of each of the source volume files at the voxels
% identified by each ROI in the matrix MEANS (with size M x N).
%
% REX(SOURCES, ROIS, 'paramname1',paramvalue1,'paramname2',paramvalue2,...);
%   permits the specification of additional parameters:
%       'summary_measure' :     choice of summary measure (across voxels) [{'mean'},'eigenvariate','median','weighted mean','count']
%       'level' :               summarize across [{'rois'},'clusters','peaks','voxels']
%       'scaling' :             type of scaling (for timeseries extraction) [{'none'},'global','roi']
%       'conjunction_mask':     filename of conjunction mask volume(s)
%       'output_type' :         choice of saving output ['none',{'save'},'saverex']
%       'gui' :                 starts the gui [{0},1] 
%       'select_clusters'       asks user to select one or more clusters if multiple clusters exists within each ROI [0,{1}]
%       'dims' :                (for 'eigenvariate' summary measure only): number of eigenvariates to extract from the data
%       'mindist' :             (for 'peak' level only): minimum distance (mm) between peaks 
%       'maxpeak' :             (for 'peak' level only): maximum number of peaks per cluster
%

% last modified, 2/7/02 Sue Whitfield
% last modified 04/09: Update to spm5/spm8b/spm8;
%                      Allows rois to be defined from roi image files (.nii,
%                       .img)
%                      Allows averaging over a subset of clusters (if the
%                       roi contains more than one connected set)
%                      Allows the specification of an additional
%                       conjunction mask (the intersection of this mask and
%                       each roi will be used as voxels to extract the
%                       average from)
%                      Incorporates additional summary measures (eigenvariate,
%                       weighted mean, median, and count)
%                      Incorporates scaling options (whole-brain and within-roi)
%                      Allows source files to be defined from a SPM.mat
%                       file (first-level or second-level analyses)
%                      Incorporate plots of contrast estimates,
%                       fitted&adjusted response, event-related response
%                       estimates, etc.
%                      Incorporate analysis options to perform ROI-based analyses 
%                       replicating SPM voxel-based analyses
%

% version 2.1

function varargout=rex(ImgF, roi_path_array, varargin);

if nargin>0, % COMMAND-LINE OPTIONS
    fields={'sources','',...
        'rois','',...
        'conjunction_mask','',...           % conjunction mask volume file(s)
        'spm_file','',...                   % spm.mat file
        'scaling','none',...                % ['none','global','roi']
        'summary_measure','mean',...        % ['mean','eigenvariate','median','weighted mean','count']
        'output_type','',...                % ['none','save','saverex']
        'level','ROIs',...                  % ['ROIs','clusters','peaks','voxels']
        'dims',1,...                        % (for eigenvariate measure: number of dimensions to extract)
        'gui',[],...                        % use gui
        'mindist',20,...                    %
        'maxpeak',32,...                    %
        'select_clusters',1,...             % asks user to select one or more clusters if multiple clusters exists within each ROI
        'steps',[]};                        % cell array of additional steps to run after gui launches (rex_gui valid arguments, e.g. 'extract')
    if isstruct(ImgF), % CONTINUES PREVIOUS SESSION
        params=ImgF;
        for n1=0:2:nargin-2, if ~n1, params=setfield(params,lower(roi_path_array),varargin{n1+1}); else, params=setfield(params,lower(varargin{n1}),varargin{n1+1}); end; end
        for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
        if isempty(params.output_type),if nargout>0, params.output_type='none'; else, params.output_type='save'; end; end
        if isempty(params.gui),if nargout>0, params.gui=0; else, params.gui=1; end; end
    else,
        params=[]; for n1=1:2:nargin-2, params=setfield(params,lower(varargin{n1}),varargin{n1+1}); end
        for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
        if isempty(params.output_type),if nargout>0, params.output_type='none'; else, params.output_type='save'; end; end
        if isempty(params.gui),if nargout>0, params.gui=0; else, params.gui=1; end; end
        params.sources=ImgF;
        params.rois=roi_path_array;
    end
    if ~params.gui, % COMMAND-LINE 
        if ~isempty(params.spm_file)&&(~isfield(params,'SPM')||isempty(params.SPM)),
            params.SPM=load(params.spm_file);
        end
        if ~isfield(params,'VF') && ~isempty(params.sources),
            temp=params.sources;
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                params.spm_file=deblank(temp);
                params.SPM=load(params.spm_file,'SPM');
                params.sources=strvcat(params.SPM.SPM.xY.VY(:).fname);
                try,
                    params.VF=params.SPM.SPM.xY.VY;
                    nill=spm_read_vols(params.VF(1));
                catch,
                    cwd=pwd;[filepath,nill,nill]=fileparts(params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath);
                    params.VF=spm_vol(params.sources);
                    cd(cwd);
                end
            else,
                %params.spm_file='';
                params.sources=temp;
                params.VF=spm_vol(temp);
            end
        end
        if ~isfield(params,'VM') && ~isempty(params.conjunction_mask),
            params.VM=spm_vol(params.conjunction_mask);
        end
        [params.ROIdata,params.ROInames,params.ROIinfo.basis,params.ROIinfo.voxels,params.ROIinfo.files,params.ROIinfo.select,params.ROIinfo.trans]=rex_do(params,1);
        data.params=params; for n1=1:length(params.steps), data=rex_gui([],[],params.steps{n1},data,0); end; params=data.params;
        if strcmpi(params.output_type,'save')||strcmpi(params.output_type,'saverex'), save('REX.mat','params'); end
        varargout={params.ROIdata,params.ROInames,params};
        return; 
    end
else
    if ~isempty(dir('REX.mat')),
        [answ]=questdlg('Continue from previous session?','','Yes','No (starts a new session)','Yes');
        if strcmp(answ,'Yes'),load('REX.mat');rex(params);return;end
    end
    % GUI INIT
    fields={'sources','',...
        'rois','',...
        'conjunction_mask','',...           % conjunction mask volume file
        'spm_file','',...                   % spm.mat file
        'scaling','none',...                % ['none','global','roi']
        'summary_measure','mean',...        % ['mean','eigenvariate','median','weighted mean','count']
        'output_type','save',...            % ['none','save']
        'level','ROIs',...                  % ['ROIs','clusters','peaks','voxels']
        'dims',1,...
        'gui',1,...
        'mindist',20,...                     
        'maxpeak',32,...                     
        'select_clusters',1,...
        'steps',[]};
    params=[]; for n1=1:2:length(fields), if ~isfield(params,fields{n1}), params=setfield(params,fields{n1},fields{n1+1}); end; end
end

% GUI INITIALIZATION
try,spm('Defaults','fMRI');end
guistruct=struct('level',struct('gui',{{'ROI-level: Extracts one dataset separately for each ROI file','Cluster-level: Extracts one dataset separately for each connected / labeled area within each ROI file','Peak-level: Extracts one dataset separately for each local-maximum area within each ROI file','Voxel-level: Extracts one dataset separately for each voxel within each ROI file'}},...
    'values',{{'ROIs','clusters','peaks','voxels'}}),...
    'summary_measure',struct('gui',{{'Extract mean','Extract eigenvariate','Extract weighted-mean','Extract median','Extract voxel count'}},...
    'values',{{'mean','eigenvariate','weighted mean','median','count'}}),...
    'scaling',struct('gui',{{'No scaling','global scaling','within-roi scaling'}},...
    'values',{{'none','global','roi'}}),...
    'output_type',struct('gui',{{'Save output data files','Save REX project only','No output files'}},...
    'values',{{'save','saverex','none'}}));
handles(1)=figure('units','norm','position',[.2,.4,.2,.5],'name','REX','menubar','none','numbertitle','off','color','w');
handles(2)=uicontrol('units','norm','position',[.05,.900, .4,.075],'style','pushbutton','string','Sources','callback',{@rex_gui,'sources'});
handles(3)=uicontrol('units','norm','position',[.50,.900, .4,.050],'style','text','string','not selected','foregroundcolor','r','backgroundcolor','w');
handles(4)=uicontrol('units','norm','position',[.05,.800, .4,.075],'style','pushbutton','string','ROIs','callback',{@rex_gui,'rois'});
handles(5)=uicontrol('units','norm','position',[.50,.800, .4,.050],'style','text','string','not selected','foregroundcolor','r','backgroundcolor','w');
handles(6)=uicontrol('units','norm','position',[.05,.700, .9,.075],'style','popupmenu','string',strvcat(guistruct.level.gui{:}),'value',strmatch(params.level,guistruct.level.values,'exact'),'callback',{@rex_gui,'level'});
handles(7)=uicontrol('units','norm','position',[.05,.550, .9,.075],'style','popupmenu','string',strvcat(guistruct.summary_measure.gui{:}),'value',strmatch(params.summary_measure,guistruct.summary_measure.values,'exact'),'callback',{@rex_gui,'summary_measure'});
handles(8)=uicontrol('units','norm','position',[.05,.475, .9,.075],'style','popupmenu','string',strvcat(guistruct.scaling.gui{:}),'value',strmatch(params.scaling,guistruct.scaling.values,'exact'),'callback',{@rex_gui,'scaling'});
handles(9)=uicontrol('units','norm','position',[.09,.01, .3,.075],'style','pushbutton','string','Extract','enable','off','callback',{@rex_gui,'extract'});
handles(10)=uicontrol('units','norm','position',[.69,.01, .3,.075],'style','pushbutton','string','plots','enable','off','callback',{@rex_gui,'plot'});
handles(11)=uicontrol('units','norm','position',[.05,.625, .9,.075],'style','popupmenu','string',strvcat('No conjunction mask','Use conjunction mask'),'value',1+~isempty(params.conjunction_mask),'callback',{@rex_gui,'conjunction'});
handles(12)=uicontrol('units','norm','position',[.39,.01, .3,.075],'style','pushbutton','string','Results','enable','off','callback',{@rex_gui,'results'});
handles(13)=uicontrol('units','norm','position',[.05,.400, .9,.075],'style','popupmenu','string',strvcat(guistruct.output_type.gui{:}),'value',strmatch(params.output_type,guistruct.output_type.values,'exact'),'callback',{@rex_gui,'output_type'});
subplot(212);a=zeros(1,361);b=1+a;c=2+b;imagesc(reshape(...
    [c(1:361),b(1:9),c(1:90),1,1,2,b(1:12),c(1:31),1,c(1:54),b(1:4),0,2,b(1:9),c(1:33),1,c(1:52),b(1:14),2,2,b(1:5),c(1:79),1,2,1,a(1:4),1,1,2,1,0,1,1,1,2,2,1,1,0,1,0,0,1,1,c(1:25),0,c(1:50),1,1,1,0,c(1:5),1,1,0,1,2,2,1,0,1,2,b(1:8),c(1:75),1,2,2,1,c(1:4),b(1:4),0,1,0,2,1,0,1,2,0,b(1:4),0,0,1,1,c(1:71),1,1,1,c(1:6),1,2,1,1,1,0,1,1,1,2,1,1,2,1,c(1:6),1,0,c(1:22),0,c(1:47),1,1,2,0,2,1,2,1,2,2,b(1:4),0,0,b(1:4),2,2,1,0,0,1,a(1:4),1,0,1,c(1:21),1,c(1:47),1,1,2,2,2,1,c(1:4),b(1:9),2,1,2,1,a(1:6),1,1,1,0,0,1,c(1:19),1,c(1:46),1,1,1,0,2,2,2,1,2,2,2,b(1:13),0,2,1,0,1,c(1:7),1,1,0,1,c(1:16),1,c(1:45),1,1,1,2,2,b(1:4),2,b(1:6),2,1,0,1,1,1,0,1,1,0,0,1,1,0,c(1:6),1,0,b(1:6),0,0,c(1:9),1,c(1:45),1,1,1,0,1,c(1:4),b(1:8),0,b(1:4),2,0,1,1,0,0,0,1,0,0,c(1:6),1,1,0,0,0,1,1,0,1,1,c(1:8),1,c(1:44),b(1:4),c(1:6),b(1:5),0,0,b(1:9),2,0,1,0,1,1,1,0,0,1,0,0,1,a(1:5),1,1,0,0,1,1,0,c(1:51),b(1:5),...
        c(1:4),1,1,0,1,1,0,1,1,0,b(1:4),2,1,1,2,2,1,c(1:4),1,1,0,1,1,1,a(1:6),b(1:4),0,1,0,0,c(1:49),1,1,0,0,2,1,2,2,2,1,1,0,b(1:5),0,0,b(1:8),2,b(1:7),0,0,0,1,0,0,1,1,0,0,0,1,0,0,1,1,0,0,0,c(1:47),b(1:5),2,2,1,2,b(1:6),0,b(1:4),0,b(1:6),0,2,1,1,0,0,1,1,0,0,1,1,0,1,1,1,a(1:4),1,0,b(1:6),0,c(1:46),b(1:5),2,2,2,0,1,1,0,1,1,0,b(1:5),0,b(1:4),0,2,a(1:4),2,0,1,1,0,1,1,1,2,2,1,2,1,1,0,1,2,1,0,1,1,0,0,1,0,0,c(1:44),b(1:5),2,2,b(1:6),0,b(1:5),0,b(1:4),0,0,1,1,0,1,1,0,0,0,1,2,a(1:9),1,1,0,b(1:9),0,0,c(1:43),b(1:5),2,2,1,0,b(1:4),0,b(1:4),0,0,b(1:5),0,b(1:5),a(1:5),c(1:5),0,0,1,a(1:4),1,2,b(1:4),0,1,0,1,0,c(1:43),1,1,1,0,2,1,1,1,0,1,1,1,0,0,b(1:4),0,0,1,0,0,2,b(1:7),2,1,0,1,1,2,0,2,a(1:7),b(1:7),0,1,1,0,0,0,1,c(1:41),1,0,1,1,1,2,1,0,0,1,1,0,1,1,0,0,1,0,1,1,0,1,1,1,0,b(1:4),0,2,b(1:5),2,2,1,0,1,a(1:5),b(1:4),0,1,1,1,0,0,1,1,1,0,0,c(1:41),0,0,b(1:5),0,1,1,1,0,b(1:5),0,0,b(1:4),0,0,...
        b(1:4),2,0,1,a(1:6),1,1,1,0,1,1,0,0,b(1:5),2,1,1,0,0,1,1,1,0,1,0,c(1:39),1,0,0,b(1:6),0,0,1,0,1,1,0,0,0,1,0,0,1,1,0,1,0,1,1,2,1,0,2,2,0,0,0,2,0,1,1,0,0,0,1,1,a(1:4),b(1:6),0,b(1:6),0,c(1:39),b(1:11),2,b(1:4),0,0,0,b(1:8),0,0,1,2,2,1,1,2,2,b(1:8),0,2,1,1,0,1,1,2,1,0,1,0,0,1,1,1,0,1,0,c(1:39),0,1,1,0,1,1,0,1,1,0,1,1,0,b(1:8),2,0,2,0,b(1:11),0,0,b(1:5),a(1:4),1,0,0,1,0,1,0,1,0,1,1,1,0,1,1,0,c(1:39),0,1,1,1,0,1,1,0,1,0,1,0,0,0,b(1:5),0,b(1:7),0,0,b(1:6),0,1,2,1,2,1,0,1,0,0,1,0,0,0,1,1,2,1,1,1,0,1,1,1,0,1,1,0,c(1:38),1,0,1,1,0,1,1,0,b(1:4),a(1:6),b(1:4),0,0,0,1,1,0,b(1:5),2,0,b(1:4),0,0,1,a(1:5),1,0,1,1,1,2,1,1,0,1,1,1,0,1,1,1,0,1,c(1:37),0,1,1,1,0,1,1,0,0,1,1,1,0,1,0,0,1,0,1,1,0,0,1,1,1,0,0,b(1:4),0,1,1,a(1:5),2,2,0,1,a(1:7),1,1,2,1,1,a(1:4),1,1,0,1,0,c(1:37),0,0,1,1,1,0,b(1:4),0,b(1:5),a(1:4),b(1:4),0,0,b(1:4),2,2,1,1,2,0,0,1,2,2,2,a(1:4),1,1,0,1,0,1,1,1,2,1,1,0,0,...
        b(1:4),0,1,1,1,c(1:36),0,0,1,2,1,1,1,0,1,1,0,2,1,0,1,0,1,1,a(1:4),b(1:6),0,0,b(1:5),0,2,1,1,2,1,1,a(1:6),1,0,0,1,2,1,1,0,0,b(1:5),0,1,1,1,c(1:35),0,1,0,1,1,0,b(1:8),a(1:11),1,0,1,0,0,0,1,2,1,1,1,0,b(1:4),2,1,1,0,0,1,0,0,1,1,1,0,b(1:5),0,1,1,1,0,0,0,1,c(1:36),a(1:4),b(1:4),0,1,a(1:5),1,1,0,0,1,0,0,1,0,1,a(1:4),1,2,1,1,1,2,1,0,1,a(1:7),1,1,2,a(1:5),b(1:4),0,0,1,1,0,b(1:4),c(1:35),1,1,1,0,1,0,1,0,0,0,1,a(1:4),b(1:5),0,1,0,0,0,b(1:7),0,b(1:4),0,0,2,2,1,a(1:10),1,2,2,b(1:11),0,c(1:35),1,1,1,0,1,1,1,a(1:7),b(1:5),a(1:4),1,0,0,b(1:8),0,1,2,1,1,1,2,2,1,1,2,2,a(1:4),1,0,0,b(1:9),0,0,1,1,0,c(1:35),0,1,0,0,1,0,0,b(1:4),0,0,b(1:4),0,1,1,1,0,0,1,2,0,0,0,1,0,2,1,1,2,2,2,1,1,a(1:4),1,1,1,0,2,2,0,1,1,1,0,b(1:5),0,1,1,1,a(1:5),c(1:34),1,0,0,1,0,b(1:4),a(1:4),1,2,1,1,0,1,1,1,0,0,0,1,1,0,0,1,0,0,0,1,1,2,1,1,1,0,0,b(1:9),a(1:4),b(1:6),0,1,1,0,0,2,1,0,0,c(1:34),b(1:6),0,1,...
        a(1:4),b(1:6),2,2,0,0,1,0,1,2,b(1:9),2,1,1,a(1:5),1,2,1,0,1,2,1,1,1,2,b(1:6),0,1,1,1,0,2,1,1,0,c(1:34),1,0,0,0,1,0,0,1,0,0,b(1:5),c(1:5),1,a(1:5),1,1,0,b(1:7),0,0,c(1:6),1,0,1,0,0,0,1,0,b(1:6),0,1,1,1,0,b(1:4),0,c(1:34),0,1,0,1,1,0,0,b(1:4),0,1,1,2,2,1,1,1,2,1,1,1,a(1:7),1,0,1,0,0,1,1,0,1,2,2,1,1,c(1:5),0,0,2,b(1:8),0,1,0,b(1:4),0,0,c(1:33),0,0,0,1,0,1,1,0,1,0,b(1:7),2,1,2,2,1,0,1,a(1:8),b(1:5),a(1:6),1,2,1,0,0,1,a(1:5),1,2,1,1,1,0,1,1,1,0,1,2,2,1,1,c(1:33),0,0,1,1,0,1,0,1,0,0,0,1,1,1,0,1,1,c(1:4),a(1:5),1,1,0,0,1,1,0,b(1:4),a(1:7),1,1,1,0,1,2,1,1,2,0,1,1,2,b(1:6),0,b(1:5),c(1:32),1,0,1,0,1,0,1,0,1,1,1,0,0,1,1,0,1,2,1,1,0,0,0,1,a(1:5),1,1,0,b(1:4),2,1,a(1:4),1,1,a(1:5),1,1,a(1:4),b(1:10),2,b(1:4),c(1:32),0,0,0,1,1,1,0,1,1,1,a(1:7),1,a(1:6),1,a(1:4),b(1:6),2,2,2,1,c(1:9),1,1,0,0,0,1,1,2,2,b(1:6),0,b(1:5),0,c(1:31),1,0,1,0,1,1,1,0,b(1:6),a(1:5),1,a(1:5),1,0,1,...
        0,0,0,1,1,1,0,1,1,0,0,1,1,2,2,2,1,0,1,2,1,1,1,0,0,1,0,1,0,1,1,2,b(1:10),0,c(1:31),0,0,0,b(1:9),a(1:8),1,0,1,0,0,0,1,0,0,1,0,0,0,1,0,b(1:5),0,0,1,2,2,1,0,1,0,1,1,a(1:4),b(1:5),0,b(1:4),0,0,1,2,1,1,c(1:29),1,0,1,0,0,1,1,1,0,b(1:4),0,2,b(1:7),a(1:9),b(1:4),0,0,1,1,2,b(1:5),c(1:6),0,1,1,1,0,0,b(1:5),0,b(1:10),c(1:29),0,1,1,0,0,b(1:9),2,1,1,2,b(1:6),a(1:5),1,1,0,0,1,0,1,0,0,1,2,0,c(1:4),0,1,a(1:4),1,2,a(1:4),b(1:4),0,1,0,b(1:7),0,1,c(1:29),1,0,0,0,1,0,b(1:5),0,1,1,0,b(1:7),2,1,1,1,0,0,0,1,1,0,0,1,0,b(1:5),c(1:6),0,1,2,1,1,a(1:4),1,2,1,1,1,0,b(1:4),2,1,1,1,0,1,1,1,c(1:29),1,0,0,b(1:7),0,b(1:6),2,2,b(1:8),0,0,1,a(1:4),1,0,1,1,0,0,c(1:9),1,0,1,1,0,0,0,b(1:5),0,b(1:10),c(1:30),0,0,b(1:7),0,1,0,2,1,1,1,2,1,1,0,1,1,0,0,0,1,1,a(1:8),1,2,1,0,c(1:6),1,0,0,1,2,1,1,0,0,1,0,b(1:4),0,b(1:12),c(1:29),0,0,b(1:6),0,b(1:4),2,b(1:8),a(1:10),1,0,0,b(1:4),0,1,c(1:5),b(1:4),0,0,b(1:11),2,1,0,...
        b(1:7),c(1:28),0,1,1,1,0,b(1:4),0,2,1,1,1,2,1,2,2,1,2,1,1,1,a(1:6),1,0,0,0,1,0,0,1,a(1:5),c(1:8),1,0,0,2,0,0,2,b(1:5),2,b(1:11),c(1:28),a(1:4),b(1:13),2,b(1:4),0,1,a(1:9),1,0,0,1,1,a(1:4),1,1,2,2,a(1:5),1,0,0,0,b(1:15),0,1,1,1,c(1:28),0,1,0,b(1:5),0,1,1,c(1:4),1,2,2,b(1:4),0,0,0,1,a(1:5),1,2,b(1:5),c(1:9),0,0,1,2,0,0,b(1:8),2,1,1,2,2,1,2,2,2,b(1:4),c(1:27),1,0,0,1,1,0,1,0,0,1,2,1,c(1:4),1,2,b(1:5),a(1:4),1,0,0,0,b(1:7),0,0,1,c(1:4),0,1,a(1:7),b(1:21),c(1:28),0,0,1,0,0,1,0,0,1,2,2,2,b(1:4),2,b(1:5),a(1:6),2,0,1,1,1,0,0,0,1,1,1,0,c(1:7),0,0,b(1:9),0,b(1:9),2,1,1,0,1,1,c(1:27),0,1,1,1,0,b(1:4),2,2,1,2,1,1,1,2,2,b(1:4),a(1:4),1,0,1,1,0,1,1,2,0,1,0,0,c(1:8),a(1:6),b(1:10),2,b(1:8),0,0,2,1,c(1:26),0,1,1,1,0,0,1,0,1,2,1,2,1,1,2,1,2,2,1,1,2,1,0,0,1,1,0,0,1,1,1,0,2,b(1:6),c(1:8),a(1:5),b(1:20),0,0,1,1,c(1:26),0,1,1,1,0,b(1:4),2,2,2,b(1:5),2,1,1,1,2,1,2,1,0,1,0,1,1,0,0,...
        b(1:6),c(1:5),a(1:6),1,0,0,b(1:4),2,b(1:13),0,0,1,0,1,1,c(1:26),b(1:8),2,b(1:4),2,1,2,2,b(1:5),2,2,b(1:7),0,1,2,2,1,1,0,c(1:5),a(1:7),b(1:14),0,b(1:5),0,b(1:5),c(1:25),0,1,1,1,0,1,0,0,2,1,2,1,2,2,2,b(1:10),a(1:5),1,2,0,b(1:5),0,c(1:4),a(1:7),1,1,0,b(1:5),2,b(1:11),0,b(1:5),c(1:25),0,b(1:4),0,0,0,2,2,1,2,2,1,1,2,1,1,1,2,b(1:7),0,0,0,1,0,0,0,b(1:5),0,c(1:4),a(1:6),b(1:6),2,b(1:5),0,b(1:5),0,1,0,b(1:7),c(1:24),0,b(1:4),0,0,1,2,1,1,2,1,0,1,1,1,0,1,0,b(1:7),0,0,1,1,1,0,b(1:6),0,2,2,2,a(1:5),2,1,1,2,b(1:23),0,1,1,c(1:23),0,b(1:5),0,0,1,2,1,1,a(1:4),1,a(1:4),1,1,2,1,1,1,0,0,1,0,1,0,0,1,1,1,0,1,1,0,2,2,2,a(1:4),1,2,1,1,2,1,1,1,0,b(1:14),0,1,1,1,0,0,1,1,1,c(1:22),0,0,b(1:4),0,2,1,2,1,a(1:5),1,0,0,0,1,0,1,1,2,1,1,0,1,a(1:6),b(1:5),0,2,2,a(1:5),2,0,b(1:5),0,0,2,b(1:6),2,b(1:7),0,b(1:7),c(1:21),0,1,0,b(1:5),2,1,2,1,1,0,1,0,1,a(1:5),1,0,0,b(1:4),2,0,1,1,1,0,1,2,1,1,1,0,0,0,2,...
        a(1:5),2,0,1,1,1,2,1,0,0,b(1:4),2,b(1:14),0,1,1,1,c(1:21),b(1:4),0,1,1,0,0,0,1,1,1,0,0,0,1,1,0,1,a(1:5),b(1:4),0,0,1,1,2,b(1:7),0,1,2,a(1:4),1,2,b(1:4),0,b(1:4),0,b(1:17),0,1,2,1,c(1:20),0,1,1,1,0,0,1,a(1:4),1,1,0,0,0,1,1,0,1,1,1,2,0,1,0,1,1,1,0,1,2,1,2,0,0,1,1,1,0,0,2,0,2,a(1:5),b(1:8),0,1,0,b(1:22),c(1:19),0,1,1,0,1,a(1:5),1,a(1:9),1,1,0,b(1:5),0,1,a(1:4),1,0,0,1,1,0,0,1,1,1,a(1:6),b(1:18),2,2,b(1:13),c(1:18),0,0,0,1,1,2,1,0,1,0,1,0,1,1,a(1:4),1,0,0,0,b(1:4),0,1,a(1:9),b(1:5),2,2,1,a(1:4),1,0,b(1:4),0,b(1:7),0,b(1:4),2,1,1,1,0,b(1:5),2,1,1,1,0,1,c(1:18),0,0,0,1,1,1,0,0,0,1,0,1,1,a(1:8),b(1:5),0,1,0,1,0,0,1,a(1:4),b(1:5),2,a(1:8),b(1:15),0,1,1,1,2,b(1:5),2,b(1:7),c(1:17),0,0,b(1:7),0,0,1,1,0,0,1,1,0,1,a(1:4),1,a(1:6),1,1,a(1:7),b(1:5),a(1:7),b(1:20),2,1,1,1,0,b(1:9),c(1:17),0,1,0,b(1:7),0,1,1,0,1,0,1,0,0,1,0,0,0,1,1,0,0,0,1,0,1,0,0,1,0,0,0,b(1:5),a(1:9),...
        b(1:4),0,b(1:13),0,1,1,2,1,1,0,b(1:9),c(1:15),a(1:5),1,1,1,0,0,1,0,1,0,0,1,0,0,0,1,2,2,2,1,2,1,1,0,0,0,b(1:4),a(1:4),1,0,0,1,0,1,a(1:7),1,0,1,1,0,b(1:15),2,b(1:13),0,0,c(1:15),0,0,0,1,a(1:5),1,a(1:4),1,1,c(1:4),1,2,b(1:5),2,1,0,0,0,1,1,a(1:6),b(1:4),a(1:6),1,0,b(1:19),2,b(1:5),0,1,1,2,2,1,1,2,0,1,c(1:14),0,0,0,1,a(1:6),1,a(1:4),2,2,1,2,b(1:4),c(1:5),1,1,1,0,0,1,1,a(1:5),b(1:5),a(1:4),1,0,0,0,b(1:5),0,b(1:13),2,2,2,b(1:11),0,1,c(1:14),a(1:11),1,1,2,2,1,2,b(1:4),c(1:4),1,1,c(1:4),1,1,1,0,0,0,1,a(1:4),1,1,1,a(1:4),1,a(1:4),b(1:6),0,b(1:11),0,1,2,2,b(1:7),2,1,1,0,1,c(1:12),a(1:4),1,0,0,1,0,1,1,0,0,1,2,2,1,1,2,1,1,c(1:5),1,1,1,c(1:5),1,1,2,2,0,1,1,0,0,b(1:6),0,1,1,1,0,0,b(1:7),0,b(1:13),2,2,2,b(1:9),0,1,0,c(1:11),1,0,0,0,1,1,0,b(1:6),2,2,2,1,1,1,c(1:5),0,0,c(1:12),1,0,1,0,0,b(1:10),2,0,b(1:14),0,0,b(1:4),0,0,2,2,b(1:10),0,0,c(1:10),0,1,0,0,1,0,0,1,0,b(1:4),2,2,...
        1,1,2,1,c(1:4),1,1,0,1,c(1:5),1,c(1:5),0,0,0,1,0,1,1,1,0,1,1,0,b(1:5),0,b(1:6),2,b(1:7),0,0,1,0,b(1:5),2,1,0,b(1:7),0,1,1,c(1:9),1,1,0,0,0,1,0,1,1,1,0,0,b(1:4),2,2,2,1,2,2,b(1:4),0,1,2,2,2,1,1,c(1:4),1,a(1:4),1,1,0,1,1,0,b(1:7),0,b(1:15),0,1,1,0,1,1,0,0,0,2,1,1,0,b(1:8),c(1:11),a(1:5),b(1:4),0,0,1,1,c(1:7),1,2,1,1,0,1,c(1:4),1,1,2,2,1,0,0,1,a(1:4),b(1:5),0,b(1:5),0,0,b(1:21),0,b(1:5),0,1,1,2,1,2,1,0,0,c(1:11),a(1:6),1,1,1,0,1,1,1,c(1:8),1,2,a(1:4),1,1,0,0,1,a(1:5),1,a(1:4),1,1,1,0,1,1,0,0,1,0,0,0,b(1:6),0,1,1,0,2,1,0,1,1,0,1,0,0,1,1,1,0,1,1,0,2,1,1,0,1,1,1,2,0,0,0,c(1:11),1,1,0,b(1:4),0,1,1,1,c(1:4),1,1,2,2,2,1,0,1,a(1:8),1,1,a(1:4),1,a(1:4),1,1,0,b(1:6),0,0,0,b(1:9),0,0,1,1,0,1,1,1,0,1,1,0,0,1,1,1,0,2,2,1,1,1,2,1,1,0,0,1,c(1:10),b(1:13),c(1:7),b(1:4),0,1,1,a(1:6),2,a(1:4),1,a(1:4),b(1:6),0,1,1,1,0,1,1,1,2,1,1,2,2,b(1:4),2,1,0,0,1,0,1,0,1,a(1:5),2,b(1:8),...
        0,0,1,c(1:9),1,1,1,0,1,1,2,2,1,1,1,0,1,1,c(1:6),1,0,0,1,1,0,0,1,0,0,0,1,1,0,2,0,0,1,0,1,a(1:4),1,2,1,2,1,0,b(1:4),0,0,b(1:7),2,1,1,0,1,1,1,0,b(1:6),0,b(1:8),2,0,1,2,1,1,c(1:9),1,1,0,1,0,b(1:7),0,1,1,0,1,2,b(1:4),0,1,1,1,0,1,a(1:5),1,a(1:4),1,a(1:7),b(1:4),0,1,0,0,1,0,0,b(1:6),2,1,1,1,a(1:4),b(1:5),0,0,b(1:4),2,1,2,1,1,1,0,2,2,1,1,c(1:10),b(1:4),0,1,0,1,0,1,1,0,1,0,0,b(1:4),0,0,1,1,0,1,1,a(1:10),1,a(1:5),1,0,0,0,b(1:6),0,1,0,1,1,2,1,1,2,1,1,0,1,1,0,0,0,1,1,1,0,0,1,0,0,0,1,0,2,2,1,2,2,0,0,0,1,1,1,c(1:11),1,0,0,1,0,0,0,b(1:5),0,1,1,1,0,0,b(1:6),0,1,a(1:4),1,a(1:4),1,1,0,1,1,0,0,0,1,0,0,1,1,1,a(1:4),1,0,b(1:11),0,1,0,0,1,1,1,0,1,1,0,0,0,1,2,2,2,1,2,1,1,0,1,1,1,c(1:11),1,1,1,0,0,1,0,0,1,0,1,1,0,1,1,0,b(1:5),0,0,1,0,0,0,1,1,2,a(1:5),1,0,0,1,1,a(1:6),1,0,1,1,0,1,1,1,0,0,b(1:5),2,1,a(1:5),b(1:7),a(1:4),2,2,2,b(1:4),0,1,2,2,1,c(1:11),1,0,1,a(1:4),1,1,0,0,1,0,1,0,...
        1,1,1,0,0,1,1,a(1:5),1,1,a(1:6),1,0,0,1,a(1:7),1,0,1,1,0,1,0,1,0,0,b(1:9),a(1:4),1,1,1,0,1,0,1,0,1,2,b(1:4),0,1,0,0,0,c(1:14),0,1,a(1:8),1,0,1,1,0,0,0,1,0,0,1,1,0,0,1,1,1,a(1:11),1,a(1:5),b(1:6),0,1,1,0,0,0,1,0,b(1:6),0,0,b(1:6),0,1,1,0,0,2,2,0,0,1,0,1,1,0,0,0,c(1:14),0,0,0,1,1,a(1:4),1,0,1,1,1,0,b(1:4),0,1,1,1,0,1,0,b(1:4),0,0,0,1,a(1:13),1,2,1,0,1,1,0,0,0,b(1:6),0,1,0,b(1:8),0,1,0,0,2,0,0,1,0,1,0,1,0,0,0,c(1:14),a(1:4),1,a(1:6),1,0,1,1,1,0,b(1:4),0,0,1,1,1,a(1:11),1,a(1:4),2,0,0,0,b(1:5),0,1,0,0,0,b(1:7),0,b(1:5),0,1,1,a(1:4),1,2,b(1:4),0,0,0,1,0,1,c(1:15),0,1,a(1:5),1,0,1,0,1,1,0,0,0,1,0,0,1,0,2,a(1:14),1,0,0,0,1,0,0,1,0,b(1:4),0,2,2,0,0,b(1:8),0,0,1,1,1,0,0,0,1,0,1,1,1,0,2,1,1,0,1,1,a(1:4),c(1:16),1,0,1,1,a(1:5),1,0,0,1,0,1,1,0,1,0,2,a(1:11),1,1,1,0,2,1,0,0,1,0,b(1:9),0,1,0,0,0,b(1:5),0,1,1,0,b(1:4),a(1:6),1,1,2,b(1:4),a(1:4),c(1:17),b(1:5),a(1:4),...
        1,1,0,0,1,1,1,a(1:6),1,0,0,b(1:11),0,b(1:5),0,2,0,1,0,0,1,1,0,1,0,0,b(1:13),0,1,1,0,0,b(1:4),2,1,1,1,0,0,0,1,0,c(1:17),0,0,0,1,0,0,0,1,1,1,2,2,2,0,0,2,1,0,1,a(1:5),1,2,2,2,1,c(1:6),1,1,2,2,b(1:4),0,b(1:5),0,1,1,0,0,b(1:8),2,b(1:6),0,0,0,1,1,1,2,2,1,1,1,a(1:4),c(1:17),0,0,1,a(1:6),1,1,2,2,1,2,2,1,1,c(1:4),1,2,2,2,b(1:5),2,2,1,2,2,1,2,2,2,1,2,1,0,0,b(1:5),0,1,1,0,0,b(1:8),2,1,1,1,0,b(1:6),2,2,1,1,0,1,1,a(1:4),c(1:13),1,0,1,a(1:9),1,1,1,2,b(1:4),2,1,1,1,2,2,0,1,1,2,1,2,2,1,c(1:7),1,2,2,1,1,1,0,b(1:12),0,b(1:9),0,0,b(1:4),2,b(1:7),a(1:4),c(1:14),b(1:4),a(1:7),1,1,c(1:4),b(1:4),2,1,1,2,1,1,0,1,1,2,2,2,1,1,1,2,1,2,1,1,1,2,1,2,2,b(1:11),0,1,1,0,b(1:5),0,0,0,1,1,0,b(1:9),0,1,1,0,0,0,c(1:14),b(1:5),a(1:5),1,0,1,1,2,2,1,1,c(1:5),1,1,0,1,0,0,1,2,1,2,2,1,2,2,2,1,1,2,2,1,c(1:4),b(1:12),2,1,0,1,1,0,1,1,a(1:5),b(1:5),2,2,1,1,1,0,1,1,0,0,1,c(1:14),b(1:4),0,0,0,...
        1,0,0,1,0,0,c(1:7),1,c(1:4),0,1,1,a(1:5),c(1:10),1,2,2,1,1,0,0,b(1:5),0,1,0,0,1,1,0,0,0,1,1,1,a(1:4),b(1:10),0,0,1,1,0,0,c(1:16),0,0,0,1,0,0,1,0,0,1,0,0,1,1,2,2,2,1,c(1:5),0,1,0,1,0,1,1,0,0,1,2,2,1,1,2,2,1,2,1,1,2,2,b(1:5),2,1,1,1,0,2,1,0,1,1,0,b(1:4),0,0,0,b(1:8),0,1,1,1,0,1,1,0,0,c(1:19),0,1,1,1,0,1,0,0,1,0,0,1,c(1:6),1,1,2,0,0,1,2,0,0,1,1,0,1,1,c(1:11),1,0,b(1:6),0,1,2,1,0,1,1,0,1,1,0,1,1,0,b(1:11),0,1,1,1,0,0,c(1:21),1,1,1,0,0,0,1,0,0,1,1,c(1:9),1,0,1,2,0,0,1,0,0,1,c(1:5),1,c(1:4),1,2,1,0,b(1:5),0,0,1,1,0,0,1,1,0,0,0,1,1,0,0,b(1:8),0,0,1,0,1,1,0,0,c(1:26),1,1,0,0,1,0,1,c(1:8),0,0,1,1,a(1:6),1,1,0,c(1:10),1,0,b(1:5),0,1,1,2,0,0,1,2,1,0,1,1,1,0,b(1:4),0,1,1,0,0,1,1,1,a(1:4),c(1:28),0,1,1,1,0,1,1,c(1:4),1,2,2,0,0,1,1,0,0,0,1,1,0,0,1,1,1,c(1:6),1,2,b(1:4),0,0,0,b(1:5),0,0,1,1,1,0,1,1,2,0,b(1:4),0,1,0,0,0,1,1,1,a(1:4),c(1:29),0,1,1,0,1,c(1:6),1,2,0,...
        1,1,1,0,0,0,1,1,0,0,2,1,1,1,c(1:5),1,2,0,2,1,1,0,0,0,1,1,1,2,b(1:6),0,1,2,1,1,1,0,1,0,0,0,1,0,1,1,1,0,0,0,1,c(1:30),1,0,1,0,1,1,c(1:6),0,0,1,1,2,1,a(1:6),1,2,1,1,1,c(1:6),0,0,1,0,0,0,b(1:5),0,b(1:5),2,2,1,2,1,1,2,1,2,0,b(1:4),0,0,0,1,1,1,c(1:15),1,c(1:14),0,0,1,1,0,0,1,2,2,2,1,2,2,0,2,1,1,1,0,0,0,1,0,0,0,2,2,1,1,2,2,1,2,2,1,0,0,1,1,0,0,0,1,2,1,2,0,0,1,1,1,0,0,1,2,2,1,c(1:4),b(1:4),a(1:4),1,1,c(1:31),0,1,0,1,0,1,1,2,1,c(1:4),0,1,1,a(1:10),2,b(1:5),2,1,1,0,1,1,1,0,0,1,1,0,2,1,0,0,1,1,1,0,1,1,1,c(1:4),b(1:5),0,0,0,1,1,1,c(1:33),a(1:5),1,2,1,0,2,2,2,1,0,1,1,0,1,0,0,1,a(1:5),1,1,0,1,2,1,1,0,0,1,1,0,0,0,1,0,1,1,0,0,0,b(1:8),c(1:5),1,0,1,0,0,1,1,1,c(1:34),0,0,b(1:5),2,2,1,2,1,1,0,0,1,1,0,0,1,1,a(1:6),1,1,0,1,1,1,a(1:8),2,1,1,0,0,0,b(1:4),0,b(1:4),2,2,2,b(1:4),0,1,0,1,1,c(1:34),1,0,1,1,1,0,1,a(1:7),1,2,1,0,1,0,0,1,1,a(1:4),b(1:6),a(1:6),1,2,1,1,...
        a(1:6),b(1:8),2,1,1,0,0,b(1:5),c(1:36),0,1,1,0,0,0,1,1,a(1:5),1,2,2,1,2,1,1,0,0,1,1,a(1:14),1,1,a(1:7),b(1:4),0,0,1,1,1,2,2,0,0,1,1,1,0,1,c(1:38),a(1:6),2,0,0,1,0,0,0,1,1,0,1,1,a(1:19),1,0,0,0,1,0,0,0,b(1:12),0,b(1:5),c(1:40),0,0,0,1,0,0,0,1,1,0,0,0,2,a(1:10),c(1:6),a(1:7),1,a(1:8),1,1,2,b(1:7),0,0,1,1,1,0,c(1:42),a(1:8),1,0,1,1,a(1:5),c(1:14),a(1:4),1,1,a(1:4),1,0,0,0,1,1,0,b(1:8),0,1,0,c(1:44),a(1:8),1,0,1,1,1,a(1:4),c(1:14),0,1,0,1,1,1,0,0,1,1,0,0,0,b(1:8),2,0,1,2,0,c(1:45),0,1,a(1:8),1,a(1:6),c(1:15),0,1,1,1,a(1:9),1,1,1,2,1,1,1,0,0,2,1,0,c(1:46),0,1,0,0,1,a(1:6),1,a(1:4),c(1:16),1,1,0,1,0,1,1,2,2,a(1:4),b(1:6),0,1,2,1,c(1:47),0,1,1,2,0,0,1,0,0,1,0,0,0,1,0,0,0,c(1:16),0,b(1:4),2,2,2,a(1:5),b(1:5),0,c(1:51),1,0,1,2,0,1,0,1,1,2,1,2,a(1:4),c(1:17),1,c(1:6),a(1:4),b(1:6),0,c(1:53),0,1,1,1,c(1:5),0,1,1,0,0,c(1:23),1,1,1,0,0,b(1:6),0,c(1:56),0,...
        b(1:4),0,1,0,1,1,c(1:24),1,1,1,0,2,1,0,0,1,1,1,0,c(1:29),1,c(1:31),1,0,0,0,c(1:24),b(1:11),0,0,c(1:90),b(1:10),0,0,c(1:90),1,0,b(1:5),0,1,0,0,0,c(1:92),b(1:8),0,1,c(1:96),b(1:4),c(1:237)],[102,137]));set(gca,'xlim',[-40,178],'ylim',[-23,126]);colormap(gray);axis off;drawnow;
spm_ver = spm('ver','',1);
switch(lower(spm_ver)),
    case 'spm99', spm_ver=1;
    case 'spm2', spm_ver=2;
    case 'spm5', spm_ver=5;
    case {'spm8','spm8b'}, spm_ver=8;
    otherwise, disp(['Warning! unrecognized SPM version ',spm_ver]); spm_ver=5;
end
data.gui.spm_ver=spm_ver;
data.handles=handles;
data.params=params;
set(handles(1),'userdata',data);
% UPDATES ALREADY-DEFINED VALUES
if ~isempty(params.sources), rex_gui([],[],'sources',handles(1),0); end
if ~isempty(params.rois), rex_gui([],[],'rois',handles(1),0); end
if ~isempty(params.conjunction_mask), rex_gui([],[],'conjunction',handles(1),0); end
subplot(212);cla;
% PERFORM ADDITIONAL STEPS IF ANY
for n1=1:length(params.steps), rex_gui([],[],params.steps{n1},handles(1),0); end
varargout={[],[],[]};
return




% CALLBACK FUNCTION FOR GUI
function data=rex_gui(varargin);
%disp(varargin)
option=varargin{3};
if nargin<4, fig=gcbf; else, fig=varargin{4}; end
if nargin<5, interactive=1; else, interactive=varargin{5}; end
if isstruct(fig), data=fig; fig=[]; else, data=get(fig,'userdata'); end
switch(option),
    case 'sources',
        if ~isempty(data.params.spm_file), temp=data.params.spm_file; else, temp=data.params.sources; end
        if interactive,
            if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select files to extract from');
            else,                       temp=spm_select(Inf,'SPM\.mat$|\.img$|\.nii$','Select files to extract from',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
        end
        if ~isempty(temp),
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                hf=msgbox('Loading header files. Please wait...');
                data.params.spm_file=deblank(temp);
                data.params.SPM=load(data.params.spm_file,'SPM');
                data.params.sources=strvcat(data.params.SPM.SPM.xY.VY(:).fname);
                try,
                    data.params.VF=data.params.SPM.SPM.xY.VY;
                    temp=spm_read_vols(data.params.VF(1));
                catch,
                    cwd=pwd;[filepath,nill,nill]=fileparts(data.params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath);
                    data.params.VF=spm_vol(data.params.sources);
                    cd(cwd);
                end
                set(data.handles(3),'string',[num2str(length(data.params.VF)),' files selected'],'foregroundcolor','g');
                close(hf);
            else,
                data.params.spm_file='';
                data.params.sources=temp;
                hf=msgbox('Loading header files. Please wait...');data.params.VF=spm_vol(temp);close(hf);
                set(data.handles(3),'string',[num2str(length(data.params.VF)),' files selected'],'foregroundcolor','g');
            end
            set(fig,'userdata',data);
        end
        if ~(isempty(data.params.sources) || isempty(data.params.rois)),
            set(data.handles([9,10,12]),'enable','on');
        end
    case 'rois',
        temp=data.params.rois;
        if interactive,
            if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select files defining ROIs (image or .tal files)');
            else,                       temp=spm_select(Inf,'\.tal$|\.img$|\.nii$','Select files to extract from',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
        end
        if ~isempty(temp),
            data.params.rois=temp;
            set(data.handles(5),'string',[num2str(size(temp,1)),' files selected'],'foregroundcolor','g');
            set(fig,'userdata',data);
        end
        if ~(isempty(data.params.sources) || isempty(data.params.rois)),
            set(data.handles(9),'enable','on');
        end
    case 'level',
        value=get(data.handles(6),'value');
        switch(value),
            case 1, %'Extract data from each ROI'
                data.params.level='ROIs';
                set(data.handles(7),'enable','on');
            case 2, %'Extract data from each cluster'
                data.params.level='clusters';
                set(data.handles(7),'enable','on');
            case 3, %'Extract data from each peak'
                temp=inputdlg({'Minimum distance between peaks (mm)?','Maximum number of peaks per cluster?'},'',1,{num2str(data.params.mindist),num2str(data.params.maxpeak)});
                if ~isempty(temp)&&~isempty(str2num(temp{1}))&&~isempty(str2num(temp{2})),
                    data.params.mindist=max(0,str2num(temp{1}));
                    data.params.maxpeak=max(1,str2num(temp{2}));
                    data.params.level='peaks';
                    set(data.handles(7),'enable','on');
                end
            case 4, %'Extract data from each voxel'
                data.params.level='voxels';
                set(data.handles(7),'enable','off');
        end
        set(fig,'userdata',data);
    case 'conjunction',
        value=get(data.handles(11),'value');
        switch(value),
            case 1, %'no conjunction mask'
                data.params.conjunction_mask='';
            case 2, %'use conjunction mask'
                temp=data.params.conjunction_mask;
                if interactive,
                    if data.gui.spm_ver<=2,     temp=spm_get(Inf,'*','Select conjunction mask(s)');
                    else,                       temp=spm_select(Inf,'\.img$|\.nii$','Select conjunction mask(s)',mat2cell(temp,ones(size(temp,1),1),size(temp,2))); end
                end
                if ~isempty(temp),
                    hf=msgbox('Loading header files. Please wait...');data.params.VM=spm_vol(temp);close(hf);
                    data.params.conjunction_mask=temp;
                else,
                    data.params.conjunction_mask='';
                    set(data.handles(11),'value',1);
                end
        end
        set(fig,'userdata',data);
    case 'summary_measure',
        value=get(data.handles(7),'value');
        switch(value),
            case 1, %'Extract mean'
                data.params.summary_measure='mean';
            case 2, %'Extract eigenvariate'
                if isfield(data.params,'VF')&&length(data.params.VF)==1, 
                    errordlg(['You need multiple source volumes to perform eigenvariate estimation']); 
                    set(data.handles(7),'value',1);
                else, 
                    data.params.summary_measure='eigenvariate'; 
                    temp=inputdlg('Number of eigenvariates?','',1,{num2str(data.params.dims)});
                    if ~isempty(temp)&&~isempty(str2num(temp{1})),
                        data.params.dims=max(1,str2num(temp{1}));
                    end
                end
            case 3, %'Extract weighted-mean'
                data.params.summary_measure='weighted mean';
            case 4, %'Extract median'
                data.params.summary_measure='median';
            case 5, %'Extract voxel count'
                data.params.summary_measure='count';
        end
        set(fig,'userdata',data);
    case 'scaling',
        value=get(data.handles(8),'value');
        switch(value),
            case 1, %'No scaling'
                data.params.scaling='none';
            case 2, %'global scaling'
                data.params.scaling='global';
            case 3, %'within-roi scaling'
                if isfield(data.params,'VF')&&length(data.params.VF)==1, 
                    errordlg(['You need multiple source volumes to perform within-roi scaling']); 
                    set(data.handles(8),'value',1);
                else, data.params.scaling='roi'; end
        end
        set(fig,'userdata',data);
    case 'output_type',
        value=get(data.handles(13),'value');
        switch(value),
            case 1, %'save'
                data.params.output_type='save';
            case 2, %'saverex'
                data.params.output_type='saverex';
            case 3, %'none'
                data.params.output_type='none';
        end
        set(fig,'userdata',data);
    case 'extract',
        [data.params.ROIdata,data.params.ROInames,data.params.ROIinfo.basis,data.params.ROIinfo.voxels,data.params.ROIinfo.files,data.params.ROIinfo.select,data.params.ROIinfo.trans]=rex_do(data,0);
        if strcmpi(data.params.output_type,'save')||strcmpi(data.params.output_type,'saverex'), params=data.params;save('REX.mat','params'); end
        if ishandle(fig),
            set(data.handles([10,12]),'enable','on');
            set(fig,'userdata',data);
        end
    case {'results','plot'},
        if ~isfield(data.params,'ROIdata'),
            msgbox('You need to extract data first');
            return;
        end
        % selects SPM.mat if not already there
        if isempty(data.params.spm_file),
            temp=spm_select(Inf,'SPM\.mat$','Select SPM.mat file'); 
            [nill,nill,ext]=fileparts(deblank(temp(1,:)));
            if size(temp,1)==1 && strcmp(ext,'.mat'),
                hf=msgbox('Loading header files. Please wait...');
                data.params.spm_file=deblank(temp);
                data.params.SPM=load(data.params.spm_file,'SPM');
                if size(data.params.SPM.SPM.xX.X,1)~=size(data.params.ROIdata,1),
                    close(hf);
                    errordlg(['The number of datapoints extracted (',num2str(size(data.params.ROIdata,1)),') does not match the design size (',num2str(size(data.params.SPM.SPM.xX.X,1)),')']); 
                    data.params.spm_file='';data.params.SPM=[];
                    if ishandle(fig), set(fig,'userdata',data); end
                    return;
                end
                close(hf);
                if ishandle(fig), set(fig,'userdata',data); end
            else, return; end
        end
        switch(option),
            case 'results',
                if ~data.params.gui,
                    s=1:length(data.params.ROInames);
                elseif length(data.params.ROInames)>1,
                    [s,v] = listdlg('PromptString',['Select ROIs '],...
                        'SelectionMode','multiple',...
                        'ListString',strvcat(data.params.ROInames),...
                        'InitialValue',1:length(data.params.ROInames),...
                        'ListSize',[300,300]);
                else, s=1; end
                if length(s)>0,
                    if ~data.params.gui, Ic=1; else, [Ic,data.params.SPM.SPM.xCon] = spm_conman(data.params.SPM.SPM,'T|F',1,'Select contrast','',1); end
                    [cbeta,CI,T,p,P,dof]=rex_test(data.params.SPM.SPM.xX,data.params.ROIdata(:,s),data.params.SPM.SPM.xCon(Ic).c,'figure',data.params.SPM.SPM.xCon(Ic).name,{data.params.ROInames{s}},s,data.params.ROIinfo);
                    if strcmpi(data.params.output_type,'save')||strcmpi(data.params.output_type,'saverex'),
                        params=data.params;
                        params.results=struct('beta',cbeta,'CI',CI,'T',T,'p_unc',p,'p_FDR',P,'dof',dof,'contrast',data.params.SPM.SPM.xCon(Ic).c,'contrast_name',data.params.SPM.SPM.xCon(Ic).name,'ROI_name',{{data.params.ROInames{s}}});
                        save('REX.mat','params');
                        clear params;
                    end
                    
                    if ishandle(fig), set(fig,'userdata',data); end
                end
            case 'plot',
                % selects ROI
                hfig=figure('units','norm','position',[.41,.4,.4,.5],'name','REX plots','numbertitle','off','color','w');
                names=data.params.ROInames;
                nroi=spm_input('Which roi?',-1,'m',{strvcat(names{:})});
                % computes GLM model
                [Beta,ResMS]=rex_modelestimate(data.params.SPM.SPM.xX,data.params.ROIdata);
                % plots
                spm_graph(data.params.ROIdata(:,nroi),Beta(:,nroi),ResMS(:,nroi),data.params.SPM.SPM,hfig);
        end
        
end
return;


% MAIN DATA EXTRACTION ROUTINE
function varargout=rex_do(params,silence);
txt={};ROInames={};
if isfield(params,'params'), gui=params.gui; handles=params.handles; params=params.params; 
else, gui=[]; handles=[]; end
if ~isfield(params,'VF')||isempty(params.VF),varargout={[],[],[],[],[]};return;end
if ~isempty(params.spm_file)&&isfield(params,'SPM')&&isfield(params.SPM,'SPM')&&isfield(params.SPM.SPM,'Sess'),
    sessions=zeros(length(params.VF),1);for n1=1:length(params.SPM.SPM.Sess), sessions(params.SPM.SPM.Sess(n1).row)=n1;end;if any(sessions==0), sessions=sessions+1; end
else,
    sessions=ones(length(params.VF),1);
end
ROIdata=nan+zeros(length(params.VF),size(params.rois,1));
ROIdat=ROIdata;
ROIbasis={};ROIvoxels={};ROIfiles={};ROIselect={};ROItrans={};
rr=1;
clear iM; for i=1:length(params.VF), iM{i}=inv(params.VF(i).mat); end
for r=1:size(params.rois,1)
    roi_path = deblank(params.rois(r,:));
    [roi_path_dir,roi_path_name,roi_path_ext]=fileparts(roi_path);
    
    % Read in coordinates into ROImm
    % -------------------
    switch(roi_path_ext),
        case '.tal',
            [XYZMM,XYZWW,XYZNN,XYZnames]=rex_image(roi_path,params.level,'text',params.select_clusters,params.mindist,params.maxpeak);
        case {'.img','.nii'}
            [XYZMM,XYZWW,XYZNN,XYZnames]=rex_image(roi_path,params.level,'image',params.select_clusters,params.mindist,params.maxpeak);
        otherwise,
            error(['Warning! unrecognized tile format ',roi_path_ext]);
    end
    g=zeros(2,max(sessions));
    for nclusters=1:length(XYZMM),
        if rr>size(ROIdata,2), ROIdata=cat(2,ROIdata,nan+zeros(length(params.VF),1)); end
        if rr>size(ROIdat,2),  ROIdat =cat(2,ROIdat ,nan+zeros(length(params.VF),1)); end
        XYZmm=XYZMM{nclusters};
        XYZww=XYZWW{nclusters};
        XYZnn=XYZNN(nclusters);
        ROInames{rr}=[roi_path_name];
        if iscell(XYZnames)&&length(XYZnames)>=nclusters, ROInames{rr}=[ROInames{rr},'.',XYZnames{nclusters}];
        elseif length(XYZMM)>1, ROInames{rr}=[ROInames{rr},'.cluster',num2str(XYZnn,'%03d')]; end
        if strcmpi(params.summary_measure,'eigenvariate'),rrx=rr-1+(1:min(params.dims(min(r,length(params.dims))),min(length(params.VF),size(XYZmm,2))));tempx='.eig';
        elseif strcmpi(params.level,'voxels'),rrx=rr-1+(1:size(XYZmm,2));tempx='.voxel';
        else, rrx=rr; end
        if length(rrx)>1, namesx=cell(1,length(rrx)); for i=1:length(rrx), namesx{i}=[ROInames{rr},tempx,num2str(i,'%05d')]; end;
        else, namesx={ROInames{rr}}; end
        txt{end+1}=[num2str(size(XYZmm,2)), ' voxels in ROI ',ROInames{rr}];
        if ~silence,disp(txt{end});end
        
        if ~isempty(params.conjunction_mask),
            for nconj=1:length(params.VM),
                c_iM=inv(params.VM(nconj).mat);
                c_XYZ = c_iM(1:3,:)*[XYZmm; ones(1,size(XYZmm,2))];
                m=spm_get_data(params.VM(nconj),c_XYZ);
                XYZmm=XYZmm(:,m>0);
                XYZww=XYZww(:,m>0);
            end
            txt{end+1}=[num2str(size(XYZmm,2)), ' voxels in ROI ',ROInames{rr},' after conjunction'];
            if ~silence,disp(txt{end});end
        end
        
        if strcmpi(params.scaling,'roi'),g=zeros(2,max(sessions));end;
        if strcmpi(params.summary_measure,'eigenvariate'), % first-step: compute covariance structure
            data=zeros(length(params.VF),length(params.VF));
            datamean=zeros(1,size(XYZmm,2));
            for n1=1:1e3:size(XYZmm,2),
                idx=n1:min(size(XYZmm,2),n1-1+1e3);
                temp1=zeros(length(params.VF),length(idx));
                for i=1:length(params.VF),
                    XYZ = iM{i}*[XYZmm(:,idx); ones(1,length(idx))];
                    temp1(i,:) = spm_sample_vol(params.VF(i),XYZ(1,:),XYZ(2,:),XYZ(3,:),0);
                end
                idxnan=find(isnan(temp1));
                if ~isempty(idxnan),
                    datamean(idx)=sum(~isnan(temp1),1);
                    temp1(idxnan)=0;
                    datamean(idx)=sum(temp1,1)./max(eps,datamean(idx));
                    [idxnani,idxnanj]=ind2sub(size(temp1),idxnan);
                    temp1(idxnan)=datamean(idx(idxnanj));
                else, datamean(idx)=mean(temp1,1); end
                data=data+temp1*temp1';
            end
            [q1,q2,nill]=svd(data);
            temp=min(size(q1,2),params.dims(min(r,length(params.dims))));
            data=q1(:,1:temp)*diag(sqrt(diag(q2(1:temp,1:temp))));
            basis=zeros(size(XYZmm,2),temp);
        elseif strcmpi(params.level,'voxels'),
            data=zeros(length(params.VF),size(XYZmm,2));
        end
        step=1;stepend=0;
        if ~isempty(params.spm_file), cwd=pwd;[filepath,nill,nill]=fileparts(params.spm_file);if isempty(filepath),filepath='.';end;cd(filepath); end
        while ~stepend, 
            for i = 1:length(params.VF)
                
                % Convert to XYZmm to pixel coordinates in XYZ
                %iM=inv(params.VF(i).mat);
                XYZ = iM{i}(1:3,:)*[XYZmm; ones(1,size(XYZmm,2))];
                % resample data at voxel in ROI
                d = spm_get_data(params.VF(i),XYZ);
                % mask with NaNrep
                d2=d;
                if isfield(params.VF(i),'dim')&&length(params.VF(i).dim)>3,NaNrep = spm_type(params.VF(i).dim(4),'nanrep');
                elseif isfield(params.VF(i),'dt'), NaNrep = spm_type(params.VF(i).dt(1),'nanrep');
                else, NaNrep=0; end
                if NaNrep==0, d2 = d2(d2~=0); end
                d2 = d2(find(~isnan(d2)));

                if strcmpi(params.level,'voxels'),
                    data(i,:)=d(:)';ROIdat(i,rr)=mean(d2);
                else,
                    switch(lower(params.summary_measure)),
                        case 'mean',
                            ROIdat(i,rr) = mean(d2);
                        case 'eigenvariate',
                            d3=d;if NaNrep==0, d3(~d3)=datamean(~d3); end;d3(isnan(d3))=datamean(isnan(d3));
                            basis=basis+d3(:)*data(i,:);
                            ROIdat(i,rr)=mean(d3);
                            %data(i,:)=d(:)';ROIdat(i,rr)=mean(d2);
                            %if step==1, data(i,:)=d(:)';
                            %elseif step==2, temp=weight.*d(:); temp(isnan(temp))=0; ROIdat(i,rr)=sum(temp); end
                        case 'weighted mean',
                            temp=XYZww(:).*d(:); temp(isnan(temp))=0; ROIdat(i,rr)=sum(temp);
                        case 'median',
                            ROIdat(i,rr) = median(d2);
                        case 'count',
                            ROIdat(i,rr) = sum(d2>0);
                    end
                end
                if ~silence&&length(params.VF)>1,
                    if i==1, hf=waitbar((i/length(params.VF)),['Extracting data (ROI ',num2str(r),'/',num2str(size(params.rois,1)),' cluster ',num2str(nclusters),'/',num2str(length(XYZMM)),')']);
                        set(hf,'color','w');
                    elseif i==length(params.VF), close(hf);
                    elseif (rand<100/length(params.VF)||i==length(params.VF)), waitbar((i/length(params.VF)),hf);
                    end
                end
                if strcmpi(params.scaling,'global')&& nclusters==1, %&& step==1 ,
                    % Computes global scaling
                    g(:,sessions(i))=g(:,sessions(i))+[spm_global(params.VF(i));1];
                end
                if strcmpi(params.scaling,'roi'),% && ~(strcmpi(params.summary_measure,'eigenvariate')&&step==1),
                    % Computes within-roi scaling
                    g(:,sessions(i))=g(:,sessions(i))+[ROIdat(i,rr);1];
                end
                if ~silence && ~isempty(gui) && (rand<5/length(params.VF) ||i==length(params.VF)),% && ~(strcmpi(params.summary_measure,'eigenvariate')&&step==1),
                    figure(handles(1));subplot(212);
                    if size(ROIdat,1)>1, h=plot(ROIdat(:,max(1,rr-10):rr),'-'); for n1=1:length(h),set(h(n1),'color',ones(1,3)*(1-n1/length(h)));end;axis tight;
                    else, bar(ROIdat'); end
                    set(gca,'units','norm','position',[.2,.2,.6,.2],'xcolor','c','ycolor','c');xlabel('volumes/scans');ylabel('raw data');drawnow;
                end
            end
            if strcmpi(params.summary_measure,'eigenvariate'),%step==1&
                basis=basis*diag(1./max(eps,sqrt(sum(basis.^2,1))));
                temp=sign(sum(basis,1))./max(eps,sum(abs(basis),1));
                basis=basis*diag(temp);
                data=data*diag(temp);
%                 for n1=1:size(data,2),data(isnan(data(:,n1)),n1)=mean(data(~isnan(data(:,n1)),n1),1); end;
%                 idxvalid=find(~any(isnan(data),1));
%                 sdata=size(data,2);
%                 weight=zeros(sdata,1);
%                 data=data(:,idxvalid);
%                 %[temp,nill,nill]=svd(data(:,idxvalid)',0);weight(idxvalid)=temp(:,1); weight=weight/sum(weight); step=step+1;
%                 if size(data,1)<length(idxvalid), [q1,q2,q3]=svd(data',0);
%                 else, [q3,q2,q1]=svd(data,0); end
%                 temp=min(size(q3,2),params.dims(min(r,length(params.dims))));
%                 basis=zeros(sdata,temp);
%                 data=q3(:,1:temp)*diag(diag(q2(1:temp,1:temp))'.*sign(sum(q1(:,1:temp),1))./max(eps,sum(abs(q1(:,1:temp)),1)));
%                 basis(idxvalid,:)=q1(:,1:temp)*diag(sign(sum(q1(:,1:temp),1))./max(eps,sum(abs(q1(:,1:temp)),1)));
            else, basis=XYZww(:);end
            stepend=1;
        end
        if ~isempty(params.spm_file), cd(cwd);end
        if strcmpi(params.level,'voxels')||strcmpi(params.summary_measure,'eigenvariate'),ROIdat(:,rrx)=data; end
        ROIbasis{r}{nclusters}=basis;
        ROIfiles{r}{nclusters}=fullfile(pwd,[ROInames{rr},'.rex']);
        ROIvoxels{r}{nclusters}=XYZmm';
        % scaling
        for n1=1:max(sessions),
            idx=find(sessions==n1);
            if ~isempty(idx),
                switch(lower(params.scaling)),
                    case {'global','roi'},  ROIdata(idx,rrx)=ROIdat(idx,rrx)/(sum(g(1,n1))/sum(g(2,n1)))*100;
                    otherwise,              ROIdata(idx,rrx)=ROIdat(idx,rrx);
                end
            end
        end
        % indexes of ROIdata to indexes of ROIbasis/ROIvoxels transformation
        switch(lower(params.level)),
            case {'rois','clusters','peaks'},
                if strcmpi(params.summary_measure,'eigenvariate'),
                    for n1=1:length(rrx), ROItrans{rrx(n1)}={r,nclusters,n1,':'}; end
                else,
                    ROItrans{rrx}={r,nclusters,1,':'};
                end
            case 'voxels',
                for n1=1:length(rrx), ROItrans{rrx(n1)}={r,nclusters,n1,n1}; end
        end
        
        % work out output arguments
        % write output files if requested
        % -------------------------
        if strcmpi(params.output_type,'save')
            name_dat=[ROInames{rr},'.rex.txt'];
            fid = fopen(name_dat,'w');
            if fid == -1, error(['Unable to create new file - please check permissions in current directory.']);end
            txt{end+1}=['OUTPUT DATA FILE: ',char(name_dat)];
            fprintf(fid,[repmat(['%4.4f '],[1,length(rrx)]),'\n'], ROIdata(:,rrx)');
            fclose(fid);
            name_dat=[ROInames{rr},'.rex.mat'];
            R=ROIdata(:,rrx);
            save(name_dat,'R');
            txt{end}=[txt{end},' & ',char(name_dat)];
            name_dat=[ROInames{rr},'.rex.tal'];
            fid = fopen(name_dat,'w');
            if fid == -1, error(['Unable to create new file - please check permissions in current directory.']);end
            txt{end+1}=['OUTPUT .tal FILE : ',char(name_dat)];
            fprintf(fid,'%3.0f %3.0f %3.0f\n',XYZMM{nclusters});
            fclose(fid);
            txt{end+1}=['LOCATION: ',pwd];
            txt{end+1}=' ';
        end
        for i=1:length(rrx), ROInames{rrx(i)}=namesx{i}; end
        rr=rr+length(rrx);
    end
    ROIselect{r}=XYZNN;
end
if ~silence && ~isempty(gui),
    figure('units','norm','position',[.41,.4,.4,.5],'name','REX extract','numbertitle','off','color','w');
    %if size(ROIdata,1)>1, 
        dotwoplots=0;
        if ~isempty(params.spm_file) && isfield(params.SPM.SPM,'xCon') && ~isempty(params.SPM.SPM.xCon) && size(ROIdata,2)<1e3,
            Ic=strmatch('effects of interest',lower(strvcat(params.SPM.SPM.xCon(:).name)),'exact');
            if isempty(Ic), Ic=length(params.SPM.SPM.xCon)+1; params.SPM.SPM.xCon(Ic).c=diag(any(cat(2,params.SPM.SPM.xCon(:).c),2));params.SPM.SPM.xCon(Ic).c(:,~any(params.SPM.SPM.xCon(Ic).c,1))=[];end;
            if ~isempty(Ic)&&~isempty(params.SPM.SPM.xCon(Ic(1)).c), 
                Ic=Ic(1);
                [beta,ResMS]=rex_modelestimate(params.SPM.SPM.xX,ROIdata);
                cbeta=params.SPM.SPM.xCon(Ic).c'*beta;
                SE=sqrt(diag(params.SPM.SPM.xCon(Ic).c'*params.SPM.SPM.xX.Bcov*params.SPM.SPM.xCon(Ic).c)*ResMS);
                CI=1.6449*SE;
                effnames={};for n1=1:size(params.SPM.SPM.xCon(Ic).c,2),effnames{n1}=strcat(params.SPM.SPM.xX.name{find(params.SPM.SPM.xCon(Ic).c(:,n1)~=0)});end
                dotwoplots=1;
            end
        end
        if dotwoplots,
            subplot(212);
            dx=size(cbeta,1)/(numel(cbeta)+3*size(cbeta,1));xx=1*repmat((1:size(cbeta,1))',[1,size(cbeta,2)])+repmat((-(size(cbeta,2)-1)/2:(size(cbeta,2)-1)/2)*dx,[size(cbeta,1),1]);color=get(gca,'colororder');%xxd=.4/size(cbeta,2)/2;
            for n1=1:numel(xx),color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);patch(xx(n1)+dx*[-1,-1,1,1]/2,cbeta(n1)*[0,1,1,0],'k','facecolor',1-(1-color0)/8,'edgecolor','none'); line(xx(n1)+[0,0],cbeta(n1)+CI(n1)*[-1,1],'linewidth',3,'color',color0); end
            hold on; plot([.5,size(cbeta,1)+.5],[0,0],'k-');hold off;
            xlabel('Effects of interest');axis tight;set(gca,'xtick',1:size(cbeta,1),'xticklabel',effnames,'xlim',[0,size(cbeta,1)+1],'xcolor','c','ycolor','c');
            hold on; plot(repmat(.5:size(cbeta,1)+.5,[2,1]),repmat(get(gca,'ylim')',[1,size(cbeta,1)+1]),'k:'); hold off; 
            subplot(211);
        end
        h=plot(ROIdata(:,1:min(2e2,size(ROIdata,2))),'.:'); axis tight;
        set(gca,'xcolor','c','ycolor','c');xlabel('volumes/scans');
        if length(ROInames)>4, temp={ROInames{1:2},ROInames{end-1:end}}; h=h([1,2,end-1,end]);
        else, temp=ROInames; end
        h=legend(h,temp);set(h,'location','northoutside','interpreter','none','box','off');
    %elseif size(ROIdata,2)<1e2, bar(ROIdata'); set(gca,'xtick',1:length(ROInames),'xticklabel',ROInames); 
    %else, plot(ROIdata','.-'); end
    msgbox(txt,'REX output');
end
if ~silence,disp(strvcat(txt{:}));end
varargout={ROIdata,ROInames,ROIbasis,ROIvoxels,ROIfiles,ROIselect,ROItrans};
return;



% READS ROI FILES
function [XYZMM,XYZWW,XYZidx,XYZnames]=rex_image(roi_path,level,type,select,mindist,maxpeak);
[roi_path_dir,roi_path_name,roi_path_ext]=fileparts(roi_path);
switch(lower(type)),
    case 'text',
        XYZmm = spm_load(roi_path)';
        if size(XYZmm,1)~=3,error('The .tal mask file should have 3 columns (x,y,z locations in mm).'),end
        XYZww=ones(1,size(XYZmm,2));
        a.mat=[4,0,0,-94;0,4,0,-130;0,0,4,-76;0,0,0,1];
        xyz=pinv(a.mat)*[XYZmm;ones(1,size(XYZmm,2))];
        xyz=round(xyz(1:3,:));
        b=zeros((max(xyz,[],2)-min(xyz,[],2)+1)');
        idxvoxels=sub2ind(size(b),xyz(1,:)-min(xyz(1,:))+1,xyz(1,:)-min(xyz(1,:))+1,xyz(1,:)-min(xyz(1,:))+1);
        b(idxvoxels)=1;
        C=[];x_rep=0;
        XYZnames=[];
    case 'image',
        a=spm_vol(roi_path);
        b=spm_read_vols(a);
        idxvoxels=find(b>0);
        XYZww=b(idxvoxels)';
        [xt,yt,zt]=ind2sub(a.dim,idxvoxels);
        xyz=[xt,yt,zt]';
        ub=unique(b(idxvoxels));
        if length(ub)>1&&all(rem(ub,1)==0),C=XYZww';x_rep=1;else, C=[];x_rep=0;end;
        if x_rep && ~isempty(dir(fullfile(roi_path_dir,[roi_path_name,'.txt']))),
            XYZnames=textread(fullfile(roi_path_dir,[roi_path_name,'.txt']),'%s','delimiter','\n');
            if length(XYZnames)~=max(ub), XYZnames=[]; end
        else, XYZnames=[]; end
end
if isempty(xyz), XYZMM={};XYZWW={};XYZidx=[];XYZnames={}; return; end
if isempty(C), C=spm_clusters(max(1,round(xyz)));end; % C: cluster per voxel;
c=hist(C,1:max(C)); % c: #voxels per clusters
txt=[];xyzpeak={};
XYZidx=find(c>0);
idxn=[];idx2={};for n1=1:length(XYZidx),idx2{n1}=find(C(:)==(XYZidx(n1))); idxn(n1)=length(idx2{n1}); end
if ~x_rep, [nill,sidxn]=sort(idxn(:));sidxn=flipud(sidxn); else, sidxn=(1:length(idxn))'; end
xyzpeak=cell(1,length(XYZidx));
%clusters=cell(1,length(XYZidx));
k=zeros(1,length(XYZidx));
for n1=1:length(XYZidx),
    k(n1)=idxn(sidxn(n1));
    %clusters{n1}=idxvoxels(idx2{sidxn(n1)});
    temp=XYZww(idx2{sidxn(n1)});idxtemp=find(temp==max(temp));xyzpeak{n1}=mean(xyz(:,idx2{sidxn(n1)}(idxtemp)),2)';
end
if isempty(XYZnames),
    for n1=1:length(XYZidx),
        txt=strvcat(txt,[...
            ['( ',sprintf('%+03.0f ',(a.mat(1:3,:)*[xyzpeak{n1}';1])'),') '],...
            [sprintf('%6d voxels',k(n1))]]);
    end
else,
    for n1=1:length(XYZidx),
        txt=strvcat(txt,[...
            [XYZnames{XYZidx(sidxn(n1))},'  ( ',sprintf('%+03.0f ',(a.mat(1:3,:)*[xyzpeak{n1}';1])'),') '],...
            [sprintf('%6d voxels',k(n1))]]);
    end
end
if ~select, s=1:size(txt,1);
elseif length(XYZidx)>1, 
    [s,v] = listdlg('PromptString',['Select cluster(s) in ',roi_path_name],...
    'SelectionMode','multiple',...
    'ListString',txt,...
    'InitialValue',1:size(txt,1),...
    'ListSize',[300,300]);
else, s=1; end
switch(lower(level)),
    case {'rois','voxels'},
        sidxn=sidxn(s);
        idxin=cat(1,idx2{sidxn});
        XYZWW={XYZww(:,idxin)};
        XYZMM={a.mat(1:3,:)*[xyz(:,idxin);ones(1,length(idxin))]};
        if x_rep, XYZidx=XYZidx(sidxn); else, XYZidx=s; end
        if ~isempty(XYZnames)&&length(s)==1, XYZnames={XYZnames{XYZidx}}; else, XYZnames=[]; end
    case {'clusters','peaks'},
        sidxn=sidxn(s);
        for n1=1:length(s),
            idxin=cat(1,idx2{sidxn(n1)});
            XYZWW{n1}=XYZww(:,idxin);
            XYZMM{n1}=a.mat(1:3,:)*[xyz(:,idxin);ones(1,length(idxin))];
        end
        %if ~isempty(XYZnames), XYZnames={XYZnames{sidxn}}; else, XYZnames=[]; end
        if x_rep, XYZidx=XYZidx(sidxn); else, XYZidx=s; end
        if ~isempty(XYZnames), XYZnames={XYZnames{XYZidx}}; else, XYZnames=[]; end
        if strcmpi(level,'peaks'),
            n0=1;
            for n1=1:length(s),
                peaks=0;
                if length(unique(XYZWW{n1}))>1,
                    idxvox=idx2{sidxn(n1)};
                    idxpeak=1:length(idxvox);
                    sb=[size(b,1);size(b,2);size(b,3)];
                    for n2a=-1:1,for n2b=-1:1,for n2c=-1:1,
                                offset=n2a+sb(1)*n2b+sb(1)*sb(2)*n2c;
                                idxpeak=idxpeak(all(xyz(:,idxvox(idxpeak))>1,1));
                                idxpeak=idxpeak(all(xyz(:,idxvox(idxpeak))<repmat(sb,[1,length(idxpeak)]),1));
                                idxpeak=idxpeak(b(idxvoxels(idxvox(idxpeak)))>=b(idxvoxels(idxvox(idxpeak))+offset));
                                idxpeak=idxpeak(b(idxvoxels(idxvox(idxpeak))+offset)>0);
                                if isempty(idxpeak), break; end
                            end;end;end;
                    if length(idxpeak)>1,
                        [ww,idx]=sort(-XYZWW{n1}(:,idxpeak));
                        idxmax=idx(1);
                        for n2=2:length(idx),
                            if min(sqrt(sum(abs(XYZMM{n1}(:,idxpeak(idx(n2)))*ones(1,length(idxmax))-XYZMM{n1}(:,idxpeak(idxmax))).^2,1)))>mindist,
                                idxmax=[idxmax,idx(n2)];
                                if length(idxmax)>=maxpeak, break; end
                            end
                        end
                        idxmax=idxpeak(idxmax);
                        if length(idxmax)>1,
                            d=zeros([length(idxmax),size(XYZMM{n1},2)]);
                            for n2=1:length(idxmax),d(n2,:)=sqrt(sum(abs(XYZMM{n1}(:,idxmax(n2))*ones(1,size(XYZMM{n1},2))-XYZMM{n1}).^2,1));end
                            [nill,idxc]=min(d,[],1);
                            for n2=1:length(idxmax),
                                idxd=find(idxc==n2);
                                if ~isempty(idxd),
                                    XYZMMnew{n0}=XYZMM{n1}(:,idxd);
                                    XYZWWnew{n0}=XYZWW{n1}(:,idxd);
                                    XYZidxnew(n0)=n0;%XYZidx(n1);
                                    if ~isempty(XYZnames), XYZnamesnew{n0}=[XYZnames{n1},'.',char('a'-1+n2)]; end
                                    n0=n0+1;
                                end
                            end
                            peaks=1;
                        end
                    end
                end
                if ~peaks,
                    XYZMMnew{n0}=XYZMM{n1};
                    XYZWWnew{n0}=XYZWW{n1};
                    XYZidxnew(n0)=n0;%XYZidx(n1);
                    if ~isempty(XYZnames), XYZnamesnew{n0}=XYZnames{n1}; end
                    n0=n0+1;
                end
            end
            XYZMM=XYZMMnew;
            XYZWW=XYZWWnew;
            XYZidx=XYZidxnew;
            if ~isempty(XYZnames), XYZnames=XYZnamesnew; end
        end
end
%[XYZMM,XYZWW,XYZidx,XYZnames]

% ESTIMATES GENERAL LINEAR MODEL IN SPM
function [beta,ResMS]=rex_modelestimate(xX,Y);
[nScan nBeta] = size(xX.X);
KWY   = spm_filter(xX.K,xX.W*Y);
beta  = xX.pKX*KWY;                  %-Parameter estimates
res   = spm_sp('r',xX.xKXs,KWY);     %-Residuals
ResSS = sum(res.^2);                 %-Residual SSQ
ResMS=ResSS/xX.trRV;

% ESTIMATES CONTRAST IN SPM
function [cbeta,CI,T,p,P,dof]=rex_test(xX,Y,c,fig,effnames,roinames,s,ROIinfo);
[beta,ResMS]=rex_modelestimate(xX,Y);
cbeta=c'*beta;
SE=sqrt(diag(c'*xX.Bcov*c)*ResMS);
CI=1.6449*SE;
T=cbeta./SE;
dof=xX.erdf;
p=nan+zeros(size(T));idxvalidT=find(~isnan(T));p(idxvalidT)=1-spm_Tcdf(T(idxvalidT),dof);
p=2*min(p,1-p);
P=fdr(p,2);
if nargin>3,
    hfig=figure('units','norm','position',[.41,.0,.55,.9],'name','REX results','numbertitle','off','color','w');
    subplot(411);
    dx=size(cbeta,1)/(numel(cbeta)+3*size(cbeta,1));xx=1*repmat((1:size(cbeta,1))',[1,size(cbeta,2)])+repmat((-(size(cbeta,2)-1)/2:(size(cbeta,2)-1)/2)*dx,[size(cbeta,1),1]);color=get(gca,'colororder');color(all(~color,2),:)=[];%xxd=.4/size(cbeta,2)/2;
    for n1=1:numel(xx),color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);h=patch(xx(n1)+dx*[-1,-1,1,1]/2,cbeta(n1)*[0,1,1,0],'k','facecolor',1-(1-color0)/4,'edgecolor','none'); if P(n1)<=.05, set(h,'facecolor',color0); end
        h=line(xx(n1)+[0,0],cbeta(n1)+CI(n1)*[-1,1],[1,1],'linewidth',2,'color',1-(1-color0)/4); if P(n1)<=.05, set(h,'color','k'); elseif p(n1)<=.05, set(h,'color',1-(1-color0)/2); end; end
    hold on; plot([.5,size(cbeta,1)+.5],[0,0],'k-');hold off; hh=gca;
    if ~iscell(effnames)&&size(cbeta,1)>1, effnames2={};for n1=1:size(cbeta,1),effnames2{n1}=[effnames,'_contrast',num2str(n1)];end;effnames=effnames2;end
    ylabel('Effect sizes'); set(hh,'xaxislocation','top','xtick',1:size(cbeta,1),'xticklabel',effnames,'xlim',[min(xx(:))-dx,max(xx(:))+dx],'ylim',[min(0,min(cbeta(:)-CI(:)))-1e-4,max(0,max(cbeta(:)+CI(:)))+1e-4]*[1.1,-.1;-.1,1.1],'xcolor','c','ycolor','c');
    for n1=1:numel(xx),color0=color(1+rem(ceil(n1/size(cbeta,1))-1,size(color,1)),:);h=text(xx(n1),min(get(hh,'ylim'))-abs(diff(get(hh,'ylim')))*.05,roinames{ceil(n1/size(cbeta,1))}); set(h,'rotation',-90,'fontsize',8,'color',1-(1-color0)/4,'interpreter','none','buttondownfcn',{@rex_results_gui,'plot',n1}); if P(n1)<=.05, set(h,'color',color0); end; end 
    for n1=1:numel(xx),htick(n1)=line([xx(n1),xx(n1)],get(hh,'ylim'),[-1,-1]);set(htick(n1),'linestyle',':','color','k','visible','off');end 
    uicontrol('style','text','units','norm','position',[.05,.50,.9,.025],'string',sprintf('%-32s%10s%10s%12s%12s','ROI','beta','T','p-unc','p-FDR'),'backgroundcolor','w','foregroundcolor','b','horizontalalignment','left','fontname','monospaced','fontsize',8);
    txt=[];for n1=1:numel(cbeta),txt=strvcat(txt,[[sprintf('%-32s',roinames{ceil(n1/size(cbeta,1))})],[sprintf('%10.2f',cbeta(n1))],[sprintf('%10.2f',T(n1))],[sprintf('%12f',p(n1))],[sprintf('%12f',P(n1))]]); end;txt=strvcat(txt,' ');
    hax=axes('units','norm','position',[.1,.0,.8,.25],'visible','off');
    hl=uicontrol('style','listbox','units','norm','position',[.05,.25,.9,.25],'string',txt,'backgroundcolor','w','foregroundcolor','k','horizontalalignment','left','fontname','monospaced','fontsize',8,'callback',{@rex_results_gui,'list'});
    set(hfig,'userdata',struct('hplot',htick,'haxes',hax,'hlist',hl,'s',s,'ROIinfo',ROIinfo));
end

function rex_results_gui(varargin);
dataobj=get(gcbf,'userdata');
switch(varargin{3}),
    case 'list',
        idx=get(dataobj.hlist,'value');
    case 'plot',
        idx=varargin{4};
        set(dataobj.hlist,'value',idx);
end
set(dataobj.hplot,'visible','off');
if all(idx<=length(dataobj.hplot)&idx>0),
    set(dataobj.hplot(idx),'visible','on');
    idx=dataobj.s(idx);
    Z=dataobj.ROIinfo.basis{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},dataobj.ROIinfo.trans{idx}{3});
    XYZ=dataobj.ROIinfo.voxels{dataobj.ROIinfo.trans{idx}{1}}{dataobj.ROIinfo.trans{idx}{2}}(dataobj.ROIinfo.trans{idx}{4},:);
    
    mip=load('MIP.mat');mip=1+mip.mask_all;
    if length(unique(Z))==1, Z=2+zeros(size(Z));
    else, Z=2+Z/max(abs(Z)); end
    d=spm_project(Z',round(XYZ'),[2,2,2,size(mip)]);
    idx=find(d~=0);mip(idx)=round(34.5+31.5*(d(idx)-2));
    axes(dataobj.haxes);
    image(rot90(mip));axis equal;axis tight;axis off;colormap([1*ones(1,3);.8*ones(1,3);jet(64)]);
    set(gcbf,'currentobject',dataobj.hlist);
    %M=[2,0,0,-92;0,2,0,-128;0,0,2,-74;0,0,0,1];
    %axes(dataobj.haxes);
    %spm_mip([Z',0],[XYZ',zeros(3,1)],M,{'mm' 'mm' 'mm'});axis equal;
else,
    axes(dataobj.haxes);
    cla;
end

function q=fdr(p,dim);
% FDR False discovery rate
% Q=FDR(P); returns vector Q of estimated false discovery rates (set-level q-values) from 
% a vector P of multiple-test false positive levels (uncorrected p-values)
% Q=FDR(P,dim); where P is a matrix computes the fdr along the dimension dim of P
%

if nargin<2, 
    if sum(size(p)>1)==1,dim=find(size(p)>1);
    else, dim=1; end
end
nd=length(size(p)); 
if dim~=1, p=permute(p,[dim,1:dim-1,dim+1:nd]); end

sp=size(p);
q=ones(sp);
N1=sp(1);
N2=prod(sp(2:end));
for n2=1:N2,
    [sp,idx]=sort(p(:,n2));
    qt=N1*sp./(1:N1)';
    min1=nan;
    for n=N1:-1:1,
        min1=min(min1,qt(n));
        q(idx(n),n2)=min1;
    end
end
if dim~=1, q=ipermute(q,[dim,1:dim-1,dim+1:nd]); end


% spm_graph function in SPM8 modified to handle ROI data
function [Y,y,beta,Bcov] = spm_graph(y,beta,ResMS,SPM,Fgraph)

%-Plot
%==========================================================================

% find out what to plot
%--------------------------------------------------------------------------
Cplot = {   'Contrast estimates and 90% C.I.',...
            'Fitted responses',...
            'Event-related responses',...
            'Parametric responses',...
            'Volterra Kernels'};


% ensure options are appropriate
%--------------------------------------------------------------------------
try
    Sess  = SPM.Sess;
catch
    Cplot = Cplot(1:2);
end
%Cplot  = Cplot{spm_input('Plot',-1,'m',Cplot)};
Cplot  = Cplot{spm_input('Plot','!+1','m',Cplot)};

switch Cplot

    % select contrast if
    %----------------------------------------------------------------------
    case {'Contrast estimates and 90% C.I.','Fitted responses'}

        % determine which contrast
        %------------------------------------------------------------------
        Ic    = spm_input('Which contrast?','!+1','m',{SPM.xCon.name});
        TITLE = {Cplot SPM.xCon(Ic).name};
        %if xSPM.STAT == 'P'
        %    TITLE = {Cplot SPM.xCon(Ic).name '(conditional estimates)'};
        %end


        % select session and trial if
        %------------------------------------------------------------------
    case {'Event-related responses','Parametric responses','Volterra Kernels'}

        % get session
        %------------------------------------------------------------------
        s     = length(Sess);
        if  s > 1
            s = spm_input('which session','+1','n1',1,s);
        end

        % effect names
        %------------------------------------------------------------------
        switch Cplot
            case 'Volterra Kernels'
                u = length(Sess(s).Fc);
            otherwise
                u = length(Sess(s).U);
        end
        Uname = {};
        for i = 1:u
            Uname{i} = Sess(s).Fc(i).name;
        end

        % get effect
        %------------------------------------------------------------------
        str   = sprintf('which effect');
        u     = spm_input(str,'+1','m',Uname);

        % bin size
        %------------------------------------------------------------------
        dt    = SPM.xBF.dt;

end

spm('pointer','watch');

%-Extract filtered and whitened data from files
%==========================================================================
try
    %y = spm_get_data(SPM.xY.VY,XYZ);
    y = spm_filter(SPM.xX.K,SPM.xX.W*y);
catch
    % data has been moved or renamed
    %------------------------------------------------------------------
    y = [];
    spm('alert!',{'Original data have been moved or renamed',...
        'Recomendation: please update SPM.xY.P'},...
        mfilename,0);
end
XYZstr = '';%sprintf(' at [%g, %g, %g]',xyz);


%-Compute residuals
%-----------------------------------------------------------------------
if isempty(y)

    % make R = NaN so it will not be plotted
    %----------------------------------------------------------------------
    R   = NaN*ones(size(SPM.xX.X,1),1);

else
    % residuals (non-whitened)
    %----------------------------------------------------------------------
    R   = spm_sp('r',SPM.xX.xKXs,y);

end

%-Get parameter and hyperparameter estimates
%==========================================================================
%if xSPM.STAT ~= 'P'

    %-Parameter estimates:   beta = xX.pKX*xX.K*y;
    %-Residual mean square: ResMS = sum(R.^2)/xX.trRV
    %----------------------------------------------------------------------
    %beta  = spm_get_data(SPM.Vbeta, XYZ);
    %ResMS = spm_get_data(SPM.VResMS,XYZ);
    Bcov  = ResMS*SPM.xX.Bcov;

% else
%     % or conditional estimates with
%     % Cov(b|y) through Taylor approximation
%     %----------------------------------------------------------------------
%     beta  = spm_get_data(SPM.VCbeta, XYZ);
% 
%     if isfield(SPM.PPM,'VB');
%         % Get approximate posterior covariance at ic
%         % using Taylor-series approximation
% 
%         % Get posterior SD beta's
%         Nk=size(SPM.xX.X,2);
%         for k=1:Nk,
%             sd_beta(k,:) = spm_get_data(SPM.VPsd(k),XYZ);
%         end
% 
%         % Get AR coefficients
%         nsess=length(SPM.Sess);
%         for ss=1:nsess,
%             for p=1:SPM.PPM.AR_P
%                 Sess(ss).a(p,:) = spm_get_data(SPM.PPM.Sess(ss).VAR(p),XYZ);
%             end
%             % Get noise SD
%             Sess(ss).lambda = spm_get_data(SPM.PPM.Sess(ss).VHp,XYZ);
%         end
% 
%         % Which block are we in ?
%         % this needs updating s.t xSPM contains labels of selected voxels
%         v = find((SPM.xVol.XYZ(1,:)==XYZ(1))&(SPM.xVol.XYZ(2,:)==XYZ(2))&(SPM.xVol.XYZ(3,:)==XYZ(3)));
%         block_index = SPM.xVol.labels(v);
%         Bcov=zeros(Nk,Nk);
%         for ss=1:nsess,
%             % Reconstuct approximation to voxel wise correlation matrix
%             post_R=SPM.PPM.Sess(ss).block(block_index).mean.R;
%             if SPM.PPM.AR_P > 0
%                 dh=Sess(ss).a(:,1)'-SPM.PPM.Sess(ss).block(block_index).mean.a;
%             else
%                 dh=[];
%             end
%             dh=[dh Sess(ss).lambda(1)-SPM.PPM.Sess(ss).block(block_index).mean.lambda];
%             for i=1:length(dh),
%                 post_R=post_R+SPM.PPM.Sess(ss).block(block_index).mean.dR(:,:,i)*dh(i);
%             end
%             % Get indexes of regressors specific to this session
%             scol=SPM.Sess(ss).col;
%             mean_col_index=SPM.Sess(nsess).col(end)+ss;
%             scol=[scol mean_col_index];
% 
%             % Reconstuct approximation to voxel wise covariance matrix
%             Bcov(scol,scol) = Bcov(scol,scol) + (sd_beta(scol,1)*sd_beta(scol,1)').*post_R;
%         end
% 
%     else
%         Bcov  = SPM.PPM.Cby;
%         for j = 1:length(SPM.PPM.l)
% 
%             l    = spm_get_data(SPM.VHp(j),XYZ);
%             Bcov = Bcov + SPM.PPM.dC{j}*(l - SPM.PPM.l(j));
%         end
%     end
% end
CI    = 1.6449;                 % = spm_invNcdf(1 - 0.05);

spm('pointer','arrow');

%-Colour specifications and index;
%--------------------------------------------------------------------------
Col   = [0 0 0; .8 .8 .8; 1 .5 .5];

switch Cplot

    % plot parameter estimates
    %----------------------------------------------------------------------
    case 'Contrast estimates and 90% C.I.'

        % compute contrast of parameter estimates and 90% C.I.
        %------------------------------------------------------------------
        cbeta = SPM.xCon(Ic).c'*beta;
        SE    = sqrt(diag(SPM.xCon(Ic).c'*Bcov*SPM.xCon(Ic).c));
        CI    = CI*SE;

        contrast.contrast      = cbeta;
        contrast.standarderror = SE;
        contrast.interval      = 2*CI;
        assignin('base','contrast',contrast)

        % bar chart
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        cla
        hold on

        % estimates
        %------------------------------------------------------------------
        h     = bar(cbeta);
        set(h,'FaceColor',Col(2,:))

        % standard error
        %------------------------------------------------------------------
        for j = 1:length(cbeta)
            line([j j],([CI(j) 0 - CI(j)] + cbeta(j)),...
                'LineWidth',6,'Color',Col(3,:))
        end

        title(TITLE,'FontSize',12)
        xlabel('contrast')
        ylabel(['contrast estimate',XYZstr])
        set(gca,'XLim',[0.4 (length(cbeta) + 0.6)])
        hold off

        % set Y to empty so outputs are assigned
        %------------------------------------------------------------------
        Y = [];

        % all fitted effects or selected effects
        %------------------------------------------------------------------
    case 'Fitted responses'

        % predicted or adjusted response
        %------------------------------------------------------------------
        str   = 'predicted or adjusted response?';
        if spm_input(str,'!+1','b',{'predicted','adjusted'},[1 0]);

            % fitted (predicted) data (Y = X1*beta)
            %--------------------------------------------------------------
            Y = SPM.xX.X*SPM.xCon(Ic).c*pinv(SPM.xCon(Ic).c)*beta;
        else

            % fitted (corrected)  data (Y = X1o*beta)
            %--------------------------------------------------------------
            Y = spm_FcUtil('Yc',SPM.xCon(Ic),SPM.xX.xKXs,beta);

        end

        % adjusted data
        %------------------------------------------------------------------
        y     = Y + R;

        % get ordinates
        %------------------------------------------------------------------
        Xplot = {'an explanatory variable',...
                 'scan or time',...
                 'a user specified ordinate'};
        Cx    = spm_input('plot against','!+1','m',Xplot);

        % an explanatory variable
        %------------------------------------------------------------------
        if     Cx == 1

            str  = 'Which explanatory variable?';
            i    = spm_input(str,'!+1','m',SPM.xX.name);
            x    = SPM.xX.xKXs.X(:,i);
            XLAB = SPM.xX.name{i};

            % scan or time
            %--------------------------------------------------------------
        elseif Cx == 2

            if isfield(SPM.xY,'RT')
                x    = SPM.xY.RT*[1:size(Y,1)]';
                XLAB = 'time {seconds}';
            else
                x    = [1:size(Y,1)]';
                XLAB = 'scan number';
            end

            % user specified
            %--------------------------------------------------------------
        elseif Cx == 3

            x    = spm_input('enter ordinate','!+1','e','',size(Y,1));
            XLAB = 'ordinate';

        end

        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        cla
        hold on
        [p q] = sort(x);
        if all(diff(x(q)))
            plot(x(q),Y(q),'LineWidth',4,'Color',Col(2,:));
            plot(x(q),y(q),':','Color',Col(1,:));
            plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(3,:));

        else
            plot(x(q),Y(q),'.','MarkerSize',16,'Color',Col(1,:));
            plot(x(q),y(q),'.','MarkerSize',8, 'Color',Col(2,:));
            xlim = get(gca,'XLim');
            xlim = [-1 1]*diff(xlim)/4 + xlim;
            set(gca,'XLim',xlim)

        end
        title(TITLE,'FontSize',12)
        xlabel(XLAB)
        ylabel(['response',XYZstr])
        legend('fitted','plus error')
        hold off

        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Event-related responses'

        % get plot type
        %--------------------------------------------------------------
        Rplot   = { 'fitted response and PSTH',...
            'fitted response and 90% C.I.',...
            'fitted response and adjusted data'};

        if isempty(y)
            TITLE = Rplot{2};
        else
            TITLE = Rplot{spm_input('plot in terms of','+1','m',Rplot)};
        end

        % plot
        %------------------------------------------------------------------
        switch TITLE
            case 'fitted response and PSTH'


                % build a simple FIR model subpartition (X); bin size = TR
                %----------------------------------------------------------
                BIN         = SPM.xY.RT;
                %BIN         = max(2,BIN);
                xBF         = SPM.xBF;
                U           = Sess(s).U(u);
                U.u         = U.u(:,1);
                xBF.name    = 'Finite Impulse Response';
                xBF.order   = round(32/BIN);
                xBF.length  = xBF.order*BIN;
                xBF         = spm_get_bf(xBF);
                BIN         = xBF.length/xBF.order;
                X           = spm_Volterra(U,xBF.bf,1);
                k           = SPM.nscan(s);
                X           = X([0:(k - 1)]*SPM.xBF.T + SPM.xBF.T0 + 32,:);

                % place X in SPM.xX.X
                %----------------------------------------------------------
                jX          = Sess(s).row;
                iX          = Sess(s).col(Sess(s).Fc(u).i);
                iX0         = [1:size(SPM.xX.X,2)];
                iX0(iX)     = [];
                X           = [X SPM.xX.X(jX,iX0)];
                X           = SPM.xX.W(jX,jX)*X;
                X           = [X SPM.xX.K(s).X0];

                % Re-estimate to get PSTH and CI
                %----------------------------------------------------------
                j           = xBF.order;
                xX          = spm_sp('Set',X);
                pX          = spm_sp('x-',xX);
                PSTH        = pX*y(jX);
                res         = spm_sp('r',xX,y(jX));
                df          = size(X,1) - size(X,2);
                bcov        = pX*pX'*sum(res.^2)/df;
                PSTH        = PSTH(1:j)/dt;
                PST         = [1:j]*BIN - BIN/2;
                PCI         = CI*sqrt(diag(bcov(1:j,(1:j))))/dt;
        end



        % basis functions and parameters
        %------------------------------------------------------------------
        X     = SPM.xBF.bf/dt;
        x     = ([1:size(X,1)] - 1)*dt;
        j     = Sess(s).col(Sess(s).Fc(u).i(1:size(X,2)));
        B     = beta(j);

        % fitted responses with standard error
        %------------------------------------------------------------------
        Y     = X*B;
        CI    = CI*sqrt(diag(X*Bcov(j,j)*X'));

        % peristimulus times and adjusted data (y = Y + R)
        %------------------------------------------------------------------
        pst   = Sess(s).U(u).pst;
        bin   = round(pst/dt);
        q     = find((bin >= 0) & (bin < size(X,1)));
        y     = R(Sess(s).row(:));
        pst   = pst(q);
        y     = y(q) + Y(bin(q) + 1);



        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,1,2)
        hold on
        switch TITLE

            case 'fitted response and PSTH'
                %----------------------------------------------------------
                errorbar(PST,PSTH,PCI)
                plot(PST,PSTH,'LineWidth',4,'Color',Col(2,:))
                plot(x,Y,'-.','Color',Col(3,:))

            case 'fitted response and 90% C.I.'
                %----------------------------------------------------------
                plot(x,Y,'Color',Col(2,:),'LineWidth',4)
                plot(x,Y + CI,'-.',x,Y - CI,'-.','Color',Col(1,:))

            case 'fitted response and adjusted data'
                %----------------------------------------------------------
                plot(x,Y,'Color',Col(2,:),'LineWidth',4)
                plot(pst,y,'.','Color',Col(3,:))

        end


        % label
        %------------------------------------------------------------------
        [i j] = max(Y);
        text(ceil(1.1*x(j)),i,Sess(s).Fc(u).name,'FontSize',8);
        title(TITLE,'FontSize',12)
        xlabel('peristimulus time {secs}')
        ylabel(['response',XYZstr])
        hold off


        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Parametric responses'


        % return gracefully if no parameters
        %------------------------------------------------------------------
        if ~Sess(s).U(u).P(1).h, return, end

        % basis functions
        %------------------------------------------------------------------
        bf    = SPM.xBF.bf;
        pst   = ([1:size(bf,1)] - 1)*dt;

        % orthogonalised expansion of parameteric variable
        %------------------------------------------------------------------
        str   = 'which parameter';
        p     = spm_input(str,'+1','m',{Sess(s).U(u).P.name});
        P     = Sess(s).U(u).P(p).P;
        q     = [];
        for i = 0:Sess(s).U(u).P(p).h;
            q = [q spm_en(P).^i];
        end
        q     = spm_orth(q);


        % parameter estimates for this effect
        %------------------------------------------------------------------
        B     = beta(Sess(s).Fc(u).i);

        % reconstruct trial-specific responses
        %------------------------------------------------------------------
        Y     = zeros(size(bf,1),size(q,1));
        uj    = Sess(s).U(u).P(p).i;
        for i = 1:size(P,1)
            U      = sparse(1,uj,q(i,:),1,size(Sess(s).U(u).u,2));
            X      = kron(U,bf);
            Y(:,i) = X*B;
        end
        [P j] = sort(P);
        Y     = Y(:,j);

        % plot
        %------------------------------------------------------------------
        figure(Fgraph)
        subplot(2,2,3)
        surf(pst,P,Y')
        shading flat
        title(Sess(s).U(u).name{1},'FontSize',12)
        xlabel('PST {secs}')
        ylabel(Sess(s).U(u).P(p).name)
        zlabel(['responses',XYZstr])
        axis square

        % plot
        %------------------------------------------------------------------
        subplot(2,2,4)
        [j i] = max(mean(Y,2));
        plot(P,Y(i,:),'LineWidth',4,'Color',Col(2,:))
        str   = sprintf('response at %0.1fs',i*dt);
        title(str,'FontSize',12)
        xlabel(Sess(s).U(u).P(p).name)
        axis square
        grid on


        % modeling evoked responses based on Sess
        %------------------------------------------------------------------
    case 'Volterra Kernels'

        % Parameter estimates and basis functions
        %------------------------------------------------------------------
        bf    = SPM.xBF.bf/dt;
        pst   = ([1:size(bf,1)] - 1)*dt;

        % second order kernel
        %------------------------------------------------------------------
        if u > length(Sess(s).U)

            % Parameter estimates and kernel
            %--------------------------------------------------------------
            B     = beta(Sess(s).Fc(u).i);
            i     = 1;
            Y     = 0;
            for p = 1:size(bf,2)
                for q = 1:size(bf,2)
                    Y = Y + B(i)*bf(:,p)*bf(:,q)';
                    i = i + 1;
                end
            end

            % plot
            %--------------------------------------------------------------
            figure(Fgraph)
            subplot(2,2,3)
            imagesc(pst,pst,Y)
            axis xy
            axis image

            title('2nd order Kernel','FontSize',12);
            xlabel('peristimulus time {secs}')
            ylabel('peristimulus time {secs}')

            subplot(2,2,4)
            plot(pst,Y)
            axis square
            grid on

            title(Sess(s).Fc(u).name,'FontSize',12);
            xlabel('peristimulus time {secs}')


            % first  order kernel
            %--------------------------------------------------------------
        else
            B     = beta(Sess(s).Fc(u).i(1:size(bf,2)));
            Y     = bf*B;

            % plot
            %--------------------------------------------------------------
            figure(Fgraph)
            subplot(2,1,2)
            plot(pst,Y)
            grid on
            axis square

            title({'1st order Volterra Kernel' Sess(s).Fc(u).name},...
                'FontSize',12);
            xlabel('peristimulus time {secs}')
            ylabel(['impulse response',XYZstr])
        end

end


% Turn hold button off - this will alert the user to press it again
%--------------------------------------------------------------------------
%try
%    set(get(gcbo,'Userdata'),'Value',0);
%catch
%end


%-call Plot UI
%--------------------------------------------------------------------------
%spm_results_ui('PlotUi',gca)

return;



