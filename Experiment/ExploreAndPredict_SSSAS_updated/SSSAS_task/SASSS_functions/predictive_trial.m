function [output resp_choice resp_acc] = predictive_trial( E, w, state, ordering, hyp_LR, correct_resp, feedback, post_jitter)
%PREDICTIVE_TRIAL this function plays a simple predictive trial and
%return a vector with trial information
% [output resp_choice resp_acc] = predictive_trial( E, w, state, ordering, hyp_LR, correct_resp, feedback, post_jitter)
% hypothesis
Screen('DrawTexture', w.id, E.explore.texture_id(state,hyp_LR), [], E.predict.hypothesis_rect);

% alternatives
for o = 1:3
    Screen('DrawTexture', w.id, E.predict.texture_id(ordering(o),1), [], E.predict.target_rect{o});
end

% wait for response
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
        [keydown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_middle_right_keycode)
    end
    if keydown && find(keyCode, 1, 'first') == E.left_middle_right_keycode(1)
        resp_onset = secs;
        resp_RT = secs-trial_onset;
        resp_side = 1; exit = 1;
    elseif keydown && find(keyCode, 1, 'first')==E.left_middle_right_keycode(2)
        resp_onset = secs;
        resp_RT = secs-trial_onset;
        resp_side = 2; exit = 1;
    elseif keydown && find(keyCode, 1, 'first')==E.left_middle_right_keycode(3)
        resp_onset = secs;
        resp_RT = secs-trial_onset;
        resp_side = 3; exit = 1;
    end
    if GetSecs-trial_onset>E.timing.predwarning && warning==0
        Screen('DrawTexture', w.id, E.warning.texture_id, [], E.warning.rect);
        Screen('Flip', w.id);
        warning = 1;
    end
end;
if warning==0;Screen('Flip',w.id);end;
resp_choice = ordering(resp_side);
resp_acc = double(correct_resp==resp_choice);

%%% display response & eventually feedback
Screen('DrawTexture', w.id, E.explore.texture_id(state,hyp_LR), [], E.predict.hypothesis_rect);
for o = 1:3
    if o == resp_side
        Screen('DrawTexture', w.id, E.predict.texture_id(ordering(o),2), [], E.predict.target_rect{o});
    else
        Screen('DrawTexture', w.id, E.predict.texture_id(ordering(o),1), [], E.predict.target_rect{o});
    end
end
post_onset = GetSecs;
if E.serialport
    % write state_hyp code
    if feedback == 1
        IOPort('Write', E.mainserialport, E.serialtrig.reinforcer{resp_acc+1}, 0);
    else
        IOPort('Write', E.mainserialport, E.serialtrig.reinforcer{3}, 0);
    end
end
if feedback == 0
    Screen('Flip', w.id);
    WaitSecs(E.timing.predfeedback + E.timing.predhighlight);
else
    Screen('DrawTexture', w.id, E.feedback.texture_id(resp_acc+1), [], E.feedback.rect);
    Screen('Flip', w.id);
    WaitSecs(E.timing.predfeedback+E.timing.predhighlight);
end
post_offset = GetSecs;

Screen('Flip', w.id);
fade_offset = GetSecs;
WaitSecs(post_jitter);

output = [hyp_LR resp_side resp_RT resp_choice correct_resp resp_acc feedback warning post_jitter trial_onset resp_onset post_onset post_offset]


