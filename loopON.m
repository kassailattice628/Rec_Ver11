function loopON(hObject, ~, s, dio)
%global figUIobj
%reload_params;

switch get(hObject,'value')
    case 1
        reload_params;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        
        s.IsContinuous = true;
        startBackground(s); %session start
        
        outputSingleScan(dio.TrigAI,1);%reset trigger signals at high
        %outputSingleScan(dio.TrigAI,0);%reset trigger signals at Low
        
        %stop(s)
    case 0
        set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
        disp('capture stop')
        if s.IsRunning
            stop(s)
        end
        
end
end