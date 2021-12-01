clear all;
% 1 = triangle
spst.frame_triangle.exe = 'Screen(''FramePoly'', w.id, spst.frame_triangle.color, eval(spst.frame_triangle.pointList), spst.frame_triangle.penWidth)';
spst.frame_triangle.pos = [0.1 0.1];
spst.frame_triangle.height = 0.08;
spst.frame_triangle.color = [255 255 255];
spst.frame_triangle.pointList = ['[scrconv(w, [spst.frame_triangle.pos(1)-spst.frame_triangle.height/2, spst.frame_triangle.pos(2)+(spst.frame_triangle.height*sqrt(3)/4)]);',...
                    'scrconv(w, [spst.frame_triangle.pos(1)+spst.frame_triangle.height/2, spst.frame_triangle.pos(2)+(spst.frame_triangle.height*sqrt(3)/4)]);',...
                    'scrconv(w, [spst.frame_triangle.pos(1), spst.frame_triangle.pos(2)-(spst.frame_triangle.height*sqrt(3)/4)]);]'];
spst.frame_triangle.penWidth = 4;
spst.frame_triangle.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', spst.frame_triangle.pos(1), spst.frame_triangle.pos(2), spst.frame_triangle.color,)';
spst.frame_triangle.exe_highlight2 = 'Screen(''FramePoly'', w.id, spst.frame_triangle.color, eval(spst.frame_triangle.pointList), spst.frame_triangle.penWidth*2)';

% 2 = square
spst.frame_square.exe = 'Screen(''FrameRect'', w.id, spst.frame_square.color, eval(spst.frame_square.rect), spst.frame_square.penWidth)';
spst.frame_square.pos = [0.098 0.098];
spst.frame_square.height = 0.08;
spst.frame_square.color = [255 255 255];
spst.frame_square.rect = 'scrconv(w,[spst.frame_square.pos(1)-spst.frame_square.height/2,spst.frame_square.pos(2)-spst.frame_square.height/2, spst.frame_square.pos(1)+spst.frame_square.height/2,spst.frame_square.pos(2)+spst.frame_square.height/2])';
spst.frame_square.penWidth = 4;
spst.frame_square.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', spst.frame_square.pos(1), spst.frame_circle.pos(2), spst.frame_square.color,)';
spst.frame_square.exe_highlight2 = 'Screen(''FrameRect'', w.id, spst.frame_square.color, eval(spst.frame_square.rect), spst.frame_square.penWidth*2)';

% 3 = square
spst.frame_circle.exe = 'Screen(''FrameOval'', w.id, spst.frame_circle.color, eval(spst.frame_circle.rect), spst.frame_circle.penWidth)';
spst.frame_circle.pos = [0.1 0.1];
spst.frame_circle.height = 0.08;
spst.frame_circle.color = [255 255 255];
spst.frame_circle.rect = 'scrconv(w,[spst.frame_circle.pos(1)-spst.frame_circle.height/2,spst.frame_circle.pos(2)-spst.frame_circle.height/2, spst.frame_circle.pos(1)+spst.frame_circle.height/2,spst.frame_circle.pos(2)+spst.frame_circle.height/2])';
spst.frame_circle.penWidth = 4;
spst.frame_circle.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', spst.frame_circle.pos(1), spst.frame_circle.pos(2), spst.frame_circle.color,)';
spst.frame_circle.exe_highlight2 = 'Screen(''FrameOval'', w.id, spst.frame_circle.color, eval(spst.frame_circle.rect), spst.frame_circle.penWidth*2)';
 
