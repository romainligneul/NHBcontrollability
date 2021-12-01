function stim = fixation_cross(w, dur, predur, specs, progress)
% FIXATION_CROSS to display a fixation cross in the middle of the screen
% - w is the screenID where psychtoolbox should flip the stimulus
% - dur is the duration (in seconds) of the fixation cross
% - predur is the duration (in seconds) of the prefixation symbol (i.e. warning useful to diminish RT variance)
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are
% used:
% struct('size', 30,...
%                  'style', 'courrier',...
%                  'symbol', '+',...
%                  'color', [255 255 255],...
%                  'colorpretrig', [180 180 180],...
%                  'symbolpretrig', '+');

% assign defaults and manually specified parameters
defaults = struct('size', 30,...
    'symbol', '+',...
    'color', [0 0 0],...
    'colorpretrig', [50 50 50],...
    'symbolpretrig', '+');
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end

if isempty(predur)
    predur = 0;
end;

% draw the progress bar if required
if ~isempty(progress)
    progressrect = scrconv(w,progress.rect);
    progressrect(3) = progressrect(1)+ (progressrect(3)- progressrect(1))*progress.progress(1);
end
Screen('TextSize', w.id, specs.size);

stim.onset = GetSecs;
while GetSecs-stim.onset<=dur
    
    if predur > 0
        while (GetSecs-stim.onset) < predur
          %  Screen('FillRect',w.id,progress.fillcolor,  progressrect);
          %  Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);
            DrawFormattedText(w.id, specs.symbolpretrig, 'center', 'center', specs.colorpretrig);
            Screen('Flip', w.id);
            predur = 0;
        end;
    else
      %  Screen('FillRect',w.id,progress.fillcolor,  progressrect);
      %  Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);
        DrawFormattedText(w.id, specs.symbol, 'center', 'center', specs.color);
        Screen('Flip',w.id);
    end;
    
end

end

