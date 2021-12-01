function [ stim resp ] = simplechoice_threeresp( C, w, pic)
%SIMPLECHOICE:

%%% Making textures
% reverse?
texturename = [C.stim.path pic];
textrect = [scrconv(w,C.stim.sC.rect)];
% % assign info in stim structure

% initialize variables
exit = 0; parasiteresp = cell(0); resp = cell(0);

% wait for all keys to be released
KbCheck([],2);

% build image
textureimage = imread(texturename);
textureindex = Screen('MakeTexture', w.id, textureimage);

% get onset of the stimulus
stim.onset = GetSecs;

% initialize circles
xstep = (C.stim.sC.xrange(2)-C.stim.sC.xrange(1))/(C.stim.sC.steps-1);
radius = (xstep/2) - (xstep/8);
xpos = C.stim.sC.xrange(1);
selected = 0;%(C.stim.likert.steps+1)/2;
confirmed = 0;

% draw all
KbReleaseWait;
draw_circles(C, w, radius, xpos, xstep, selected)
Screen('DrawTexture', w.id, textureindex, [], textrect);
Screen('Flip',w.id);
stim.onset = GetSecs;

% wait response
exit = 0;
while exit == 0
 
     [keyIsDown, timeSecs, keyCode ] = KbCheck;
     WaitSecs(0.002);
      
      if sum(keyIsDown)>0
        resp.RT = GetSecs-stim.onset;
        resp.code = find(keyCode, 1, 'first');
        resp.name = lower(KbName(resp.code));
        if ismember(resp.name, {'left', 'down', 'right'}) % acceptable responses
            resp.chosen = strmatch(resp.name, {'left', 'down', 'right'}');
            exit = 1;
        end
      end
      
end;

KbReleaseWait;

% display response
% draw
KbReleaseWait
selected = resp.chosen;%(C.stim.likert.steps+1)/2;
draw_circles(C, w, radius, xpos, xstep, selected)
Screen('DrawTexture', w.id, textureindex, [], textrect);
Screen('Flip',w.id);
stim.responset = GetSecs;
while GetSecs-stim.responset < C.stim.sC.postwait 
end

%%%---- AUX function

    function draw_circles(C, w, radius, xpos, xstep, selected)
        
        for s = 1:C.stim.likert.steps
            
            rect(s,:) = scrconv(w,[xpos-radius C.stim.sC.yrange-radius xpos+radius C.stim.sC.yrange+radius]);
            
            % t1rect(s,:) = scrconv(w,[xpos-radius 0.4-radius xpos+radius 0.4+radius]);
            
            if s == selected
                color = C.stim.likert.selcolor;
            else
                color = C.stim.likert.color;
            end;

            Screen('FillOval', w.id, color, rect(s,:));
            
            xpos = xpos + xstep;
            
        end;

    end


end

