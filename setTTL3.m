function setTTL3(~, ~)
global figUIobj
global recobj

TTL3freq = str2double(get(figUIobj.freqTTL3,'string'));

switch get(figUIobj.TTL3_select,'value')
    case 0 % FixDuration
        TTL3pulsenum = str2double(get(figUIobj.pulsenumTTL3,'string'));
        TTL3duration = round(TTL3pulsenum/TTL3freq*100)*10;
        set(figUIobj.durationTTL3,'string', TTL3duration);
        
    case 1 % Fix PulseNum
        TTL3duration = str2double(get(figUIobj.durationTTL3,'string'));
        TTL3pulsenum = TTL3freq * TTL3duration/1000;
        set(figUIobj.pulsenumTTL3,'string', TTL3pulsenum);        
end

% pulse width
TTL3dutycycle=str2double(get(figUIobj.dutycycleTTL3,'string'));
pulse_width = TTL3dutycycle / TTL3freq * 1000; %ms
set(figUIobj.widthTTL3, 'string', pulse_width);

% check duration
TTL3delay = str2double(get(figUIobj.delayTTL3,'string'));
if recobj.rect < TTL3duration + TTL3delay
    errordlg('TTL is longer than recording time!!');
    set(figUIobj.delayTTL3, 'string', 100);
    set(figUIobj.durationTTL3, 'string', 100);
    set(figUIobj.freqTTL3, 'string', 100);
    set(figUIobj.pulsenumTTL3, 'string',10);
    set(figUIobj.dutycycleTTL3, 'string',10);
    set(figUIobj.widthTTL3, 'string', 5);
end

end
