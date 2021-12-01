%
clear all;

% dependencies needed
addpath(genpath('../SmartPST'));
addpath(genpath('SASSS_functions'));
E.stimdir = ['SASSS_stim\'];
load('active_subject.mat');
E.serialport = 1;
E.serialkeys = 1;
%%% open PST screen
w = open_PSTscreen(0, [122 122 122], 2,1, 1);
w.bg = [180 180 180];
%Screen('CloseAll')

%%% define instructions
E.instructions.dir =[E.stimdir 'instructions_calibration\'];
E.instructions.left_right_keycode = [37 39];

if E.serialport
    
    E.serialtrig.predictstate_action{1} = {'21', '22', '23'}; 
    E.serialtrig.predictstate_action{2} = {'24', '25', '26'}; 
    E.serialtrig.predictstate_action{3} = {'27', '28', '29'}; 
    E.serialtrig.predictstate_action{4} = {'30', '31', '32'};
    E.serialtrig.explorestate{1} = {'41', '42', '43'}; %
    E.serialtrig.explorestate{2} = {'44', '45', '46'}; % 
    E.serialtrig.explorestate{3} = {'47', '48', '49'}; %
    E.serialtrig.explorestate{4} = {'50', '51', '52'}; %
    
    E.serialtrig.reinforcer = {'61', '62', '63'}; % + / - / null
    
    E.left_right_keycode = [97 99];
    E.left_middle_right_keycode = [97 98 99];
    E.instructions.left_right_keycode = [97 99];

    % open eye-track + respi + cardio port
    specialSettings = [];
    joker = '';
    baudRate = 115200;
    portSettings = sprintf('%s %s BaudRate=%i ReadFilterFlags=1', joker, specialSettings, baudRate);
    E.mainserialport = IOPort('OpenSerialPort', 'COM2',portSettings);

end

%%% load instruction textures
E = instructions_tool(E,w,'load');
%%% display first round of instructions

%%% define rectangles for exploratory trials
E.target_xwidth = [0.5 0.05 0.05 0.95 0.95];
E.target_ypos = [0.5 0.05 0.95 0.05 0.95];
E.target_halfsize = 0.015;
for o = 1:length(E.target_xwidth)
    E.explore.target_rect{o} = scrconv(w,[E.target_xwidth(o)-E.target_halfsize E.target_ypos(o)-E.target_halfsize E.target_xwidth(o)+E.target_halfsize E.target_ypos(o)+E.target_halfsize]);
end
[img, ~, alpha] = imread([E.stimdir 'eyetrack_stim.png']);
img(:,:,4) = alpha;
E.texture_id = Screen('MakeTexture',w.id,img);

[E output] = instructions_tool(E,w, 'display', 1, 1, 1);

for t = 1:5
    
   Screen('DrawTexture', w.id, E.texture_id, [], E.explore.target_rect{t});
   Screen('Flip',w.id);
   if E.serialport
       % write state UC/C code
       IOPort('Write', E.mainserialport, uint8(200+t), 0);
   end
   WaitSecs(4);
   
   Screen('Flip',w.id);
   WaitSecs(1);
 
end

color = [0 0 0; 255 255 255];
col = randi(2);
[E output] = instructions_tool(E,w, 'display', 2, 2, 2);

for tt = 1:10
    
   Screen('FillRect', w.id,color(col,:), w.rectpix);
   Screen('Flip',w.id);
   if E.serialport
       % write state UC/C code
       IOPort('Write', E.mainserialport, uint8(210+col), 0);
   end
   WaitSecs(3);

   Screen('FillRect', w.id,[122 122 122], w.rectpix);   
   Screen('Flip',w.id);
   if E.serialport
       % write state UC/C code
       IOPort('Write', E.mainserialport, uint8(210), 0);
   end   
   WaitSecs(2);
   
   col = 3-col;
 
end
filename = mfilename;
save([filename '_' S.fullid '.mat']);
try
    save(['M:\fMRI_logfiles\' S.fullid '\' filename '_' S.fullid '.mat'])
end
Screen('CloseAll')



