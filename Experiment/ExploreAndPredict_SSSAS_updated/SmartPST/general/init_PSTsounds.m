function sounds = init_PSTsounds(sounds_paths, device, mode)
% sounds_paths = {'\home\sound.wav',...};
% devide = use a specific device, otherwise leave empty
% mode = 1 for sound playback
for s = 1:length(sounds_paths)
    [wavedata sounds.freq] = audioread(sounds_paths{s});
    nrchannels = size(wavedata,2); % Number of rows == number of channels.
    if nrchannels < 2
        wavedata = [wavedata' ; wavedata'];
        nrchannels = 2;
    end
    sounds.wav{s} = wavedata;
end;
InitializePsychSound;
if isempty(mode);mode=1;end;
for m = 1:length(mode)
    sounds.port_h(m) = PsychPortAudio('Open', device, [], 0, sounds.freq, nrchannels);
end

end