% 2 = square
spst.fill_rectangle.exe = 'Screen(''FillRect'', w.id, spst.fill_rectangle.color, eval(spst.fill_rectangle.rect))';
spst.fill_rectangle.pos = [0.098 0.098];
spst.fill_rectangle.height = 0.08;
spst.fill_rectangle.width = 0.08;
spst.fill_rectangle.color = [255 255 255];
spst.fill_rectangle.rect = 'scrconv(w,[spst.fill_rectangle.pos(1)-spst.fill_rectangle.width/2,spst.fill_rectangle.pos(2)-spst.fill_rectangle.height/2, spst.fill_rectangle.pos(1)+spst.fill_rectangle.width/2,spst.fill_rectangle.pos(2)+spst.fill_rectangle.height/2])';
spst.fill_rectangle.exe_highlight1 = 'Screen(''DrawText'', w.id, ''?'', spst.fill_rectangle.pos(1), spst.fill_rectangle.pos(2), spst.fill_rectangle.color,)';
%spst.fill_rectangle.exe_highlight2 = 'Screen(''FillRect'', w.id, spst.fill_rectangle.color, eval(spst.fill_rectangle.rect), spst.frame_square.penWidth*2)';


% text
spst.text.exe = 'eval(spst.text.bounds);DrawFormattedText(w.id, spst.text.str,  scrconv(w,spst.text.pos(1),1)-(normBoundsRect(3)-normBoundsRect(1))/2, scrconv(w,spst.text.pos(2),2)-(normBoundsRect(4)-normBoundsRect(2))/2, spst.text.defcolor, spst.text.charperline)';
spst.text.pos = [0.1 0.1];
spst.text.justify = 'center';
spst.text.bounds = 'normBoundsRect = Screen(''TextBounds'', w.id, spst.text.str);';
spst.text.str = '';
spst.text.charperline = 80;
spst.text.defcolor = [255 255 255];
spst.text.highcolor = [255 255 255];
spst.text.warningcolor = [200 30 30];
spst.text.rewardcolor = [200 30 30];
spst.text.exe_highlight1 = 'eval(spst.text.bounds);DrawFormattedText(w.id, spst.text.str,  scrconv(w,text.pos(1),1)-(normBoundsRect(3)-normBoundsRect(1))/2, scrconv(w,text.pos(2),2)-(normBoundsRect(4)-normBoundsRect(2))/2, spst.text.highcolor, spst.text.charperline)';
spst.text.exe_warning = 'eval(spst.text.bounds);DrawFormattedText(w.id, spst.text.str,  scrconv(w,text.pos(1),1)-(normBoundsRect(3)-normBoundsRect(1))/2, scrconv(w,text.pos(2),2)-(normBoundsRect(4)-normBoundsRect(2))/2, spst.text.warningcolor, spst.text.charperline)';

% % text - malfunctionning at the Donders (possibly when display w.id >9 or messed up)
% spst.text.exe = 'DrawFormattedText(w.id, spst.text.str, spst.text.justify, ''center'', spst.text.defcolor, spst.text.charperline, [],[], [],[], scrconv(w,[spst.text.pos(1)-spst.text.width/2, spst.text.pos(2)-spst.text.height/2, spst.text.pos(1)+spst.text.width/2, spst.text.pos(2)+spst.text.height/2]))';
% spst.text.pos = [0.1 0.1];
% spst.text.justify = 'center';
% spst.text.height = 0.2;
% spst.text.str = '';
% spst.text.width = 0.4;
% spst.text.charperline = 80;
% spst.text.defcolor = [255 255 255];
% spst.text.highcolor = [255 255 255];
% spst.text.warningcolor = [200 30 30];
% spst.text.rewardcolor = [200 30 30];
% spst.text.exe_highlight1 = 'DrawFormattedText(w.id, spst.text.str, spst.text.justify, ''center'', spst.text.highcolor, spst.text.charperline, [],[], [],[], scrconv(w,[spst.text.pos(1)-spst.text.width/2, spst.text.pos(2)-spst.text.height/2, spst.text.pos(1)+spst.text.width/2, spst.text.pos(2)+spst.text.height/2]))';
% spst.text.exe_warning = 'DrawFormattedText(w.id, spst.text.str, spst.text.justify, ''center'', spst.text.warningcolor, spst.text.charperline, [],[], [],[], scrconv(w,[spst.text.pos(1)-spst.text.width/2, spst.text.pos(2)-spst.text.height/2, spst.text.pos(1)+spst.text.width/2, spst.text.pos(2)+spst.text.height/2]))';

