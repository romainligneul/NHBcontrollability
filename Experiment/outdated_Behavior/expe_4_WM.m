%%%%%% Modified N-back
clear all;
addpath(genpath('../SmartPST'));

run('objects_generator');

load('active_subject');
tic
% open PST if necessary
if S.automated == 0;
    w = open_PSTscreen(0, [180 180 180], 2,1, 1);
end
external_folder = 'M:\Experiments_Logfiles\SAS_protocol\WM_logs\';

% detect ABC pattern / 3 different in a row
% detect ABCD pattern / 4 different in a row
% detect AXA pattern / 2 back
% detect AXXA pattern / 3 back
%%% define conditions
E.conds = [1 2]; % cond 1 = ABC type / cond 2 = AXA type
E.levels = [3 4 3 4]; % levels correspond to the target pattern length
E.r_bycond_bylevel = [8 8 8 8];
E.nchars = 10;
E.filler_lengths = {[0 1 1 1 2 2 3 4]+1, [0 1 1 1 2 2 3 4], [0 1 1 1 2 2 3 4]+1, [0 1 1 1 2 2 3 4]};
% fillers_lengths should match r_bycond-bylevel and will be shuffled

%%% define stimuli
% text
spst.text.color = [255 255 255];
spst.text.pos = [0.5 0.5];
E.number_font = 70;
E.normal_font = 30;
Screen('TextFont', w.id, 'Calibri');

%%% define durations
E.trialdur = 1.5;
E.displaydur = 0.7;
E.duration_interblock_instructions = 5;
E.warningmsg_duration = 1;

