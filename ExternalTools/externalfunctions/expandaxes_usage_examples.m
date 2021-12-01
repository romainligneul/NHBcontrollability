% Usage examples for expandaxes.m
% This script contains:
%   - simple examples of the use of expandaxes
%   - examples of what can be done if expandaxes does not work as expected
%   - examples of the correct and incorrect use of expandaxes
%
%
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

%% Example 1: simple plot
x = 1:10; y = x;
figure;
plot(x, y)
xlabel('x')
ylabel('y')
title('figure before calling expandaxes')
f = figure;
plot(x, y)
xlabel('x')
ylabel('y')
title('figure after calling expandaxes')
expandaxes(f)

%% Example 2: Figure with 2 subplots and coliorbars
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
f = figure;
f.Position(3) = 2.*f.Position(3); % double width
for i = 1:2
    Z = i.*sin(X)+cos(Y);
    subplot(1,2,i)
    contour(X,Y,Z,'LineWidth',3,'Fill','On')
    c = colorbar;
    c.Label.String = 'z';
    xlabel('x')
    ylabel('y')
    title(['function ',num2str(i)])
end
expandaxes(gcf)

%% Example 3: Automatic correction of the width between subplots
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
f = figure;
f.Position(3) = 2.*f.Position(3); % double width
for i = 1:2
    Z = i.*sin(X)+cos(Y);
    subplot(1,2,i)
    contour(X,Y,Z,'LineWidth',3,'Fill','On')
    c = colorbar;
    c.Label.String = 'z';
    xlabel('x')
    ylabel('y')
    title(['function ',num2str(i)])
end
fHor = 0.01; % decrease the gap size between subplots in horizontal direction
fVer = 1; % since there is not gap between subplots in vertical direction, fVer is set to 1.
expandaxes(gcf, fHor, fVer)





%% Example 4: Manual correction of positioning

% Figure from example 3 without title. A colorbar bug causes the label to be cut off at the top.
f = figure;
f.Position(3) = 2.*f.Position(3);
for i = 1:2
    Z = i.*sin(X)+cos(Y);
    subplot(1,2,i)
    contour(X,Y,Z,'LineWidth',3,'Fill','On')
    c = colorbar;
    c.Label.String = 'z';
    xlabel('x')
    ylabel('y')
end
fHor = 0.01;
fVer = 1;
expandaxes(gcf, fHor, fVer)

%Correction 1: The right subplot can be made slightly wider.
%1. extraction of axes objects:
AX = findobj(gcf,'type','axes');
%2. Save width of the second subplot:
pos = AX(1).Position;
%3. Manual adjustment of the width
AX(1).Position(3) = pos(3)+0.1;
%4. Adjustment was too wide. Repeat:
AX(1).Position(3) = pos(3)+0.01;
% Adjustment was not wide enough. Repeat:
AX(1).Position(3) = pos(3)+0.02;
%5. Perfect!

%Correction 2: Both subplots need the height reduced. This can be done in a
%loop.
%1. Save position vectors for each axes object
pos = zeros(length(AX), 4); 
pos(1,:) = AX(1).Position;
pos(2,:) = AX(1).Position;
%2. Reduce width
for i = 1:2
    AX(i).Position(4) = pos(i,4) - 0.1;
end
%3. Reduced height too much. Repeat with smaller reduction:
for i = 1:2
    AX(i).Position(4) = pos(i,4) - 0.01;
end
%5. Perfekte!


%% Example 5: Same as example 4, but in this example the figure and axes handles are saved
%while creating the figure
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
f = figure;
f.Position(3) = 2.*f.Position(3);
AX = repmat(axes,2,1);
for i = 1:2
    Z = i.*sin(X)+cos(Y);
    AX(i) = subplot(1,2,i);
    contour(X,Y,Z,'LineWidth',3,'Fill','On')
    c = colorbar;
    c.Label.String = 'Z-Achse';
    xlabel('X-Achse')
    ylabel('Y-Achse')
end
fHor = 0.01;
fVer = 1;
expandaxes(gcf, fHor, fVer)


pos = AX(2).Position;
AX(2).Position(3) = pos(3)+0.02;

pos = zeros(length(AX), 4); 
pos(1,:) = AX(1).Position;
pos(2,:) = AX(1).Position;
for i = 1:2
    AX(i).Position(4) = pos(i,4) - 0.01;
end


%% Example 6: Order of the axes formatting
x = 1:10; y = x;

% 6a: Changing the FontSize after calling expandaxes
%     (incorrect use of expancdaxes)
f = figure;
plot(x, y) 
xlabel('x')
ylabel('y')
title('incorrect use of expandaxes')
expandaxes(f)
ax = gca;
ax.YLabel.FontSize = 14;
ax.XLabel.FontSize = 14;

% 6b: Changing the FontSize before calling expandaxes
%     (correct use of expandaxes)
f = figure;
plot(x, y) 
xlabel('x')
ylabel('y')
title('correct use of expandaxes')
ax = gca;
ax.YLabel.FontSize = 14;
ax.XLabel.FontSize = 14;
expandaxes(f)

% 6c: Manipulation of a colorbar before calling expandaxes
%     (incorrect use of expandaxes)
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
Z = sin(X)+cos(Y);
f = figure;
ax = axes;
contour(X,Y,Z,'LineWidth',3,'Fill','On')
c = colorbar;
c.Label.String = 'z';
xlabel('x')
ylabel('y')
title('inccorrect use of expandaxes')
c.Position(3) = 0.5.*c.Position(3);
pos = ax.Position;
ax.Position(3) = pos(3) - 0.03;
c.Position(1) = pos(1) + pos(3) - 0.01;
expandaxes(f)

% 6d: Manipulation of a colorbar after calling expandaxes
%     (correct use of expandaxes)
x = linspace(-2*pi,2*pi);
y = linspace(0,4*pi);
[X,Y] = meshgrid(x,y);
Z = sin(X)+cos(Y);
f = figure;
ax = axes;
contour(X,Y,Z,'LineWidth',3,'Fill','On')
c = colorbar;
c.Label.String = 'z';
xlabel('x')
ylabel('y')
title('correct use of expandaxes')
expandaxes(f)
% extraction of colorbar handle
c = findobj(f,'type','colorbar'); 
c.Position(3) = 0.5.*c.Position(3);
pos = ax.Position;
ax.Position(3) = pos(3) + 0.075;
c.Position(1) = ax.Position(1) + ax.Position(3) + 0.01;

