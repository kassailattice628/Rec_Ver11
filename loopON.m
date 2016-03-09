function loopON(hObject, ~, s, dio, hGui)

global sobj
global recobj

reload_params;

if get(hObject,'value') == 0 % loop OFF
    set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
    
    if sobj.ScrNum ~= 0
        %ResetAllTrig;
    end
    sobj.Dir8 = randperm(8);
    sobj.Dir16 = randperm(16);
    
    
    disp('capture stop')
    if s.IsRunning
        stop(s)
    end
else % loop ON
    while get(hObject,'value') == 1
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        
        %start loop
        MainLoop(s, dio, hGui)
    end
    
    %%% Reset Cycle Num %%%
    recobj.cycleNum = 0- recobj.prestim;
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    clear recobj.STARTloop;
end
end

function MainLoop(s,dio, hGui)
global recobj
global sobj

recobj.cycleNum = recobj.cycleNum + 1;
%start DAQ
if s.IsRunning == false
    s.startBackground; %session start, wait Trigger
end

%Timer Start
if recobj.cycleNum == -recobj.prestim +1
    recobj.STARTloop= tic;
end

try %error check
    
    
    
    switch get(hGui.stim, 'value')
        case 0 % Vis.Stim off
            %Start AI Trig
            outputSingleScan(dio.TrigAI,1);%AI and sRot Trigger ON
            
            %saving params
            recobj.tRec = toc(recobj.STARTloop);
            recobj.TTL3 = 0;
            sobj.tPTBon = 0;
            sobj.tPTBon2 = 0;
            sobj.tPTBoff = 0;
            sobj.tPTBoff2 = 0;
            sobj.position = 0;
            sobj.position_cord = zeros(1,4);
            sobj.position_cord2 = zeros(1,4);
            sobj.stim2_center = zeros(1,2);
            sobj.dist_pix = 0;
        case 1 %
            %VisualStimulus;
            outputSingleScan(dio.TrigAI,1);%AI and sRot Trigger ON
            
            %report # of cycles
            disp(['#: ',num2str(recobj.cycleNum)])
    end
    
    %pause(recobj.interval);
    
    while s.IsRunning
        pause(0.1);
    end
catch ME1
    %PTB error
    Screen('CloseAll');
    rethrow(ME1);
end
end
