function w = open_PSTscreen(screen_id, bgcolor, skiptest,hide_cursor, unify)
% usually screen_id = 0 is for single display computer. otherwise 1,2..
% indexes the different display
Screen('Preference', 'SkipSyncTests', skiptest);
[w.id w.rectpix] =Screen('OpenWindow',screen_id, bgcolor);
w.centerpix = [w.rectpix(3)/2 w.rectpix(4)/2];
w.conv = [w.rectpix(3) w.rectpix(4) w.rectpix(3) w.rectpix(4)];
w.refreshrate = Screen('NominalFrameRate',w.id);
Screen('BlendFunction', w.id, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');   % set la transparence (pour avoir des jolis points antialiases)
Screen('Flip',w.id);
if ~isempty(hide_cursor)
    HideCursor;
end
if ~isempty(unify)
    KbName('UnifyKeyNames');
end
end

