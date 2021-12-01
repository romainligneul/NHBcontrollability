function [ stim resp ] = polyvalent_likert(w, selected, specs, progress )
%%% POLYVALENT_LIKERT displays a Likert-like (!) scale and ask the subject to use the response device to answer
% - w: the screenID where psychtoolbox should flip the stimulus
% - selected: the preselected option. If empty, will be set to 1.
% - method: 'scroll' or 'key'. Default = 'scroll';
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are used.
% steps = 5;
% msgtxt: define the "instruction" = 'How many kudos do you want to bet?';
% ytxt1: define the ypos of 'instruction' text in relative coordinates. def = 0.425;
% labels: define the number and the names of response bins. def = {'1', '2', '3', '4', '5'};
% xrange: define the xpos and width (in relative coordinates) of the scale. def = [0.35 0.65];
% ylabel: define the position of the label name below response circles. def = 0.55;
% wraplabel: define the number of characters before a line break in the label names. def = 15;
% labelsize: define the font size used for label names. def = 15;
% color: define the color of unselected responses. def = [180 180 180];
% selcolor: define the color of selected responses. def = [255 255 255];
% confcolor: define the color of confirmed responses = [100 255 100];
% left_right_confirm: define the left/right and confirmation response buttons. def = {'left', 'right', 'down'};
% confirmwait: jitter after response selection. def  = 0.3;

% assign defaults and manually specified parameters
defaults = struct('method', 'scroll',...
    'keymap', [1 2 3 4 5],...
    'xrange', [0.35 0.65], ...
    'msgtxt', 'How many kudos do you want to bet?',...
    'ytxt1', 0.425,...
    'ylabel', 0.55,...
    'wraplabel', 15,...
    'labelsize', 15,...
    'color', [180 180 180], ...
    'selcolor', [255 255 255], ...
    'confcolor', [100 255 100],...
    'confirmwait', 0.3,...
    'bgcolor', [0 0 0],...
    'respleft', 'LeftArrow',...
    'respmid', 'DownArrow',...
    'respright', 'RightArrow');
defaults.labels = {'1', '2', '3', '4', '5'};
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end
specs.resp_keymap{1} = specs.respleft;
specs.resp_keymap{2} = specs.respright;
specs.resp_keymap{3} = specs.respmid;
specs.steps = length(specs.keymap);

oldtextsize = Screen('TextSize', w.id);
% compute the spacing and the size of response circles
xstep = (specs.xrange(2)-specs.xrange(1))/(length(specs.keymap)-1);
radius = (xstep/2);
xpos = specs.xrange(1);

% initialize stuff
if isempty(selected)
    selected = 1;%(specs.steps+1)/2;
end

confirmed = 0;
npresses = 0;
exit = 0;

% background
Screen('FillRect', w.id,  specs.bgcolor, w.rectpix);

% draw the progress bar if required
if ~isempty(progress)
    progressrect = scrconv(w,progress.rect);
    progressrect(3) = progressrect(1)+ (progressrect(3)- progressrect(1))*progress.progress(1);
    Screen('FillRect',w.id,progress.fillcolor,  progressrect);
    Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);
end

% first draw of circles and flip
draw_circles(specs, w, radius, xpos, xstep, selected, confirmed)
Screen('Flip',w.id);
stim.onset = GetSecs;

% wait for subject confirmation

while exit == 0
    
    % wait for press
    [secs, keyCode] = KbWait;
    npresses = npresses+1;
    % left<->right / confirm method
    if strcmp(specs.method, 'scroll');
        if ismember(KbName(keyCode),specs.resp_keymap{3})
            confirmed = selected;
            resp.answer = confirmed;
            resp.RT = GetSecs-stim.onset;
            resp.npresses = npresses;
            WaitSecs(specs.confirmwait);
            exit = 1;
            % leftmove
        elseif strcmp(KbName(keyCode),specs.resp_keymap{1})
            selected = selected-1;
            if selected < 1;selected=1;end;
        elseif strcmp(KbName(keyCode),specs.resp_keymap{2})
            selected = selected+1;
            if selected > specs.steps; selected=specs.steps;end;
        else
        end
    elseif strcmp(specs.method, 'key')
        if ismember(KbName(keyCode),specs.keymap);
            if selected == find(ismember(KbName(keyCode),specs.keymap))
                confirmed = selected;
                resp.answer = confirmed;
                resp.RT = GetSecs-stim.onset;
                resp.npresses = npresses;
                WaitSecs(specs.confirmwait);
                exit = 1;
            else
                selected = chosenkey;
            end;
        end
    end;
    
    % draw everything
    Screen('FillRect', w.id,  specs.bgcolor, w.rectpix);
    if ~isempty(progress)
        Screen('FillRect',w.id,progress.fillcolor,  progressrect);
        Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);
    end
    draw_circles(specs, w, radius, xpos, xstep, selected, confirmed);
    Screen('Flip',w.id);
    
    KbReleaseWait;
end

% draw everything one last time
Screen('FillRect', w.id,  specs.bgcolor, w.rectpix);
if ~isempty(progress)
    Screen('FillRect',w.id,progress.fillcolor,  progressrect);
    Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);
end
draw_circles(specs, w, radius, xpos, xstep, selected, confirmed);
Screen('Flip',w.id);
Screen('TextSize', w.id, oldtextsize);
WaitSecs(specs.confirmwait);
KbReleaseWait;

%%%---- AUX function

    function draw_circles(specs, w, radius, xpos, xstep, selected, confirmed)
        
        for s = 1:specs.steps
            
            rect(s,:) = scrconv(w,[xpos-radius 0.5-radius xpos+radius 0.5+radius]);
            
            % t1rect(s,:) = scrconv(w,[xpos-radius 0.4-radius xpos+radius 0.4+radius]);
            
            if s == confirmed
                color = specs.confcolor;
            elseif s == selected
                color = specs.selcolor;
            else
                color = specs.color;
            end;
            Screen('TextSize', w.id, specs.labelsize);
            textrect = Screen('TextBounds', w.id,specs.labels{s});
            halftextwidth = (textrect(3)-textrect(1))/2;
            DrawFormattedText(w.id,specs.labels{s},scrconv(w,xpos,1)-halftextwidth/2,scrconv(w,specs.ylabel,2),color, specs.wraplabel)
            Screen('FillOval', w.id, color, rect(s,:));
            
            xpos = xpos + xstep;
            
        end;
        % instruction
        DrawFormattedText(w.id,specs.msgtxt ,'center',scrconv(w,specs.ytxt1,2),specs.color, [])
        
    end

end


