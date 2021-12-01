close all; clear all;
% first pair for the training
colors = distinguishable_colors(30*3,[0 0 0; 180/255 180/255 180/255]);
%   figure(1)
%   image(reshape(colors,[1 size(colors)]));
% % 
% 
% for cp = [1:3:length(colors)]
%     figure(1)
%     image(reshape(colors(cp:cp+2,:),[1 size(colors(cp:cp+2,:))]));
%     cp
%     pause
% end
% 

goodtriplets = {...
    [1 2 3],...
    [4 5 6],...
    [9 10 11],...
    [12 13 14],...
    [17 18 19],...
    [20 21 22],...
    [28 29 30],...
    [43 44 45],...
    [55 57 58],...
    [63 66 67],...
    [73 74 79],...
    [81 82 85],...
    [88 89 90]};

% luminance homogenous
target_lumin = 0.5;
% always oppose 
% basis_set{1} = colors(4,:);
% basis_set{2} = colors(5,:);
% basis_set{3} = colors(6,:);

%colors = [];
for cp = 1:length(goodtriplets)
    % relative colorluminance of color circles (http://en.wikipedia.org/wiki/Relative_luminance)
    alea = rand;
    basis_set{1} = [alea 1-alea 0];
    basis_set{2} = [1-alea 0 alea];
    basis_set{3} = [0 1-alea alea];
    for c = 1:3
        dumset = [basis_set{c}(1)*(0.6+0.4*(rand-0.5)), basis_set{c}(2)*(0.6+0.4*(rand-0.5)), basis_set{c}(3)*(0.6+0.4*(rand-0.5))];
        dumlum = (0.2126*dumset(1) + 0.7152*dumset(2) + 0.0722*dumset(3));
        colors(goodtriplets{cp}(c),:) = 255*dumset*(target_lumin/dumlum);
    end
% figure(2)
%     image(reshape(colors(goodtriplets{cp},:),[1 size(colors(goodtriplets{cp},:))]));
%          cp
%      pause
    
end


Screen('Preference', 'SkipSyncTests', 2);
ScrNb = 0; % main screen is usually 0 on PCs // second screen is usually
[w.id w.rectpix] =Screen('OpenWindow',ScrNb, [0 0 0]);
w.centerpix = [w.rectpix(3)/2 w.rectpix(4)/2];
w.conv = [w.rectpix(3) w.rectpix(4) w.rectpix(3) w.rectpix(4)];
w.refreshrate = Screen('NominalFrameRate',w.id);
%Screen('BlendFunction', w.id, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');   % set la transparence (pour avoir des jolis points antialiases)
Screen('Flip',w.id);
HideCursor;

% write all combination of stims
colcomb = {[1 1 2], [2 1 3], [3 2 3], [1 2 1], [2 3 1], [3 3 2]};
serie = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'};
for t = 1:length(goodtriplets)  
    
    mkdir(['dualcircles/' serie{t}]);
    
    for c = 1:length(colcomb)
        
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{c}(2)),:) 1], [100 100 500 500], 0, 180);
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{c}(3)),:)  1], [100 100 500 500], 180, 180);
        
        Screen('Flip', w.id);
  
        WaitSecs(0.05);
       %   pause
        imgonscreen=Screen('GetImage', w.id, [100 100 500 500]);
        
        imwrite(uint8(imgonscreen), ['dualcircles/' serie{t} '/' num2str(colcomb{c}(1)) '_' num2str(colcomb{c}(2)) num2str(colcomb{c}(3)) '.jpg']);
        
    end
    
    for comb = 1:3
        
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{comb}(2)),:) 1], [100 100 500 500], 0, 90);
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{comb}(3)),:)  1], [100 100 500 500], 90, 90);
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{comb}(2)),:) 1], [100 100 500 500], 180, 90);
        Screen('FillArc', w.id, [colors(goodtriplets{t}(colcomb{comb}(3)),:)  1], [100 100 500 500], 270, 90);                
        Screen('Flip', w.id);
  
        WaitSecs(0.05);
       %   pause
        imgonscreen=Screen('GetImage', w.id, [100 100 500 500]);
        
        imwrite(uint8(imgonscreen), ['dualcircles/' serie{t} '/comb_' num2str(colcomb{comb}(1)) '.jpg']);
    end;
    
    
end;

Screen('CloseAll');