for c= 1:length(E.conds)
    
    for l = 1:length(E.r_bycond_bylevel)
        
        E.filler_lengths{l} = Shuffle(E.filler_lengths{l});
        E.useful{c,l} = 0;
        
        while sum(E.useful{c,l}(:,1)) ~= E.r_bycond_bylevel(l)
            % initialize streak
            streak = [1 4 2 5]+randi(4);
            
            for r = 1:E.r_bycond_bylevel(l)
                
                filler_length = E.filler_lengths{l}(r);%fill_ind{l,c}(r,2)-fill_ind{l,c}(r,1);
                
                
                if c == 1; %%%% CASE INCREASING ORDER
                    
                    % get filler pattern
                    subexit = -1;
                    while subexit < (filler_length)
                        fill_pattern = randi(E.nchars,1,filler_length)-1;
                        dumstreak = [streak fill_pattern];
                        subexit = 0;
                        %    if dumstreak(end)==1;continue;end;
                        %  while sum(sign(diff(fill_pattern))>0)~=E.levels(l)-1 || subexit < E.levels(l) % numel(unique(target_pattern))~=E.levels(l)
                        for u = 0:length(fill_pattern)-1
                            if  ismonotonic(dumstreak(end-u-E.levels(l)+1:end-u),1);% ismonotonic(dumstreak(end-u-E.levels(l)+1:end-u),1, 'INCREASING') % sum(sign(diff(dumstreak(end-u-E.levels(l)+1:end-u)))>0)==E.levels(l)-1 % numel(unique(dumstreak(end-u-E.levels(l)+1:end-u)))
                                subexit = 0;
                            else
                                subexit = subexit+1;
                            end
                        end
                        %  end
                    end % here, we have a decent target pattern
                    streak =  [streak fill_pattern];
                    
                    % get any target pattern
                    target_pattern = zeros(1,E.levels(l));
                    subexit = -1;
                    while subexit < E.levels(l) % numel(unique(target_pattern))~=E.levels(l)
                        subexit = 0;
                        target_pattern = randi(E.nchars,1,E.levels(l))-1;
                        dumstreak = [streak target_pattern];
                        for u = 0:length(target_pattern)-1
                            if ismonotonic(dumstreak(end-u-E.levels(l)+1:end-u),1);%ismonotonic(dumstreak(end-u-E.levels(l)+1:end-u),1, 'INCREASING')  % numel(unique(dumstreak(end-u-E.levels(l)+1:end-u)))
                                if u==0
                                    subexit = subexit+1;
                                else
                                    subexit = 0;
                                end
                            else
                                if u>0
                                    subexit = subexit+1;
                                else
                                    subexit = 0;
                                end
                            end
                        end
                    end % here, we have a decent target pattern
                    streak = [streak target_pattern];
                    
                    
                else    %%%% CASE N-BACK
                    
                    % get filler pattern
                    subexit = 0;
                    while subexit < (filler_length)
                        fill_pattern = randi(E.nchars,1,filler_length)-1;
                        dumstreak = [streak fill_pattern];
                        if dumstreak(end)==1;continue;end;
                        %  while sum(sign(diff(fill_pattern))>0)~=E.levels(l)-1 || subexit < E.levels(l) % numel(unique(target_pattern))~=E.levels(l)
                        for u = 0:length(fill_pattern)-1
                            if  dumstreak(end-u-E.levels(l)+1) == dumstreak(end-u) % sum(sign(diff(dumstreak(end-u-E.levels(l)+1:end-u)))>0)==E.levels(l)-1 % numel(unique(dumstreak(end-u-E.levels(l)+1:end-u)))
                                subexit = 0;
                            else
                                subexit = subexit+1;
                            end
                        end
                        %  end
                    end % here, we have a decent target pattern
                    streak =  [streak fill_pattern];
                    
                    % get any target pattern
                    target_pattern = zeros(1,E.levels(l));
                    subexit = 0;
                    while subexit < E.levels(l) % numel(unique(target_pattern))~=E.levels(l)
                        subexit = 0;
                        target_pattern = randi(E.nchars,1,E.levels(l))-1;
                        dumstreak = [streak target_pattern];
                        for u = 0:length(target_pattern)-1
                            if dumstreak(end-u-E.levels(l)+1) == dumstreak(end-u)  % numel(unique(dumstreak(end-u-E.levels(l)+1:end-u)))
                                if u==0
                                    subexit = subexit+1;
                                else
                                    subexit = 0;
                                end
                            else
                                if u>0
                                    subexit = subexit+1;
                                else
                                    subexit = 0;
                                end
                            end
                        end
                    end % here, we have a decent target pattern
                    streak = [streak target_pattern];
                    
                    
                end
                
            end
            
            E.streak{c,l} = streak;
            
            for t= E.levels(l):length(E.streak{c,l})
                
                if c == 1;
                    if  ismonotonic(E.streak{c,l}(t-E.levels(l)+1:t),1);%ismonotonic(E.streak{c,l}(t-E.levels(l)+1:t),1, 'INCREASING')
                        E.useful{c,l}(t,1) = 1; % hit expected
                        E.useful{c,l}(t,2) = E.levels(l)-1;
                    else
                        E.useful{c,l}(t,1) = 0;
                        if ismonotonic(E.streak{c,l}(t-E.levels(l)+2:t),1);%, 'INCREASING'); %ismonotonic(E.streak{c,l}(t-E.levels(l)+2:t),1, 'INCREASING');
                            E.useful{c,l}(t,2) = E.levels(l)-2;
                        elseif ismonotonic(E.streak{c,l}(t-E.levels(l)+2:t),1); %ismonotonic(E.streak{c,l}(t-E.levels(l)+3:t),1, 'INCREASING');
                            E.useful{c,l}(t,2) = E.levels(l)-3;
                        end;
                    end
                else
                    if E.streak{c,l}(t)==E.streak{c,l}(t-E.levels(l)+1)
                        E.useful{c,l}(t,1) = 1; % hit expected
                        E.useful{c,l}(t,2) = E.levels(l)-1;
                    else
                        E.useful{c,l}(t,1) = 0;
                        if E.streak{c,l}(t)==E.streak{c,l}(t-E.levels(l)+2)
                            E.useful{c,l}(t,2) = E.levels(l)-2;
                        elseif E.streak{c,l}(t)==E.streak{c,l}(t-E.levels(l)+3)
                            E.useful{c,l}(t,2) = E.levels(l)-3;
                        end;
                    end
                end
            end
            
            
        end
        
        E.condstreak{c,l} = [c E.levels(l)];
        
    end
    
end


%%%% main loop: it is going to be very easy :)

