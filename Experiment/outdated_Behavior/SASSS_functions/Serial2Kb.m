function [keydown, secs, keyCode] = Serial2Kb( porthandle, targets )
%SERIAL2KB This function emulates the behavior of KbCheck using a serial
%port.
%start = GetSecs;
%while isempty(data) && sum(ismember(data,targets))==0
if IOPort('BytesAvailable', porthandle) > 0
    [data, secs, errmsg] = IOPort('Read', porthandle);
  %  if ~isempty(data);
        keydown = 1;
        %    ismember(find(data),targets)
        keyCode=zeros(1,265);
        keyCode(data(1))=1;
        % IOPort('Flush', porthandle);
%         bits = IOPort('BytesAvailable', porthandle) > 0;
%         while bits
%             IOPort('Read', porthandle,0,1);
%         end
%         
else
    keydown=0; secs = []; keyCode = [];
end
    
    


%   Detailed explanation goes here


end

