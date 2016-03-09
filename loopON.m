function loopON(hObject, ~, s, dio, hGui)
% Loop start and stop

global recobj
global RecData


reload_params;

if get(hObject, 'value')
    RecData=[];
    % set 1st counter
    recobj.cycleNum = recobj.cycleNum + 1;
    % during loop
    while get(hObject,'value') == 1
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['#: ',num2str(recobj.cycleNum)])
        % start loop
        MainLoop(s, dio, hGui)
        
        % loop interval
        recobj.cycleNum = recobj.cycleNum + 1;
        pause(recobj.interval+recobj.rect/1000);
    end
else
    set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
    
    % stop loop & data acquiring
    disp('capture stop')
    if s.IsRunning
        stop(s)
    end
    % reset all triggers
    %RestTriggers
    
    % Reset Cycle Counter %
    recobj.cycleNum = 0- recobj.prestim;
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    clear recobj.STARTloop;
end
end

%% Main Contentes in the Loop%%
function MainLoop(s, dio, hGui)

global recobj
global sobj
% start DAQ
if s.IsRunning == false
    s.startBackground; %session start, listener ON, wait Trigger
end

try %error check
    switch get(hGui.stim, 'value')
        case 0 % Vis.Stim off
            % start timer and start FV
            if recobj.cycleNum == -recobj.prestim +1
                recobj.STARTloop= tic;
                % Start AI & FV
                outputSingleScan(dio.TrigAIFV,[1,1]);
            else
                % Trig AI only
                outputSingleScan(dio.TrigAIFV,[1,0]);
                %{
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
                %}
            end
            %report # of cycles
            outputSingleScan(dio.TrigAIFV,[0,0]);%AI and sRot Trigger ON
    end
catch ME1
    %PTB error
    Screen('CloseAll');
    rethrow(ME1);
end
end
