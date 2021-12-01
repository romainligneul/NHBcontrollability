function expandaxes(h, varargin)
% expandaxes: More reliable implementation of the option "expand axes to
% fill figure" in the Export Setup... settings. Works with multiple
% subplots and usually does not distort objects such as colorbars.
%
% Syntax:
%        expandaxes(h)
%        expandaxes(h, fHor, fVer) - For manual adjustment of the distance
%                                    between subplots
%        expandaxes(h, 'Undo', true) - For undoing an expandaxes operation
%                                      on a figure h
% 
% Input arguments:
%        - h:    Figure handle
%        - fHor: Factor for the distance between subplots in horizontal direction
%                (Default: 1)
%        - fVer: Factor for the distance between subplots in vertical direction
%                (Default: 1)
% 
% Hints:
% 
%    a)  General rule of thumb for the order of execution when calling expandaxes:
%           1) Set objects, FontSizes, etc.
%           2) Call expandaxes
%           3) Other manipulations of axes and colorbar positions
% 
%    b)  By setting
%           h.SizeChangedFcn = 'expandaxes(gcf, fHor, fVer);';
%        this function can be called with exery resize of the figure h.
%
%
% Author: Marc Jakobi, 04/29/2016

%% BSD License
%  
%  Copyright (c) 2016 Marc Jakobi
%  All rights reserved.
% 
% 
%  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 
%  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 
%  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
% 
%  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
% 
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
%  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
%  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
%  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
%  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
%  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%% Changelog:
%
%       - 05/24/2016: Added support for most colorbar labels. The width of
%                     the axes is reduced by 2.*(TightInset(1)-TightInset(3)) if a
%                     colorbar label is found.
%       - 05/27/2016: Added support for "subplotnumber"-text objects.
%       - 05/30/2016: Bugfix: 2 subplots above each other were shifted
%                             right by too much.
%                     Bugfix: Colorbar textlabels in a single axes were not
%                             handled correctly.
%       - 06/06/2016: Added support for more subplots (old limit: 2x2)
%                     Added support for suptiltes (may not work correctly
%                       if suptitles and colorbars are contained in the
%                       same figure (FIXED).
%       - 06/30/2016: Bugfix: Fixed issue in which manually setting the
%                             distance between subplots in
%                             horizontal/vertical direction did not work if
%                             there were no axes labels due to too small
%                             TightInset.
%       - 07/07/2016: Bugfix: Fixed an issue causing manual set distances
%                             between subplots to vary with more than two
%                             subplots.
%                     Added support for subplots containing superimpozed
%                     axes objects (e. g. plotyy)
%                     Bugfix: Combinations of suptitles and colorbars
%                     should work now.
%       - 07/08/2016: Added automatic detection of number of subplots and
%                     their respective positions.
%       - 08/02/2016: Bugfix: Fixed issue in which re-applying this
%                             function a second time would distort the axes
%                             objects by storing the original positions in
%                             the figure object and resetting to original
%                             positions before re-applying this function.
%                     Added small improvements to colorbar handling.
%       - 04/02/2016: Fixed issues with docked figures by undocking them
%                     and restoring the WindowStyle at the end.
%       - 06/04/2017: Added undo option.
%                     Moved position from h.UserData.value to
%                     h.UserData.expandaxesData.value so as to make clearer
%                     that data comes from expandaxes function.
%       - 07/04/2017: Fixed bug with new syntax.
%% parse inputs
if nargin < 1
    h = gcf;
    fHor = 1;
    fVer = 1;
elseif nargin == 1
    fHor = 1;
    fVer = 1;
elseif nargin == 2
    fVer = 1;
    if ischar(varargin{1})
        fHor = 1;
    else % Make compatible name value pair syntax
        fHor = varargin{1};
        varargin = {'Undo', false};
    end
else % Make backward-compatible with old and new syntax
    if isnumeric(varargin{1})
        fHor = varargin{1};
        if isnumeric(varargin{2})
            fVer = varargin{2};
            varargin = varargin(3:end);
        else
            varargin = varargin(2:end);
        end
    end
end
p = inputParser;
addOptional(p, 'Undo', false, @islogical)
parse(p, varargin{:});

% save WindowStyle and undock figure
Wstyle = h.WindowStyle;
h.WindowStyle = 'normal';

%% constants
fullLine = -0.005; % add this to ensure box line is not 
                   % cut off if x or y TickLabels don't go all the way to
                   % the edge
                   
%% extract axes objects
AX = findobj(h,'type','axes');


%% identify suptitle objects
spind = true(size(AX));
for i = 1:numel(AX)
    ax = AX(i);
    STa = findobj(ax,'tag','suptitle');
    if ~isempty(STa)
        spind(i) = false;
        break
    end
end
if sum(spind) < numel(AX)
    % determine position of suptitle
    AX = AX(spind);
    supt = findall(STa,'type','text');
    supt = supt(1);
    supt.VerticalAlignment = 'bottom';
    STa.Position(4) = abs(supt.Position(2).*2);
    STa.Position(2) = 1 - abs(supt.Position(2));
    supt.Position(2) = -supt.Position(2);
    % set figure upper limit to bottom of suptitle
    upperlim = STa.Position(2);
else % if no suptitle
    % set figure upper limit to top of figure
    upperlim = 1;
end


%% save previous position and reset in case expandaxes was used on figure before
for i = 1:numel(AX)
    if strcmp(AX(i).Tag,'expandedaxes') % reset to previous positions
        AX(i).Position = AX(i).UserData.expandaxesData.Position;
        AX(i).OuterPosition = AX(i).UserData.expandaxesData.OuterPosition;
        AX(i).Tag = AX(i).UserData.expandaxesData.Tag;
        if p.Results.Undo
            AX(i).UserData = rmfield(AX(i).UserData, 'expandaxesData');
        end
    end
    if ~p.Results.Undo
        % save position data in figure
        AX(i).UserData.expandaxesData.Tag = AX(i).Tag;
        AX(i).UserData.expandaxesData.Position = AX(i).Position;
        AX(i).UserData.expandaxesData.OuterPosition = AX(i).OuterPosition;
        AX(i).Tag = 'expandedaxes';
    end
end
if p.Results.Undo
    return;
end

%% Check for superimpozed axes, such as in plotyy
% identify subplots with multiple axes (e.g. plotyy)
[subs, numsub, nHor, nVer] = spidentify(h);
superimposed = false(size(AX)); % true/false vector for subplots with superimpozed axes
% index for subs struct axes corresponding with AX(i): [j, k] for [subs(j), subs(j).AX(k)]
subsind = zeros(size(AX,1),2);
if numsub ~= numel(AX) % at least one overlay?
   for i = 1:numel(AX)
       pos = AX(i).Position;
       for j = 1:numel(subs)
           if numel(subs(j).AX) > 1
               for k = 1:numel(subs(j).AX)
                   if sum(pos-subs(j).AX(k).Position) == 0
                       superimposed(i) = true;
                       subsind(i,1) = j;
                       subsind(i,2) = k;
                   end
               end
           end
       end
   end
end

%% delete blank axes labels
for i = 1:numel(AX)
    ax = AX(i);
    if numel(strfind(ax.YLabel.String,' ')) == numel(ax.YLabel.String)
        ax.YLabel.String = '';
    end
    if numel(strfind(ax.XLabel.String,' ')) == numel(ax.XLabel.String)
        ax.XLabel.String = '';
    end
    if numel(strfind(ax.Title.String,' ')) == numel(ax.Title.String)
        ax.Title.String = '';
    end
end


%% find "subplotnumber" text objects and add temporary ylabels and titles to
% adjust TightInsets accordingly (if the axes has none)
tmpt = findall(h,'tag','templabel');
delete(tmpt); % delete previous temporary labels
spn = findall(h,'tag','subplotnumber');
tmpyl = repmat(text(),numel(spn),1);
tmptl = tmpyl;
for i = 1:numel(spn)
    if strcmp(AX(i).YLabel.String,'') % temporary ylabel
        tmpyl(i) = ylabel(AX(i),'temporary ylabel','FontSize',AX(i).FontSize+0.5,'Tag','templabel');
    end
    if strcmp(AX(i).Title.String,'') % temporary title
        tmptl(i) = title(AX(i),'temporary title','FontSize',AX(i).FontSize,'Tag','templabel');
    end
end

% find colorbars
cbr = ~isempty(findobj(h,'type','colorbar'));
cTF = false(size(AX)); % true/false vector for later recreation of colorbars
if numel(AX) > 1 % for multiple axes
    %% delete colorbars and re-add later with same properties
    % Since colorbars are not axes children, the size of the axes adjusts
    % when creating a colorbar, but colorbars don't affect the TightInset.
    if cbr
        CH = h.Children;
        if upperlim ~= 1 % filter out suptitle objects
            CH = CH(spind);
        end
        chTF = false(size(CH));
        cbrPs = repmat(struct(),1,numel(AX)); % struct for saving colorbar properties
        ct = 1;
        for i = 1:numel(chTF)
            type = class(CH(i));
            ti = strfind(type,'.');
            type = type(ti(end)+1:end);
            if strcmp(type,'ColorBar')
                cTF(ct) = true;
                chTF(i) = true;
                cbrPs(ct).CP = getColorbarProperties(CH(i)); % save properties to struct for later recreation
            else
                ct = ct + 1;
            end
        end
        delete(CH(chTF)); % delete colorbars
    end
    
    %% MANIPULATION OF POSTION VECTORS
    % determine OuterPositions
    OPs = zeros(numel(AX),4); % OuterPosition of each axes
    TIs = OPs; % TightInsets of each axes
    for i = 1:numel(AX)
        ax = AX(i);
        OPs(i,:) = ax.OuterPosition;
        TIs(i,:) = ax.TightInset;
    end
    % Adjust in vertical direction
    [C, ~, ~] = unique(round(OPs(:,2),1));
    if nVer > 1 % divide into equal sections if more than one subplot in vertical direction
        bottoms = linspace(0,upperlim-upperlim./nVer,nVer)';
    else 
        bottoms = 0; % set bottom subplot OuterPostion to zero
    end
    height = upperlim./nVer;
    tmp = OPs(:,2);
    for i = 1:nVer
        if fVer ~= 1 && TIs(i,2) < 1e-5
            fact = 0.0243; % no TightInset would eliminate effect of fVer
        else
            fact = TIs(i,2); 
        end
        % set vertical spacing between subplots
        if i == 1 % Bottom
            tmp(round(tmp,1) == C(i)) = bottoms(i);
        elseif i == nVer % Top
            tmp(round(tmp,1) == C(i)) = bottoms(i) + fVer.*fact./2;
        else % in between
            tmp(round(tmp,1) == C(i)) = bottoms(i) + 0.5.*fVer.*fact./2;
        end
    end
    if nVer > 1
        if fVer ~= 1 && TIs(i,2) < 1e-5
            height = height - fVer.*0.0243./2;
        else
            height = height - fVer.*TIs(:,2)./2;
        end
    end
    OPs(:,2) = tmp;
    OPs(:,4) = height + fullLine;
    % Adjust in horizontal direction
    [C, ~, ~] = unique(round(OPs(:,1),1));
    if nHor > 1
        lefts = linspace(0,1-1./nHor,nHor)';
    else
        lefts = 0;
    end
    width = 1./nHor;
    tmp = OPs(:,1);
    for i = 1:nHor
        if fHor ~= 1 && TIs(i,1) < 1e-5
            fact = 0.0243; % no TightInset would eliminate effect of fHor
        else
            fact = TIs(i,1); 
        end
        % set horizontal spacing between subplots
        if i == 1 % Left: no spacing
            tmp(round(tmp,1) == C(i)) = lefts(i);
        elseif i == nHor % Right: 1x spacing to the left
          tmp(round(tmp,1) == C(i)) = lefts(i) + fHor.*fact./2;
        else % in between: 0.5x spacing to the left
          tmp(round(tmp,1) == C(i)) = lefts(i) + 0.5.*fHor.*fact./2;
        end
    end
    if nHor > 1
        width = width - fHor.*fact./2;
    end
    OPs(:,1) = tmp;
    OPs(:,3) = width + fullLine;
    
    %% AXES RESIZING
    for i = 1:numel(AX)
        ax = AX(i);
        ax.OuterPosition = OPs(i,:);
        OP = OPs(i,:);
        TI = ax.TightInset;
        ax.Position(1) = OP(1) + TI(1);
        ax.Position(2) = OP(2) + TI(2);
        ax.Position(4) = OP(4) - TI(2) - TI(4);
        if cTF(i)
            % subtract 2*TightInset-margin from width in case of colorbar label
            if ~strcmp(cbrPs(i).CP.Label.String,'') && strcmp(ax.YLabel.String,'')
                ax.Position(3) = OP(3) - 3.*(TI(1) - TI(3));%1.3    %1.5 %2 
            elseif ~strcmp(cbrPs(i).CP.Label.String,'')
                ax.Position(3) = OP(3) - 2.*(TI(1) - TI(3)); %1.5 %1,3 %2
            else
                ax.Position(3) = OP(3) - TI(1) - TI(3);
            end
        else
            % otherwise subtract 1*TightInset-margin from width
            ax.Position(3) = OP(3) - TI(1) - TI(3);
        end
    end
    %% re-add colorbars
    for i = 1:numel(AX)
        ax = AX(i);
        TI = ax.TightInset;
        if cTF(i)
            cbr = colorbar(AX(i));
            pause(0.002) % to prevent matlab from distorting colorbar
            % add saved properties
            addColorbarProperties(cbr, cbrPs(i).CP);
            % for some reason the re-adding colorbar trick doesn't work with
            % suptitles. This seems to fix it:
            if upperlim ~= 1 
                if ~strcmp(cbr.Label.String,'') && strcmp(AX(i).YLabel.String,'')
                    ax.Position(3) = ax.Position(3) - 2.5.*(TI(1) - TI(3));
                elseif ~strcmp(cbrPs(i).CP.Label.String,'')
                    ax.Position(3) = ax.Position(3) - 1.3.*(TI(1) - TI(3));
                else
                    ax.Position(3) = ax.Position(3) - TI(1) - TI(3);
                end
            end
        end
    end
else
    %% SINGLE AXES
    cbr = findobj(h,'type','colorbar');
    c = ~isempty(cbr);
    if c
        CP = getColorbarProperties(cbr);
        delete(cbr)
    end
    OP = AX.OuterPosition;
    TI = AX.TightInset;
    AX.Position(1) = OP(1) + TI(1);
    AX.Position(2) = OP(2) + TI(2);
    AX.Position(4) = OP(4) - TI(2) - TI(4) + fullLine;
    if c
        % subtract 2*TightInset-margin in case of colorbar label
        if ~strcmp(CP.Label.String,'')
            AX.Position(3) = OP(3) - 2.*(TI(1) - TI(3));
        else
            AX.Position(3) = OP(3) - TI(1) - TI(3);
        end
    else
        % otherwise subtract 1*TightInset-margin from width
        AX.Position(3) = OP(3) - TI(1) - TI(3);
    end
    AX.Position(3) = AX.Position(3) + fullLine;
    if c % contains colorbar?
        cbr = colorbar;
        pause(0.002) % to prevent matlab from distorting colorbar
        addColorbarProperties(cbr, CP);
    end
end
% delete temporary ylabels and titles
delete(tmpyl)
delete(tmptl)


%% Correct positions of subplots with multiple superimpozed axes
for i = 1:numsub
    if numel(subs(i).AX) > 1
        POS = [0, 0, 1000, 1000]; % final position vector for subplot
        for j = 1:numel(subs(i).AX)
            POS(1) = max([POS(1); subs(i).AX(j).Position(1)]);
            POS(2) = max([POS(2); subs(i).AX(j).Position(2)]);
            POS(3) = min([POS(3); subs(i).AX(j).Position(3)]);
            POS(4) = min([POS(4); subs(i).AX(j).Position(4)]);
        end
        for j = 1:numel(subs(i).AX)
            subs(i).AX(j).Position = POS;
        end
    end
end
expandaxesColorBarCorr(h)
h.WindowStyle = Wstyle; % restore WindowStyle
end % end of main function

%% Subfunctions for colorbar handling
function CP = getColorbarProperties(c)
% gets required colorbar properties and saves them in struct CP
LabelNames = {'String'; 'FontSize'; 'FontWeight'; 'FontName'; 'Color'; 'HorizontalAlignment'; 'Interpreter'};
CPnames = {'Box'; 'Color'; 'Direction'; 'FontAngle'; 'FontName'; 'FontSize'; 'FontWeight'; 'Limits'; 'LimitsMode';...
    'LineWidth'; 'Location'; 'AxisLocation'; 'AxisLocationMode'; 'TickDirection'; 'TickLabelInterpreter';...
    'TickLabels'; 'TickLabelsMode'; 'TickLength'; 'Ticks'; 'TicksMode'; 'Units'; 'Visible'; 'HandleVisibility';...
    'ButtonDownFcn'; 'BusyAction'; 'Interruptible'; 'CreateFcn'; 'DeleteFcn';...
    'Tag'; 'UserData'; 'Selected'; 'SelectionHighlight'; 'HitTest'; 'PickableParts'};
for ind = 1:numel(LabelNames)
    CP.Label.(LabelNames{ind}) = c.Label.(LabelNames{ind});
end
for ind = 1:numel(CPnames)
    CP.(CPnames{ind}) = c.(CPnames{ind});
end
end

function addColorbarProperties(c, CP)
% copies struct properties to colorbar handle
% c: clolorbar handle
% CP: struct
CPnames = {'Box'; 'Color'; 'Direction'; 'FontAngle'; 'FontName'; 'FontSize'; 'FontWeight'; 'Limits'; 'LimitsMode';...
    'LineWidth'; 'Location'; 'AxisLocation'; 'AxisLocationMode'; 'TickDirection'; 'TickLabelInterpreter';...
    'TickLabels'; 'TickLabelsMode'; 'TickLength'; 'Ticks'; 'TicksMode'; 'Units'; 'Visible'; 'HandleVisibility';...
    'ButtonDownFcn'; 'BusyAction'; 'Interruptible'; 'CreateFcn'; 'DeleteFcn';...
    'Tag'; 'UserData'; 'Selected'; 'SelectionHighlight'; 'HitTest'; 'PickableParts'};
for ind = 1:numel(CPnames)
    c.(CPnames{ind}) = CP.(CPnames{ind});
end
if ~strcmp(CP.Label.String,'')
    ylabel(c,CP.Label.String,'FontSize',CP.Label.FontSize,'FontWeight',CP.Label.FontWeight,...
        'FontName',CP.Label.FontName,'Color',CP.Label.Color,'HorizontalAlignment',...
        CP.Label.HorizontalAlignment,'Interpreter',CP.Label.Interpreter);
end
end

function expandaxesColorBarCorr(h)
% correction of expandaxes colorbar positioning
[s, ~, ~, ~] = spidentify(h);
C2 = findall(h,'Type','colorbar');
for in = 1:numel(s)
    if s(in).nc
        for in2 = 1:numel(C2)
            % find out which colorbar object belongs to axes
            C_AXES2 = get(C2(in2),'axes');
            if sum(C_AXES2.Position - s(in).AX(1).Position) == 0
                c = C2(in2);
                break
            end
        end
        cpos = c.Position; % colorbar position
        dif = cpos(1) - s(in).AX(1).Position(1) - s(in).AX(1).Position(3);
        if  dif > 0.02 || dif < 0
            p = s(in).AX(1).Position(3);
            c.Position(1) = c.Position(1) - (dif-0.02);
            % restore position of axes
            pause(0.001)
            for in2 = 1:numel(s(in).AX)
                s(in).AX(in2).Position(3) = p;
            end
        end
        
    end
end
end

%% Subfunction for superimpozed axes
function [subs, numsub, nHor, nVer] = spidentify(h)
% spidentify: Indentifies subplots in  figure h. Some figures contain axes
% that are superimpozed (e. g. plotyy), so that more axes objects than
% subplots can be present. With this function, superimpozed axes objects can
% be identiffied and returned in the struct "subs", divided into their
% respected subplots.
%
% Syntax: subs = spidentify(h);
%         [subs, numsub] = spidentify(h);
%         [subs, numsub, nHor, nVer] = spidentify(h);
%
% Input arguments:
%
%    h:      Figure handle, e. g. h = gcf;
%
% Output arguments:
%
%    subs:   Struct with the identified subplots as fields. Each field is a
%            1xN axes object that corresponds with the respective subplot.
% 
%            subs(i)         i = index of the subplot
%            subs(i).AX      1xN axes Handle of the subplot i containing all
%                            superimpozed axes
%            subs(i).nc      Number of colorbars contained in subplot i
%    numsub: Number of subplots in the figure
%    nVer:   Number of subplots in vertical direction
%    nHor:   Number of subplots in horizontal direction
%
%
% Author: Marc Jakobi, HTW Berlin, 06/17/2016

if ~isgraphics(h,'figure')
    error('Bitte gültigen Figure-Handle eingeben')
end
AX = findobj(h,'type','axes'); % axes handles
% eliminate suptitle objects
ind = true(size(AX));
for i = 1:numel(AX)
    if ~isempty(findall(AX(i),'tag','suptitle'))
        ind(i) = false;
    end
end
AX = AX(ind);
C = findall(h,'Type','colorbar'); % colorbar handles
numax = numel(AX);
chk = zeros(numax,1,'single');
for i = 1:numax
    ax = AX(i);
    poschk = ax.Position;
    chk(i) = sum([poschk(1); poschk(2)]);
end
ind = true(size(AX));
if numel(unique(chk)) ~= numel(chk)
    ind = false(size(chk));
    un = unique(chk);
    for i = 1:numel(chk)
        if  ~isempty(find(un == chk(i),1))
            un(find(un == chk(i),1)) = [];
            ind(i) = true;
        end
    end
end
numsub = sum(ind); % number of subplots
% assignment of axes handles to their respective subplots
subind = zeros(numax,1);
for i = 1:numax
    subind(i) = find(unique(chk) == chk(i),1);
end
subs = repmat(struct(),numsub,1);
ml = false(numsub,1);
for i = 1:numsub
    subsubind = subind == i;
    ax = AX(subsubind);
    subs(i).AX = ax;
    subs(i).nc = 0; % amount of colorbars
    for j = 1:numel(AX)
        for k = 1:numel(C)
            C_AXES = get(C(k),'axes');
            if sum(C_AXES.Position - ax.Position) == 0 && ~strcmp(C(k).YLabel.String,'')
                subs(i).nc = subs(i).nc + 1;
            end
        end
    end
    if sum(subsubind) > 1
        ml(i) = true;
    end
end
% identify number of subplots in horizontal and vertical direction
if nargout == 3 || nargout == 4
    OPv = zeros(numsub,2);
    for i = 1:numsub
        OPv(i,:) = subs(i).AX(1).OuterPosition(:,1:2);
    end
    lefts = [1; diff(sort(OPv(:,1)))];
    rights = [1; diff(sort(OPv(:,2)))];
    if numsub == 2
        if lefts(2) < rights(2)
            nHor = 1;
            nVer = 2;
        else
            nHor = 2;
            nVer = 1;
        end
    else
        nHor = find(rights > 0.1, 2);
        nVer = find(lefts > 0.1, 2);
        chk = primes(100); chk = chk(chk ~= numsub);
        if sum(numsub./chk == round(numsub./chk)) > 0
            nVer = nVer(2) - 1;
            nHor = nHor(2) - 1;
        else
            chk = sum(OPv);
            if find(chk == min(chk),1) == 2
                nHor = numsub;
                nVer = 1;
            else
                nVer = numsub;
                nHor = 1;
            end
        end
    end
end
end % end of subfunction