function [ output ] = picture_resp_association(w, spst, target_pic, resp_options, resp_type, good_resp, specs)
%PICTURE RESP ASSOCIATION: display picture & resp options,
% display an urgence message if too long, records relevant response and
% - w is the screenID where psychtoolbox should flip the stimulus
% - target_pic: corresponds to the image of 'choice'
% - resp_options: corresponds to the (3) possible next states (reordered outside)
% - specs is a structure accepting the following arguments
% if specs is empty or incomplete, then the default parameters below are
% used:
% 'resp_options_xpos' def = [0.3 0.5 0.7]
% 'resp_options_ypos' def = 0.4
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
defaults = struct('resp_options_xpos', [0.35 0.65],...
    'resp_options_ypos', 0.7, ...
    'resp_size', [0.075 0.075],...
    'txtstr', '',...
    'txtsize', 28,...
    'txtstyle',1,...
    'txtcol', [255 255 255],...
    'respindcol', [255 255 255],...
    'postchoicedur', 1,...
    'fwidth', 4,...
    'target_pos', [0.5 0.4],...
    'target_size', [0.5 0.5],...
    'resp_keymap', [37 39]);%,...
%     'respleft', 'left',...
%     'respmid', 'down',...
%     'respright', 'right');
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end
% specs.resp_keymap{1} = specs.respleft;
% specs.resp_keymap{2} = specs.respmid;
% specs.resp_keymap{3} = specs.respright;

prv_textsize = Screen('TextSize', w.id, specs.txtsize);
prv_textstyle = Screen('TextStyle', w.id, specs.txtstyle);

% draw picture
spst.image.fullpath = target_pic;
spst.image.pos = specs.target_pos;
spst.image.width = specs.target_size(1);
spst.image.height = specs.target_size(2);
eval(spst.image.exe);

for r = 1:length(resp_options)
    if resp_type(r)==1
        spst.text.str = resp_options{r};
        spst.text.pos(1) = specs.resp_options_xpos(r);
        spst.text.pos(2) = specs.resp_options_ypos;
        eval(spst.text.exe);
    elseif resp_type(r)==2
        spst.image.fullpath = resp_options{r};
        spst.image.pos(1) = specs.resp_options_xpos(r);
        spst.image.pos(2) = specs.resp_options_ypos;
        spst.image.width = specs.resp_size(1);
        spst.image.height = specs.resp_size(2);
        eval(spst.image.exe);
    end;
end;
spst.frame_circle.height = 0.025;
spst.frame_circle.penWidth = 5;
spst.frame_circle.pos = [0.5 specs.resp_options_ypos];
output.nresp = 0;
KbReleaseWait();
Screen('Flip',w.id,[],1);
output.onset(1) = GetSecs;
sortie = 0;
while sortie == 0 % && idur < jittertime-warning;
    [keyIsDown, keyCode ] = KbWait([],2);
    if sum(keyIsDown)>0
        output.resp_code = find(keyCode, 1, 'first');
        output.resp_name = lower(KbName(output.resp_code));
        output.resp_choice = strmatch(output.resp_code, specs.resp_keymap');
        if ismember(output.resp_code, specs.resp_keymap) && output.resp_choice==good_resp % acceptable responses
            output.resp_RT = GetSecs-output.onset;
            KbReleaseWait;
            if resp_type(r)==1
                spst.text.str = resp_options{output.resp_choice};
                spst.text.pos(1) = 0.5;
                spst.text.pos(2) = specs.target_pos(2);
%                 spst.text.color = [50 250 50];
                eval(spst.text.exe);
            elseif resp_type(r)==2
                spst.image.fullpath = resp_options{output.resp_choice};
                spst.image.pos(1) = 0.5;
                spst.image.pos(2) = specs.target_pos(2);
                eval(spst.image.exe);
            end;
%             spst.frame_circle.color = [50 200 50];
%             eval(spst.frame_circle.exe);
            Screen('Flip',w.id);
            output.nresp = output.nresp+1;
            PsychPortAudio('FillBuffer', spst.sounds.port_h(1), spst.sounds.wav{1});
            output.fb_onset(output.nresp) = PsychPortAudio('Start', spst.sounds.port_h(1), 1, 0, 1);
            WaitSecs(specs.postchoicedur);
            PsychPortAudio('Stop', spst.sounds.port_h(1));
            output.resp_acc = 1;
            sortie = 1;
        elseif ismember(output.resp_code, specs.resp_keymap)                                             % unacceptable responses
            output.resp_RT = GetSecs-output.onset;
            spst.frame_circle.color = [200 50 50];
            eval(spst.frame_circle.exe);
            Screen('Flip',w.id,[],1);
            output.nresp = output.nresp+1;
            PsychPortAudio('FillBuffer', spst.sounds.port_h(1), spst.sounds.wav{2});
            output.fb_onset(output.nresp) = PsychPortAudio('Start', spst.sounds.port_h(1), 1, 0, 1);
            WaitSecs(specs.postchoicedur);
            PsychPortAudio('Stop', spst.sounds.port_h(1));
            WaitSecs(specs.postchoicedur);
            output.resp_acc = 0;
            sortie = 1;
        else
            output.nresp = output.nresp+1;
            output.fb_onset(output.nresp) = GetSecs;
        end;
        KbReleaseWait;
    end;
end


Screen('TextSize', w.id, prv_textsize);
Screen('TextStyle', w.id, prv_textstyle);
Screen('Flip',w.id)

end