% instructions
%% instructions
instr_folder = 'WM_stims/WM_instructions/';
ilist = ls([instr_folder '*.jpg']);
i = size(ilist,1);
while i <= size(ilist,1)
    [~, iresp] = instr_pic_arrow(w,[instr_folder ilist(i,:)]);
    i = i+iresp;
    if i < 1
        i = 1;
    end
    if i > size(ilist,1)
        KbWait;
    end
    KbReleaseWait;
end

E.nblocks = numel(E.streak);
E.blockpermut = randperm(E.nblocks);

tt = 1;

Screen('TextSize',w.id, E.normal_font);

for b = 1:E.nblocks
    
    bb = E.blockpermut(b);
    
    useful = E.useful{bb};
    streak = E.streak{bb};
    
    %%% block instructions
    spst.image.fullpath = ['WM_stims/c' num2str(E.condstreak{bb}(1)) 'l' num2str(E.condstreak{bb}(2)) '.png'];
    spst.image.height = 0.3;
    spst.image.width = 0.3;
    eval(spst.image.exe);
    spst.corner_image.fullpath = ['WM_stims/c' num2str(E.condstreak{bb}(1)) 'l' num2str(E.condstreak{bb}(2)) 'simple.png'];
    eval(spst.corner_image.exe);
    Screen('Flip', w.id);
    WaitSecs(E.duration_interblock_instructions);
    
    % fix before beginning
    spst.fix.color = [0 0 0];
    eval(spst.fix.exe);
    eval(spst.corner_image.exe);
    Screen('Flip',w.id)
    WaitSecs(1);
    
    
    L.block_onset(b) = GetSecs;
    
    for t = 1:length(streak)
        
        Screen('TextSize',w.id, E.number_font);
       
        %
        spst.text.defcolor = [0 0 0];
        spst.text.str = num2str(streak(t));
        eval(spst.text.exe);
        eval(spst.corner_image.exe);
        Screen('Flip', w.id);
        L.onset_number(tt,1) = GetSecs;
        L.keypressed(tt,1) = 0;
        
        %
        while GetSecs-L.onset_number(tt,1)< E.trialdur
            if L.keypressed(tt,1)==0
                [L.keypressed(tt,1), L.keySecs(tt,1)] = KbCheck;
                L.rt(tt,1) = L.keySecs(tt,1)-L.onset_number(tt,1);
            end;
            if GetSecs-L.onset_number(tt,1)> E.displaydur
                eval(spst.corner_image.exe);
                Screen('Flip', w.id);
                %KbReleaseWait;
            end
        end;
        if L.keypressed(tt,1)==0
            L.rt(tt,1) = NaN;
        end
        
        Screen('TextSize',w.id, E.normal_font);
        
        if useful(t,1)==1 && L.keypressed(tt,1)~=0
            L.acc(tt,1) = 1; % hit
%             spst.text.defcolor = [0 200 0];
%             spst.text.str = ['Got it!'];
%             eval(spst.text.exe);
%             eval(spst.corner_image.exe);
%             Screen('Flip', w.id);
%             WaitSecs(E.warningmsg_duration);
        elseif useful(t,1)==1 && L.keypressed(tt,1)==0
            L.acc(tt,1) = -1; % miss
%             spst.text.defcolor = [0 0 200];
%             spst.text.str = ['Missed it!'];
%             eval(spst.text.exe);
%             eval(spst.corner_image.exe);
%             Screen('Flip', w.id);
%             WaitSecs(E.warningmsg_duration);
        elseif useful(t,1)==0 && L.keypressed(tt,1)~=0
            L.acc(tt,1) = 2; % false alarm
%             spst.text.defcolor = [255 50 0];
%             spst.text.str = ['False alarm!'];
%             eval(spst.text.exe);
%             eval(spst.corner_image.exe);
%             Screen('Flip', w.id);
%             WaitSecs(E.warningmsg_duration);
        else
            L.acc(tt,1) = 0; % correct rejection
        end
        
        L.track_block(tt,1) = bb;
        L.track_cond(tt,:) = E.condstreak{bb};
        
        tt = tt+1;
    end
    
    Screen('TextSize',w.id, E.normal_font);
    
end

save(['logfiles/WM/WM_' S.fullid '.mat'], 'E', 'S', 'L');
try
save([external_folder 'WM_' S.fullid '.mat'], 'S', 'L', 'E');
end
Screen('CloseAll');

toc