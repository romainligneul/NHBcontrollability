function [ time ] = simplefade(w, x, y, height, width, alphavec, framedur, varargin)

time(1) = GetSecs;

advance = 0;
if ~isempty(varargin{1})
    color = varargin{1};
else
    color = 255;
end

while GetSecs-time(1) < dur
    
      alpha = advance*alphavec(2) + (1-avance)*alphavec(1);
      Screen('FillRect', w.id, color*alpha, [x-width/2 y-height/2 x+width/2 y+height/2]);
      Screen('Flip', w.id, [],1];

end
