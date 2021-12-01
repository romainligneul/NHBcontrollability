function [ stim resp parasiteresp ] = binaryquestion( w,specs )
%%% This function displays a binaryquestion scale and asks subject to answer by
%%% double pressing a button

% assign defaults and manually specified parameters
defaults = struct('rect', [0.4 0.4 0.6 0.6],...
    'clockimg', 'general_stims\clock_small.png',...
    'ytxt1', 0.45,...
    'ylabel', 0.55,...
    'label1', 'start',...
    'label2', 'start',...
    'wrapquestion',80,...
    'color',[0 0 0],...
    'xpos', [0.45 0.55],...
    'confcolor',[255 255 255],...
    'confirmwait',0.2,...
    'leftcode', 'left',...
    'rightcode', 'right');

for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end


% trick because structure doesnt accept cell inputs
specs.resp_keymap{1} = specs.leftcode;
specs.resp_keymap{2} = specs.rightcode;

parasiteresp.onset = [];
parasiteresp.button = [];

% initialize stuff

DrawFormattedText(w.id,specs.msgtxt ,'center',scrconv(w,specs.ytxt1,2),specs.color,specs.wrapquestion)
textrect = Screen('TextBounds', w.id,specs.label1);
halftextwidth = (textrect(3)-textrect(1))/2;
DrawFormattedText(w.id,specs.label1,scrconv(w,specs.xpos(1),1)-halftextwidth,scrconv(w,specs.ylabel,2),specs.color, specs.wrapquestion)
textrect = Screen('TextBounds', w.id,specs.label2);
halftextwidth = (textrect(3)-textrect(1))/2;
DrawFormattedText(w.id,specs.label2,scrconv(w,specs.xpos(2),1)-halftextwidth,scrconv(w,specs.ylabel,2),specs.color, specs.wrapquestion)

Screen('Flip', w.id);
stim.onset = GetSecs;
npresses = 0;
exit = 0;

while exit == 0
    [secs, keyCode] = KbWait;
    %WaitSecs(specs.pressdelay);
    npresses = npresses+1;
    if ismember(KbName(keyCode),specs.resp_keymap{1})
        resp.answer = 1;
        resp.RT = GetSecs-stim.onset;
        % initialize stuff
        DrawFormattedText(w.id,specs.msgtxt ,'center',scrconv(w,specs.ytxt1,2),specs.color, [])
        DrawFormattedText(w.id,specs.label1,scrconv(w,specs.xpos(1),1)-halftextwidth,scrconv(w,specs.ylabel,2),specs.confcolor, specs.wrapquestion)

        Screen('Flip', w.id);
        WaitSecs(specs.confirmwait);
        exit = 1;
        % leftmove
    elseif ismember(KbName(keyCode),specs.resp_keymap{2})
        resp.RT = GetSecs-stim.onset;
        resp.answer = 2;
        % initialize stuff
        DrawFormattedText(w.id,specs.msgtxt ,'center',scrconv(w,specs.ytxt1,2),specs.color, [])
        DrawFormattedText(w.id,specs.label2,scrconv(w,specs.xpos(2),1)-halftextwidth,scrconv(w,specs.ylabel,2),specs.confcolor, specs.wrapquestion)

        Screen('Flip', w.id);
        WaitSecs(specs.confirmwait);
        exit = 1;
    else
        parasiteresp.onset(end+1) = GetSecs;
        parasiteresp.button{end+1} = KbName(keyCode);
    end;
    
    KbReleaseWait;
end

end


