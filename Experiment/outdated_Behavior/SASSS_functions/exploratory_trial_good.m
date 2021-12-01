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
Screen('Flip',w.id);
trial_onset = GetSecs;
exit = 0; warning = 0;advance = 0; resp_onset = [];
if E.serialkeys==1
    IOPort('Purge', E.mainserialport);
end
while exit < 2
    if E.serialkeys==0
        [keydown, secs, keyCode] = KbCheck();
    else
        %STRINGTOSERIALKEYMETHOD
        [keydown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_right_keycode)
    end
    if isempty(resp_onset)
        if keydown && find(keyCode, 1, 'first') == E.left_right_keycode(1)
            resp_onset = GetSecs;
            resp_RT = secs-trial_onset;
            resp_side = 1; exit = exit+1;
        elseif keydown && find(keyCode, 1, 'first')==E.left_right_keycode(2)
            resp_onset = GetSecs;
            resp_RT = secs-trial_onset;
            resp_side = 2; exit = exit+1; % condition 1 on exit: response has occured
        end
    end
    % manage warning
    if GetSecs-trial_onset>E.timing.stdwarning && isempty(resp_onset)
        Screen('DrawTexture', w.id, E.warning.texture_id, [], E.warning.rect);
        warning = 1;
    end
    % manage fade
    if GetSecs-trial_onset> E.timing.fadedelay
        if advance == 0;
            fade_onset = GetSecs;
        end
        advance = (GetSecs-fade_onset)/E.timing.fadedur;
        if advance >= 1;
            advance = 1;
            if ~isempty(resp_onset)
            exit = exit+1; % condition 1 on exit: fade is done
            end
        end
    end
    if side == 1
        Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{1},[],[],1-advance);
        Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{2},[],[],1-advance);
    else
        Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{2},[],[],1-advance);
        Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{1},[],[],1-advance);
    end
    Screen('Flip',w.id);
end;
resp_choice = E.explore.mapping{side}{state}(resp_side);
fade_offset = GetSecs;
% fade_onset = GetSecs;
% %%% fade off
% while GetSecs-fade_onset< E.timing.fadedur
%     advance = (GetSecs-fade_onset)/E.timing.fadedur;
%     if side == 1
%         Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{1},[],[],1-advance);
%         Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{2},[],[],1-advance);
%     else
%         Screen('DrawTexture', w.id, E.explore.texture_id(state,1), [], E.explore.target_rect{2},[],[],1-advance);
%         Screen('DrawTexture', w.id, E.explore.texture_id(state,2), [], E.explore.target_rect{1},[],[],1-advance);
%     end
%     Screen('Flip', w.id);
% end
% Screen('Flip', w.id);
% 
% correction of jitter in case of miss
if warning == 1
post_jitter = post_jitter-((fade_offset-fade_onset)-E.timing.fadedelay);
if post_jitter<0.1;
    post_jitter = 0.1;
end
end
WaitSecs(post_jitter);

output = [side resp_side resp_RT resp_choice warning post_jitter trial_onset resp_onset fade_onset fade_offset]
end

