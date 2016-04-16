function check_stim_duration(~, ~)
global figUIobj
global sobj
global recobj

rectime = re_write(figUIobj.rect)/1000; %ms -> s

flipNum1 = re_write(figUIobj.flipNum);
dur1 = flipNum1*sobj.m_int;

delayNum1 = re_write(figUIobj.delayPTBflip);
delay1 = delayNum1*sobj.m_int;

flipNum2 = re_write(figUIobj.flipNum2);
dur2 = flipNum2*sobj.m_int;

delayNum2 = re_write(figUIobj.delayPTBflip2);
delay2 = delayNum2*sobj.m_int;

%%%%%% check duration %%%%%
if strcmp(sobj.pattern, 'Looming')
    % Stimulus duration is automatically defined in Looming mode
else % Error Reset
    recobj.rect = re_write(figUIobj.rect);
    if strcmp(sobj.pattern, '2P_conc')
        if rectime < dur1 + delay1 || rectime < dur2 + delay2
            errordlg('Stim. Duration is longer than Recording Time!!');
            reset_stim_duration;
        end
    else
        if rectime < dur1 + delay1
            errordlg('Stim. Duration is longer than Recording Time!!');
            reset_stim_duration;
        end
    end
end
% update GUI
set(figUIobj.stimDur, 'string',['flips=',num2str(floor(dur1*1000)), 'ms']);
set(figUIobj.delayPTB, 'string',['flips=',num2str(floor(delay1*1000)), 'ms']);
set(figUIobj.stimDur2, 'string',['flips=',num2str(floor(dur2*1000)), 'ms']);
set(figUIobj.delayPTB2, 'string',['flips=',num2str(floor(delay2*1000)), 'ms']);

%%
    function reset_stim_duration
        set(figUIobj.flipNum, 'string', 75);
        set(figUIobj.delayPTBflip, 'string', 20);
        
        set(figUIobj.flipNum2, 'string', 75);
        set(figUIobj.delayPTBflip2, 'string', 20);
        
        set(figUIobj.rect, 'string', 2000);
        
        dur1 = 75*sobj.m_int;
        delay1 = 20*sobj.m_int;
        dur2 = 75*sobj.m_int;
        delay2 = 20*sobj.m_int;
    end


end