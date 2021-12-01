function [ Tstruct Ostruct] = SAS_subfunctions( method, w, E, spst, Tstruct, varargin )
% HELPER_FUNCTIONS for the SAS experiment
% just to make the main code more readable and adaptable
% input arguments are flexible
% output argument are two structures: one is an updated Tstruct, the other
% is a flexible structure to put anything into.

switch method
    
    case 'wait_and_fade'
        
        exit = 0; noreflip = 1;
        while exit == 0
            [secs, keyCode] = KbWait([],2);%, Tstruct.resp_onset+E.timing.stdwarning);
            if find(keyCode) == E.predbuttoncodes(1);
                Tstruct.resp_RT = GetSecs-Tstruct.resp_onset;
                Tstruct.resp_side = 1; exit = 1;
            elseif find(keyCode)== E.predbuttoncodes(2);
                Tstruct.resp_RT = GetSecs-Tstruct.resp_onset;
                Tstruct.resp_side = 2; exit = 1;
            end
            if GetSecs-Tstruct.resp_onset>E.timing.stdwarning
                spst.text.pos = E.pos{10}; % 8/9
                spst.text.str = E.msg{10};
                if noreflip
                    eval(spst.text.exe_warning);
                    Screen('Flip', w.id);
                end
                noreflip = 0;
            end
            KbReleaseWait();
        end;
        if noreflip;Screen('Flip',w.id);end;
        Tstruct.resp_choice = Tstruct.pair(Tstruct.resp_side);
        WaitSecs(E.timing.stdpostchoice);
        Tstruct.fade_onset = GetSecs;
        %%% fade off
        while GetSecs-Tstruct.fade_onset< E.timing.fadedur
            advance = (GetSecs-Tstruct.fade_onset)/E.timing.fadedur;
            for o = 1:2
                spst.form{Tstruct.s}.pos = E.pos{o};
                spst.form{Tstruct.s}.color = E.colors{Tstruct.pair(o)}*(1-advance) + w.bg*advance;
                eval(spst.form{Tstruct.s}.exe);
            end;
            Screen('Flip', w.id);
        end
        for o = 1:2 % force zeros
            spst.form{Tstruct.s}.color = [w.bg];
            eval(spst.form{Tstruct.s}.exe);
        end
        Screen('Flip', w.id);
        for o = 1:2 % reset good colors after flip
            spst.form{stdtrial.s}.color = E.colors{Tstruct.pair(o)};
        end
        WaitSecs(E.timing.postfade);
end


end

