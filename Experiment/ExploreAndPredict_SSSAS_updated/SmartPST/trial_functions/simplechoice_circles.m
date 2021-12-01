function [ stim resp ] = simplechoice(w, st_img, stresp_img, jittertime, specs)
%SIMPLECHOICE: display stimuli dot, wait response, display an urgence
% message if too long, records relevant response and eventually fades the
% stimulus.
% INPUTS:
% - w is the screenID where psychtoolbox should flip the stimulus
% - st_img is the complete filename of the picture to be read and displayed
% - stresp_img structure containing the "response images"
% - jittertime: jitter at the end of the trial randomly split before and
% after fading
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are
% used:
% 'rect', position of the stimulus on the screen. def= [0.4 0.4 0.6 0.6]
% 'fadeoff', duration of the fading period in second. def = 0.3
% 'warningdelay', duration before the appearance of the clock in seconds. def = 2
% 'clockimg', path to clock image: def 'general_stims\clock_small.png'
% 'clock_y', def = 0.8,...
% 'clock_x', def =0.5,...
% 'clock_halfheight', size of the clock. def = 0.1

% assign defaults and manually specified parameters
defaults = struct('rect', [0.4 0.4 0.6 0.6],...
    'fadeoff', 0.3,...
    'warningdelay', 2,...
    'clockimg', 'general_stims\clock_small.png',...
    'clock_y', 0.8,...
    'clock_x', 0.5,...
    'clock_halfheight', 0.1,...
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


% wait for all keys to be released
KbReleaseWait();

% display circles once
if ischar(st_img)
textureimage = imread(st_img);
else
    textureimage = st_img;
end;
textureindex = Screen('MakeTexture', w.id, textureimage);

% get onset of the stimulus
stim.onset(1) = GetSecs;

% initialize variables
exit = 0;
idur = 0;
textrect = [scrconv(w,specs.rect)];

Screen('DrawTexture', w.id, textureindex, [], textrect);
Screen('Flip', w.id);

% start initial looping
while exit == 0 % && idur < jittertime-warning;
    
    [keyIsDown, timeSecs, keyCode ] = KbCheck;
    if sum(keyIsDown)>0
        resp.code = find(keyCode, 1, 'first');
        resp.name = lower(KbName(resp.code));
        if ismember(resp.name, specs.resp_keymap) % acceptable responses
            resp.choice = strmatch(resp.name, specs.resp_keymap');
            resp.RT = GetSecs-stim.onset;
            KbReleaseWait;
            exit = 1;
        else                                             % unacceptable responses
        end;
        KbReleaseWait;
    end;
    
    %%% draw circle
    if idur > specs.warningdelay
        clockname = [specs.clockimg];
        clockimage = imread(clockname);
        clockrect= scrconv(w,[specs.clock_x-(specs.clock_halfheight*0.7617) specs.clock_y-specs.clock_halfheight specs.clock_x+(specs.clock_halfheight*0.7617) specs.clock_y+specs.clock_halfheight]);
        clockindex = Screen('MakeTexture', w.id, clockimage);
        Screen('DrawTexture', w.id, textureindex, [], textrect);
        Screen('DrawTexture', w.id, clockindex, [], clockrect);
        Screen('Flip', w.id);
        idur = 0; % this little trick makes sure that the program doesn't flip unnecessarily
    else
        idur = GetSecs-stim.onset;
    end
    
end;

% build substitute the st texture for the stresp texture
if ~isempty(stresp_img)
    resp_img = stresp_img{resp.side};
    textureimage = imread(resp_img);
    textureindex = Screen('MakeTexture', w.id, textureimage);
    Screen('Flip', w.id);
end

% wait some time before fading.
randsplitjit = rand;
WaitSecs(jittertime*randsplitjit);

% decay if necessary
if specs.fadeoff>0
    % set decay
    nframes = specs.fadeoff*w.refreshrate;
    decaysteps = [1:-1/nframes:0.001];
    % make sure a few frames are completely blacks in the end
    nframes = nframes + 3;
    decaysteps(end:end+3) = 0;
    exit = 0;flipoval = 0;
    % decaysteps
    played_frames = 1;
    % write decay onset
    stim.onset(2) = GetSecs;
    while played_frames<=nframes
        Screen('DrawTexture', w.id, textureindex, [],textrect,[],[],decaysteps(played_frames));
        Screen('Flip', w.id);
        WaitSecs(0.001);
        played_frames = played_frames+1;
    end;
    Screen('Flip', w.id);
end

% last waiting period
WaitSecs(jittertime*(1-randsplitjit));

end