% Fixation cross
spst.fix.exe = 'DrawFormattedText(w.id, spst.fix.symbol, ''center'', ''center'', spst.fix.color);';
spst.fix.pos = [0.5 0.5];
spst.fix.symbol = '+';
spst.fix.color = [255 255 255];

% Image
spst.image.exe = '[p,~,spst.image.alpha] = imread(spst.image.fullpath); if ndims(p)==2 && ~isempty(spst.image.alpha); p(:,:,2) = spst.image.alpha; elseif ndims(p)==3 && ~isempty(spst.image.alpha); p(:,:,4) = spst.image.alpha; end; texture = Screen(''MakeTexture'', w.id, p);Screen(''DrawTexture'', w.id, texture, [], eval(spst.image.rect), spst.image.rotation, []);';
spst.image.pos = [0.5 0.5];
spst.image.height = 0.5;
spst.image.width = 0.5;
spst.image.fullpath = 'mean_mask_1.jpg';
spst.image.rotation = [];         % in degrees
spst.image.color = [255 255 255]; % for highlighting (frame)
spst.image.penWidth = 3;          % for highlighting (frame)
spst.image.rect = 'scrconv(w,[spst.image.pos(1)-spst.image.width/2,spst.image.pos(2)-spst.image.height/2, spst.image.pos(1)+spst.image.width/2,spst.image.pos(2)+spst.image.height/2])';
spst.image.highrect = 'scrconv(w,[spst.image.pos(1)-0.01-spst.image.width/2,spst.image.pos(2)-0.01-spst.image.height/2, spst.image.pos(1)+0.01+spst.image.width/2,spst.image.pos(2)+0.01+spst.image.height/2])';
spst.image.exe_highlight1 = 'p = imread(spst.image.fullpath); texture = Screen(''MakeTexture'', w.id, p);Screen(''DrawTexture'', w.id, texture, [], eval(spst.image.highrect), spst.image.rotation, [], spst.image.alpha);';

% Image
spst.corner_image.exe = 'for corimg=1:4;Screen(''DrawTexture'', w.id, texture, [], eval(spst.corner_image.rect{corimg}));end;';
spst.corner_image.pos = {[0.07 0.07],[0.07 0.93],[0.93 0.07],[0.93 0.93]};
spst.corner_image.width = 0.10;
spst.corner_image.height = 0.10;
spst.corner_image.fullpath = 'mean_mask_1.jpg';
spst.corner_image.rotation = [];         % in degrees
spst.corner_image.color = [255 255 255]; % for highlighting (frame)
spst.corner_image.penWidth = 3;          % for highlighting (frame)
spst.corner_image.rect{1} = 'scrconv(w,[spst.corner_image.pos{1}(1)-spst.corner_image.width/2,spst.corner_image.pos{1}(2)-spst.corner_image.height/2, spst.corner_image.pos{1}(1)+spst.corner_image.width/2,spst.corner_image.pos{1}(2)+spst.corner_image.height/2])';
spst.corner_image.rect{2} = 'scrconv(w,[spst.corner_image.pos{2}(1)-spst.corner_image.width/2,spst.corner_image.pos{2}(2)-spst.corner_image.height/2, spst.corner_image.pos{2}(1)+spst.corner_image.width/2,spst.corner_image.pos{2}(2)+spst.corner_image.height/2])';
spst.corner_image.rect{3} = 'scrconv(w,[spst.corner_image.pos{3}(1)-spst.corner_image.width/2,spst.corner_image.pos{3}(2)-spst.corner_image.height/2, spst.corner_image.pos{3}(1)+spst.corner_image.width/2,spst.corner_image.pos{3}(2)+spst.corner_image.height/2])';
spst.corner_image.rect{4} = 'scrconv(w,[spst.corner_image.pos{4}(1)-spst.corner_image.width/2,spst.corner_image.pos{4}(2)-spst.corner_image.height/2, spst.corner_image.pos{4}(1)+spst.corner_image.width/2,spst.corner_image.pos{4}(2)+spst.corner_image.height/2])';

save('SmartPST_evalobjects.mat')