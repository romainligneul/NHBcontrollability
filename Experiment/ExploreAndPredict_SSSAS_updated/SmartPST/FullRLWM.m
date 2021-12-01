%%  Reinforcement-Learning Working-Memory Task from Collins & Frank. (2012)
%% Modified shorter version for patients (cf. Collins et al 2014, JoN)


%%%% Anne Collins
%%%% Brown University
%%%% May 2013
%%%% anne_collins@brown.edu

%%%% Actual experiment code.



function dataT=FullRLWM(blocks,stSets,stSeqs,Actions,stimuli,rules,subject_id, local_sujet,deb)

language = 2;%1 for dutch
if nargin>8
debug = deb;
else
    debug = 0;
end

rand('twister',sum(100*clock));
nA = 3;
%load datatmp
dataT=[];

% create input file to be saved within subject's output data
Entrees=[];
Entrees.local_sujet = local_sujet;
Entrees.blocks=blocks;
Entrees.stSets=stSets;
Entrees.stSeqs=stSeqs;
Entrees.Actions=Actions;
Entrees.stimuli=stimuli;
Entrees.rules=rules;
dataT{length(blocks)+1}=Entrees;

% presentation time
prestime =1.5;
FBprestime = .75;

% interstimulus interval
ISI= .75;

% actions
buttonz=Actions;  % 1 2 3 the required response button codes (see  Kbname)



textE{1} =  'Block ';
textD{1} = 'Blok ';
textE{2} = 'Take some time to identify the images for this block.';
textD{2} = 'Neem even de tijd om de afbeeldingen van dit blok in u op te nemen.';
textE{3} = '[Press a key to continue.]';
textD{3} = '[Druk op een toets om verder te gaan.]';
textE{4} = 'Correct';
textD{4} = 'Juist';
textE{5} = 'Incorrect';
textD{5} = 'Onjuist';
textE{6} = 'End of block ';
textD{6} = 'Einde van blok ';
textE{7} = 'End of RLWM. \n\n\nThank you for completing the experiment!';
textD{7} = 'Einde van RLWM. \n\n\nDank u voor het voltooien van het experiment!';

if language == 1
    text = textD;
else
    text = textE;
end

red = [255 0 0];
green = [0 255 0];
blue =[0 0 255];% 

screenRect = 1.1*[0,0,1000,800]; % screen for debugging
% --------------- 
% open the screen
% ---------------

