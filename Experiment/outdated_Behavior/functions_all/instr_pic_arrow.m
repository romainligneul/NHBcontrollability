function [onset resp unwanted_resp] = instructions_picture(w, pic, index, varargin)
%INSTRUCTIONS Display instruction and ask for a double space press
%   Detailed explanation goes here

%%% initialize stuff
unwanted_resp = [];
out = 0;

%%% present instructions
onset = GetSecs;

p = imread(pic);
texture = Screen('MakeTexture', w.id, p);
Screen('DrawTexture', w.id, texture);
if ~isempty(varargin)
    DrawFormattedText(w.id,varargin{1}, 'center', 'center', [255 255 255]);
end
Screen('Flip',w.id);

while out == 0
    % monitor eventual parasite responses
    [keyIsDown, timeSecs, keyCode ] = KbCheck([],2);
    %KbName(find(keyCode))
    if sum(keyIsDown)>0
        if strcmp(KbName(find(keyCode)), 'LeftArrow')
            resp = -1; % usually, will be used to go back, therefore -1 is logical
            KbReleaseWait();
            out = out + 1;
        elseif strcmp(KbName(find(keyCode)), 'RightArrow')
            resp = 1;
            KbReleaseWait();
            out = out + 1;         
        else
            KbReleaseWait();
        end;
    end
end

%Screen('Close', texture);