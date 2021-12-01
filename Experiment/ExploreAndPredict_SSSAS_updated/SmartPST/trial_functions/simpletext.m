function [ stim ] = simpletext( w, txtstr, dur, specs, progress)
%SIMPLETEXT display some text in the middle of the screen.
% most simple function ever..

% assign defaults and manually specified parameters
defaults = struct('xpos', 'center',...
    'ypos', 'center', ...
    'font', 'courier',...
    'bgcolor', [0 0 0],...
    'txtsize', 30,...
    'txtcolor', [255 255 255],...
    'wraplength', 60);
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end

 Screen('TextSize', w.id, specs.txtsize);
% Screen('TextFont', w.id, specs.font);
if ~isempty(progress)
    progressrect = scrconv(w,progress.rect);
    progressrect(3) = progressrect(1)+ (progressrect(3)- progressrect(1))*progress.progress(1);
    Screen('FillRect',w.id,progress.fillcolor,  progressrect);
    Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);   
end
DrawFormattedText(w.id,txtstr, specs.xpos, specs.ypos, specs.txtcolor, specs.wraplength);
Screen('Flip', w.id);
stim.onset = GetSecs;
WaitSecs(dur);


end