corSound = wavread('corrSound.wav');corSound = [corSound';corSound'];
incSound = wavread('incorSound.wav');incSound = [incSound';incSound'];
Snd('Open')
try
    % get screen parameters
    
    Screen('Preference', 'SkipSyncTests',1);
    if debug
    [w,rect] = Screen('OpenWindow',0,0, screenRect);
    else
    [w, rect] = Screen('OpenWindow', 0, 0,[],32,2);
    end
    % create screen center, central square
    center=[rect(3)/2 rect(4)/2];
    crect = CenterRectOnPoint([0 0 200 200],rect(3)/2,rect(4)/2);
    % 400 pixel rectangle for presentation. Adjust at will
    crectP = CenterRectOnPoint([0 0 400 400],rect(3)/2,rect(4)/2);
    
    % create stim sample display boxes
    x=rect(3)/7;
    x=min(x,rect(4)/5);
    boitesPresentation=[1*x 1*x 2*x 2*x;
                        3*x 1*x 4*x 2*x;
                        5*x 1*x 6*x 2*x;
                        1*x 3*x 2*x 4*x;
                        3*x 3*x 4*x 4*x;
                        5*x 3*x 6*x 4*x];
    
    HideCursor;	% Hide the mouse cursor
    %ListenChar(2);
    
    Screen('TextFont', w , 'Times');
    Screen('TextSize', w, 32 );
    

    Tinitial=GetSecs;
    if debug
        torun = [1 length(blocks)];
    else
        torun = [1:length(blocks)];
    end
    
    
    %Run experiment for 13 blocks
    for b=torun
        data=[];
        
        % Get stim set size
        nS=blocks(b);%%%Combien d'images
        % Create a matrix to store the stimuli
        SMat=zeros(300,300,3,nS);
        % get the specific stimuli numbers
        sordre=stimuli{b};%%%Quelles images dans la famille
        % get the specific stimulus type
        Type=stSets(b);%%%%Famille d'images
        % load stimuli and store them in matrix SMat for display
        for i=1:nS
            load(['imagesRLWM/images',num2str(Type),'/image',num2str(sordre(i))])%%%load des stimuli
            SMat(:,:,:,i)=X;
        end
         
        %%%Get stim sequence for block b
        stimseq=stSeqs{b};
        taille=length(stimseq);
        
        %%%Get correct action sequence for block b, using predifined rules
        actionseq=0*stimseq;
        TS=rules{b};
        for i=1:nS
            actionseq(stimseq==i)=TS(i);
        end
        TMin=nS*3*3;
        
        
        % Stim sets presentation in previously built boxes
        Screen('FillRect', w,0)
        Screen('TextColor',w,[255 255 255]);
        textI = [text{1},num2str(b),'\n\n\n',text{2},'\n\n\n',text{3}];        
        DrawFormattedText(w,textI,'center','center');
        Screen('Flip', w);
        
        WaitSecs(.2);
        kdown=0;
        while kdown==0;
            kdown=KbCheck;
        end
        
        Screen('FillRect', w, 0)
        for tt=1:nS
            Screen(w,'PutImage',SMat(:,:,:,tt),boitesPresentation(tt,:))
        end
        
        Screen('Flip', w);
        WaitSecs(.2);
        
        % wait for key press to begin block
        %WaitSecs(2)
        kdown=0;
        while kdown==0;
            kdown=KbCheck;
        end
        Screen('FillRect', w, 0)
        Screen('Flip', w);
        WaitSecs(2)
        Screen('TextSize', w, 75 );

        restcount=0;
        kdownstop=0;
        
              
        % set up criterion
        critere=0;

        t=0;
        DCor=[];
        DCode=[];
        DRT=[];
        
        if debug;tmax = taille; else tmax = taille;end
        
        while t<tmax & critere~=1;
            t=t+1;
            %get trial's stimulus
            sti=stimseq(t);
            % present it
            Screen(w,'FillPoly',0, [0 0;0 rect(4);rect(3) rect(4);rect(3) 0]);%%Ecrean total noir
            Screen(w,'PutImage',SMat(:,:,:,sti),crectP);
            Screen('Flip', w);

            % wait for a key press
            tstart=GetSecs;
            press=0;
            buttonStateResp=[0 0 0];
            RT=-1;
            code=-1;
            while GetSecs<tstart + prestime & press==0
                [kdown secs code]=KbCheck;

                if kdown == 1;
                    press = 1;
                    if press == 1;
                        RT = secs-tstart;
                        keycode = find(code==1);keycode = keycode(1);
                        if intersect(keycode,buttonz);  % if buttons
                            code = find(keycode == buttonz);
                        else
                            code=-1;
                            press = 0; %% this is so other keys don't count as non answers
                        end
                    end
                end
            end
            if press>0
                WaitSecs(.1);%prestime-RT);
            end
            cor=-1;
            rew=-1;
            %deliver feedback if legal keypress ;occured
            if code==1 | code==2 | code==3;
                if code==actionseq(t)
                    cor=1;
                    rew=1;
                    word=text{4};%'Correct';
                    couleur = blue;
                else
                    cor=0;
                    rew=0;
                    word=text{5};%'Incorrect';
                    couleur = red;
                end
                %WaitSecs(.2);
                Screen(w,'FillPoly',0, [0 0;0 rect(4);rect(3) rect(4);rect(3) 0]);%%Full black screen
                
                Screen('TextSize', w, 32 );
                Screen('TextColor',w,couleur);
                DrawFormattedText(w,word,'center','center');
            %Screen(w,'DrawText',word,center(1)-150,center(2)-50,255);
                Screen('Flip', w);
                tic;
                 if rew == 1
                    Snd('Play',corSound);
                else
                    Snd('Play',incSound);
                 end
                 latence=toc;
                WaitSecs(max(0,FBprestime-latence));
                Snd('Close');
            else
                %no/illegal keypress: deliver no reward, encode as -1
                Screen(w,'FillPoly',0, [0 0;0 rect(4);rect(3) rect(4);rect(3) 0]);%%Full black screen
                couleur = red;
                word='Too slow. Answer faster!';
                Screen('TextSize', w, 32 );
                Screen('TextColor',w,couleur);
                DrawFormattedText(w,word,'center','center');
                Screen('Flip', w);
                tic;
                noteInterne([250],[.2]);
                latence=toc;
                
                WaitSecs(max(0,FBprestime-latence));
                
                %WaitSecs(FBprestime);
                code=-1;
                cor=-1;
                RT=-1;
            end
            
            %cumulate reward for learning criterion
            if cor==1
                RCumule(sti,1+rem(t-1,4))=1;
            else
                RCumule(sti,1+rem(t-1,4))=0;
            end
            
            X=mean(RCumule');
            if min(X)<0.7
                critere=0;
            elseif t<TMin
                critere=0;
            else
                critere=1;%%%3/4 of last 4 trials of each stim correct
            end
            Screen('TextColor',w,[255 255 255]);
            Screen(w,'FillPoly',0, [0 0;0 rect(4);rect(3) rect(4);rect(3) 0]);%%Ecrean total noir
            Screen('TextSize', w, 32 );
            DrawFormattedText(w,'+','center','center');
            %Screen(w,'DrawText','+',rect(3)/2-10,rect(4)/2-10,255);
            Screen('Flip', w);
   
            WaitSecs(ISI);

            DCor(t)=cor;
            DRT(t)=RT;
            DCode(t)=code;
            %[sti code rew]
        end % ending sessions

        % build output structure with all info in
        gain=floor(100*(taille-t)/(taille-TMin));
        data.gain=gain;
        data.critere=critere;
        data.temps=t;
        data.Cor=DCor;
        data.RT=DRT;
        data.Code=DCode;
        data.seq=stimseq;
        data.actionseq=actionseq;
        dataT{b}=data;
        
        % Give block feedback on time saved
        Screen('TextSize', w, 32 );
        Screen('FillRect', w,0)
        textI = [text{6}, num2str(b),'\n\n\n\n\n\n\n',...
            text{3}];
        DrawFormattedText(w,textI,'center','center');
        %Screen(w,'DrawText',['End of block ',num2str(b)],(rect(3)/2)-150,rect(4)/2-100,255);
        %Screen(w,'DrawText',['Proportion of time saved: ',num2str(gain),' / 100'],(rect(3)/2)-400,rect(4)/2,255);
        %Screen(w,'DrawText','Press a key to continue',(rect(3)/2)-400,rect(4)/2+150,255);
        Screen('Flip', w);kdown=0;
        while kdown==0;
            kdown=KbCheck;
        end
        Screen('FillRect', w, 0)
        Screen('Flip', w);
        WaitSecs(2);
        
        save(['DataRLWM/donneesLSSt_ID',num2str(subject_id)],'dataT')
        
    end
    TFinal=GetSecs;
    
    % Give global feedback
    Duree=TFinal-Tinitial;
    minutes=floor(Duree/60);
    secondes=floor(Duree)-60*minutes;
    Screen('FillRect', w,0)
    textI = text{7};
    DrawFormattedText(w,textI,'center','center');
%         Screen(w,'DrawText','End of main part.',(rect(3)/2)-150,rect(4)/2-100,255);
%     Screen(w,'DrawText',['It lasted ',num2str(minutes),' min, ',num2str(secondes),' sec.'],(rect(3)/2)-150,rect(4)/2,255);
     
    Screen('Flip', w);
    WaitSecs(2); 
        
        
    ShowCursor;
    %ListenChar(0);
    Screen('CloseAll');
    Snd('Close')
catch
    ShowCursor;
    %ListenChar(0);
    Screen('CloseAll');
    Snd('Close')
    rethrow(lasterror);
end




end



% sound making function
function noteInterne(freq, duree, echant)
%%% note(freq, duree) joue une sŽrie de notes de frŽquences contenues dans
%%% le tableau freq et de durŽe dans le tableau duree
%%% (en s) (on peut rajouter en 3eme argument la freq d'Žchantillonage, par
%%% dŽfaut 8192Hz

if nargin==2, echant=8192; end
out=[];
for n=1:length(duree);

sery=zeros(1,sum(floor(echant*duree(n))));

ls=0;
sery(ls+1:ls+floor(echant*duree(n)))=sin(2*pi*freq(n)*[1/echant:1/echant:duree(n)]);
ls=ls+floor(echant*duree(n));

out=[out sery];
end

%player=audioplayer(sery, echant);
sound(out,echant);
end