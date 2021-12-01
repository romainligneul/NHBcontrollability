%%%
% portA = PsychSerial('Open','COM3','foobar',9600)
% PsychSerial('Write',portA,['Hello world.' 13]);
% PsychSerial('Close',
   specialSettings = [];
    joker = '';
    baudRate = 115200;
    portSettings = sprintf('%s %s BaudRate=%i', joker, specialSettings, baudRate);
    E.mainserialport = IOPort('OpenSerialPort', 'COM1',portSettings);
    
for t = 1:10000
    [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', E.mainserialport, uint8(65), 0)
    WaitSecs(0.7);
    
end
