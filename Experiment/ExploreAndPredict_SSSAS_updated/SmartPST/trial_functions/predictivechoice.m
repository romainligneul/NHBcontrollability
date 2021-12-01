function [ stim resp ] = predictivechoice(w, st_img, next_img, respside, specs, progress)
% PREDICTIVE CHOICE displays one color pair along with a 'choice' made (or
% not) by the subject and wait for a (predictive) response.
% - w is the screenID where psychtoolbox should flip the stimulus
% - st_img: corresponds to the image of 'choice'
% - next_img: corresponds to the (3) possible next states (reordered outside)
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are
% used:
% 'next_xpos' def = [0.3 0.5 0.7]
% 'next_ypos' def = 0.4
% 'next_radius' def = 0.05
% 'txtstr' def = 'next?'
% 'txtcol' def = [180 180 180]
% 'txtsize' def = 30
% 'txtcol' def = [180 180 180]
% 'respindcol' def = [180 180 180]
% 'postchoicedur' def = 0.3
% 'fwidth' def = 4
% 'respbuttons' def = {'left', 'down', 'right'}
% ''bgcolor', [180 180 180];

% assign defaults and manually specified parameters
defaults = struct('next_xpos', [0.3 0.5 0.7],...
    'next_ypos', 0.4, ...
    'next_radius', 0.05,...
    'txtstr', 'next?',...
    'txtsize', 45,...
    'txtcol', [255 255 255],...
    'respindcol', [255 255 255],...
    'bgcolor', [0 0 0],...
    'postchoicedur', 0.3,...
    'fwidth', 4,...
    'st_rect', [0.4 0.58 0.6 0.78],...
    'respleft', 'left',...
    'respmid', 'down',...
    'respright', 'right');
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end
specs.resp_keymap{1} = specs.respleft;
specs.resp_keymap{2} = specs.respmid;
specs.resp_keymap{3} = specs.respright;


%%% General specs
Screen('TextSize', w.id, specs.txtsize);
KbReleaseWait();
% build the progress bar
if ~isempty(progress)
    progressrect = scrconv(w,progress.rect);
    progressrect(3) = progressrect(1)+ (progressrect(3)- progressrect(1))*progress.progress(1);
    Screen('FillRect',w.id,progress.fillcolor,  progressrect);
    Screen('FrameRect',w.id,  progress.pencolor, scrconv(w,progress.rect), progress.penwidth);   
end

%%% change backgroup to grey
Screen('FillRect', w.id,  specs.bgcolor, w.rectpix);

%%% Making texture of s(t) pair (showing pseudochoice)
% load texture
st_ti = Screen('MakeTexture', w.id, st_img);
% positionning of s(t) pair
st_rect = [specs.st_rect(1,1)  specs.st_rect(1,2)  specs.st_rect(1,3)  specs.st_rect(1,4)];
st_rect = scrconv(w,st_rect);
% draw s(t) pair
Screen('DrawTexture', w.id, st_ti , [], st_rect);
% display target indicator
Screen('TextStyle', w.id, 1);
if respside == 1 % left
    Screen('DrawText', w.id, '?' , mean(st_rect(1,[1 3]),2)-((st_rect(1,3)-st_rect(1,1))/5)-(specs.txtsize/2), mean(st_rect(1,[2 4]))-specs.txtsize, [0 0 0]);
else % right
    Screen('DrawText', w.id, '?' , mean(st_rect(1,[1 3]),2)+((st_rect(1,3)-st_rect(1,1))/5), mean(st_rect(1,[2 4]))-specs.txtsize, [0 0 0]);   
end
Screen('TextStyle', w.id, 0);
%% Making texture of possible next states (i.e. alternative response)
% nb: reordered prior to function call
for i = 1:3
    % load texture
    next_ti(i) = Screen('MakeTexture', w.id, next_img{i});
    % define rect (prereordered)
    next_rect(:,i) = scrconv(w,[specs.next_xpos(i)-specs.next_radius specs.next_ypos-specs.next_radius specs.next_xpos(i)+specs.next_radius specs.next_ypos+specs.next_radius]);
    % draw
    Screen('DrawTexture', w.id, next_ti(i), [],next_rect(:,i)');
end

% draw instruction text
DrawFormattedText(w.id, specs.txtstr , 'center', 'center', specs.txtcol);

% flip everything once and maintain in cache for the next flip
exit = 0;
Screen('Flip', w.id, [],1);
stim.onset = GetSecs;

% start response waiting loop
while exit == 0
    [keyIsDown, timeSecs, keyCode ] = KbCheck;
    if sum(keyIsDown)>0
        resp.code = find(keyCode, 1, 'first');
        resp.name = lower(KbName(resp.code));
        if ismember(resp.name, specs.resp_keymap) % acceptable responses
            resp.RT = GetSecs-stim.onset;
            resp.choice = strmatch(resp.name, specs.resp_keymap');
            exit = 1;
        else % unacceptable responses / just indicate that another button has been pressed before target
            resp.unwantedresp = find(resp.code);
        end;
        KbReleaseWait;
    end;
    % condition for clock appearance?
end;

% display answer provided by the subject
dumsec = GetSecs;
Screen('FrameOval', w.id, specs.respindcol', next_rect(:,resp.choice), specs.fwidth);
Screen('Flip', w.id);
while GetSecs-dumsec < specs.postchoicedur
end;



end

