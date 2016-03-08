function loopON(hObject, ~, s, dio)
global figUIobj
%reload_params;

switch get(hObject,'value')
    case 1
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        disp('on')
        
        s.IsContinuous = true;
        startBackground(s); %session start
        
        outputSingleScan(dio.TrigAI,1);%reset trigger signals at Low
        disp('trigger rec')
        
        %stop(s)
        
        %outputSingleScan(dio.TrigAI,0);%reset trigger signals at Low
    case 0
        set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
        disp('capture stop')
        if s.IsRunning
            stop(s)
        end
        set(figUIobj.p2, 'XData', NaN, 'YData', NaN);
        
end
end