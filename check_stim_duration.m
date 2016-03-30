function check_stim_duration(~,~)
global sobj
global figUIobj

rectime = re_write(figUIobj.rect)/1000; %ms -> s

flipNum1 = re_write(figUIobj.flipNum);
dur1 = flipNum1*sobj.m_int;

delayNum1 = re_write(figUIobj.delayPTBflip);
delay1 = delayNum1*sobj.m_int;

flipNum2 = re_write(figUIobj.flipNum2);
dur2 = flipNum2*sobj.m_int;

delayNum2 = re_write(figUIobj.delayPTBflip2);
delay2 = delayNum2*sobj.m_int;

%% check duration
if rectime < dur1+delay1 || rectime < dur2+delay2
    errordlg('Stim. Duration is longer than Recording Time!!');
    
    set(figUIobj.flipNum, 'string',75);
    set(figUIobj.delayPTBflip, 'string',20);
    
    set(figUIobj.flipNum2, 'string', 75);
    set(figUIobj.delayPTBflip2, 'string',20);
    
    set(figUIobj.rect, 'string', 2000);
    
    dur1 = 75*sobj.m_int;
    delay1 = 20*sobj.m_int;
    dur2 = 75*sobj.m_int;
    delay2 = 20*sobj.m_int;
end

%% update GUI
set(figUIobj.stimDur,'string',['flips = ',num2str(floor(dur1*1000)),' ms']);
set(figUIobj.delayPTB,'string',['flips = ',num2str(floor(delay1*1000)),' ms']);
set(figUIobj.stimDur2,'string',['flips = ',num2str(floor(dur2*1000)),' ms']);
set(figUIobj.delayPTB2, 'string',['flips = ',num2str(floor(delay2*1000)),' ms']);

end

function y = re_write(h)
y = str2double(get(h,'string'));
end