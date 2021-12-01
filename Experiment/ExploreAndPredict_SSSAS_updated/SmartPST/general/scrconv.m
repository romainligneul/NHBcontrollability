function scrrect = scrconv(w, rect, dim)
%SCRCONV: converts relative screen coordinates into real coordinates,
% restricting drawing to the center square part of the screen
% if only one input coordinates is provided, dim is required and the
% function outputs only 1 values corresponding to the x or y converted
% position.
if numel(rect)==2
    scrrect = [rect(1:2) rect(1:2)];
else
    scrrect = rect;
end;
% coordinates must simply be compressed by the appropriate ratio
ratio = (w.rectpix(3)-(w.rectpix(3)-w.rectpix(4))/2)/w.rectpix(3);
ratio = [1-ratio 0 1-ratio 0];
scrrect = (scrrect.*w.conv)-2*(((scrrect.*w.conv)-[w.centerpix w.centerpix]).*ratio);

if numel(rect)==1
    scrrect = scrrect(dim);
end;
if numel(rect)==2
    scrrect = scrrect(1:2);
end;
end

