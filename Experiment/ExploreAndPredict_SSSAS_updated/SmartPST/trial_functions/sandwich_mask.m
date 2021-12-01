function [ output ] = sandwich_mask(w, spst, mask1, mask2, target, frame_dur, specs)
%Simple sandwich masking: display picture & resp options,

% assign defaults and manually specified parameters
defaults = struct(...
    'target_pos', [0.5 0.45],...
    'target_size', [0.5 0.5],...
    'post_frames', 18,...
    'pre_frames', 6);
for f = fieldnames(defaults)',
    if ~isfield(specs, f{1}),
        specs.(f{1}) = defaults.(f{1});
    end
end

% prepare pictures
spst.image.pos = specs.target_pos;
spst.image.width = specs.target_size(1);
spst.image.height = specs.target_size(2);


spst.image.fullpath = mask2;

ff = 1;
% premask
for f = 1:specs.pre_frames;
    spst.image.fullpath = mask1; 
    eval(spst.image.exe);
    [output.VBLTimestamp(ff) output.StimulusOnsetTime(ff) output.FlipTimestamp(ff) output.Missed(ff)] = Screen('Flip', w.id);
    if f == 1
        output.premask_onset = GetSecs;
    end;
    ff=ff+1;
end;

% target
for f = 1:frame_dur;
    spst.image.fullpath = target;
    eval(spst.image.exe);
    [output.VBLTimestamp(ff) output.StimulusOnsetTime(ff) output.FlipTimestamp(ff) output.Missed(ff)] = Screen('Flip', w.id);
    if f == 1
        output.target_onset = GetSecs;
    end;
    ff=ff+1;
end;

% post mask
for f = 1:specs.post_frames-frame_dur
    spst.image.fullpath = mask2; 
    eval(spst.image.exe);
    [output.VBLTimestamp(ff) output.StimulusOnsetTime(ff) output.FlipTimestamp(ff) output.Missed(ff)] = Screen('Flip', w.id);
    if f == 1
        output.postmask_onset = GetSecs;
    end;
    ff=ff+1;
end

eval(spst.image.exe);
Screen('Flip', w.id,[],1);

end
