keydown=0 
IOPort('Purge', E.mainserialport);

while keydown==0
     

    [keydown, secs, keyCode] = Serial2Kb( E.mainserialport, E.left_right_keycode)

     
end
find(keyCode)
WaitSecs(0.5)

   while IOPort('BytesAvailable', porthandle) > 0
       % Same as above, but now a non-blocking read (flag == 0):
       IOPort('Read', porthandle, 0, 1);
   end