function [output resp_choice] = exploratory_trial( E, w, state, side, post_jitter)
%EXPLORATORY_TRIAL this function plays a simple exploratory trial and
%return a vector with trial information

% display trial
if side == 1
    Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{1});
    Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{2});
else
    Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{2});
    Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{1});    
end
Screen('Flip',w.id, [],1);
trial_onset = GetSecs;
exit = 0; warning = 0;
if E.serialkeys==1
    IOPort('Purge', E.mainserialport);
end
while exit == 0
    if E.serialkeys==0
        [keydown, secs, keyCode] = KbCheck();
    else
        %STRINGTOSERIALKEYMETHOD
        [keydown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_right_keycode)
    end
    if keydown && find(keyCode, 1, 'first') == E.left_right_keycode(1)
        resp_onset = GetSecs;
        resp_RT = secs-trial_onset;
        resp_side = 1; exit = 1;
    elseif keydown && find(keyCode, 1, 'first')==E.left_right_keycode(2)
        resp_onset = GetSecs;
        resp_RT = secs-trial_onset;
        resp_side = 2; exit = 1;
    end
    if GetSecs-trial_onset>E.timing.stdwarning && warning==0
        Screen('DrawTexture', w.id, E.warning.texture_id, [], E.warning.rect);
        Screen('Flip', w.id);
        warning = 1;
    end
end;
if warning==0;Screen('Flip',w.id);end;
resp_choice = E.explore.mapping{side}{state}(resp_side);
fade_onset = GetSecs;
%%% fade off
while GetSecs-fade_onset< E.timing.fadedur
    advance = (GetSecs-fade_onset)/E.timing.fadedur;
    if side == 1
        Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{1},[],[],1-advance);
        Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{2},[],[],1-advance);
    else
        Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{2},[],[],1-advance);
        Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{1},[],[],1-advance);
    end
    Screen('Flip', w.id);
end
Screen('Flip', w.id);
fade_offset = GetSecs;
WaitSecs(post_jitter);

output = [side resp_side resp_RT resp_choice warning post_jitter trial_onset resp_onset fade_onset fade_offset]
end

