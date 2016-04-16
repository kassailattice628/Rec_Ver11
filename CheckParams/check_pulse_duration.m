function check_pulse_duration(~, ~)
global figUIobj

rectime = re_write(figUIobj.rect)/1000; %ms -> s

%%%%%% check duration %%%%%
pulseDelay = re_write(figUIobj.pulseDelay); %sec
pulseDuration = re_write(figUIobj.pulseDuration); %sec

if (pulseDelay + pulseDuration) > rectime
    errordlg('Pulse Duration is longer than Recording Time!!');
    set(figUIobj.pulseDelay,'string', 0);
    set(figUIobj.pulseDuration,'string', 0);
end


end
