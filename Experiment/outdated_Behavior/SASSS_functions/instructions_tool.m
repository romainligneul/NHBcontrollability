function [E output ] = instructions_tool( E, w, method, varargin)
%INSTRUCTIONS_TOOL Summary of this function goes here
% for load, only E.instructions.dir is needed
% for display, varagin{1} = w
%              varargin{2} = start_index
%              varargin{3} = final_index
%              varargin{4} = nocomeback

switch method
    case 'load'
        instrfiles = dir([E.instructions.dir '*jpg']);
        dumid = [];
        for f = 1:length(instrfiles);
            id(f) = str2num(instrfiles(f).name(~isletter(instrfiles(f).name)));
            E.instructions.pics{f} = [E.instructions.dir instrfiles(f).name];
            E.instructions.texture_id(f) = Screen('MakeTexture', w.id,  imread(E.instructions.pics{f}));
        end
        [~, ind] = sort(id);
        E.instructions.pics = E.instructions.pics(ind);
        E.instructions.texture_id = E.instructions.texture_id(ind);
        output =[];
        
    case 'display'
        
        %              varargin{1} = start_index
        %              varargin{2} = final_index
        %              varargin{3} = nocomeback
        instr_length = varargin{2};
        instr_i = varargin{1};
        ind = 1;
        
        while instr_i <= instr_length
            
            %%% present instructions
            output.onset.display(ind) = GetSecs;
            Screen('DrawTexture', w.id,E.instructions.texture_id(instr_i));
            Screen('Flip',w.id);
            out = 0;
            if E.serialkeys==1
                IOPort('Purge', E.mainserialport);
            end
            while out == 0
                if E.serialkeys==0
                    [keyIsDown, secs, keyCode] = KbCheck();
                else
                    %STRINGTOSERIALKEYMETHOD
                    [keyIsDown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_right_keycode)
                end
                %KbName(find(keyCode))
                if sum(keyIsDown)>0
                    output.onset.keypress(ind) = GetSecs;
                    if find(keyCode,1,'first') == E.instructions.left_right_keycode(1)
                        resp = -1; % usually, will be used to go back, therefore -1 is logical
                        KbReleaseWait();
                        out = out + 1;
                    elseif find(keyCode,1,'first') == E.instructions.left_right_keycode(2)
                        resp = 1;
                        KbReleaseWait();
                        out = out + 1;
                    else
                        KbReleaseWait();
                    end;
                end
                %Screen('Close', texture);
                ind = ind+1;
            end
            instr_i = instr_i + resp;WaitSecs(0.1);
            if instr_i < 1; instr_i = 1; end;
            if instr_i > instr_length; break; end;
            try
                if instr_i < varargin{3}; instr_i=varargin{1};end
            end
        end
end
