function loopON(hObject, ~, hGui)
% Loop start and stop

global recobj
global sobj
global s
global dio
global DataSave %save
global ParamsSave %save
global lh

if get(hObject, 'value')==1 % loop ON
    reload_params;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject,'value') == 1
        % set 1st counter
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['#: ',num2str(recobj.cycleNum)])
        % start loop (Trigger + Visual Stimulus)
        MainLoop(dio, hGui, sobj)
        % loop interval
        pause(recobj.interval+recobj.rect/1000);
    end
else %loop OFF
    set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
    if get(hGui.save, 'value')
        save([recobj.dirname,recobj.fname], 'DataSave', 'ParamsSave', 'recobj', 'sobj'); 
        recobj.savecount = recobj.savecount + 1;
    end
    % stop loop & data acquiring
    if s.IsRunning
        stop(s)
        delete(lh)
        disp('delete lh')
    end
    % reset all triggers
    %RestTriggers
    outputSingleScan(dio.TrigAIFV,[0,0]);%reset trigger signals at Low
    % Reset Cycle Counter %
    recobj.cycleNum = 0- recobj.prestim;
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    clear recobj.STARTloop;
end
end

%% Main Contentes in the Loop%%
function MainLoop(dio, hGui, sobj)
global recobj
global s

% start DAQ
if s.IsRunning == false
    s.startBackground; %session start, listener ON, wait Trigger
end
try %error check
    switch get(hGui.stim, 'value')
        case 0 % Vis.Stim off
            % start timer and start FV
            if recobj.cycleNum == -recobj.prestim +1
                %start timer & Trigger AI & FV
                FistLoop(dio.TrigAIFV,sobj);
                disp('Recording Start')
                
            else
                % Trig AI only
                setDO(dio.TrigAIFV,[1,0],sobj);
                outputSingleScan(dio.TrigAIFV,[0,0]);%
                
                if get(hGui.TTL3,'value')%TTL3 is ON
                    %wait TTL3 delay
                    while toc(recobj.STARTloop) - recobj.RecStartTimeToc <= recobj.delayTTL3/1000;%wait TTL2 delay (include delay TTL2 == 0)
                    end
                    recobj.tTTL3 = setDO(dio.TTL3,1) - recobj.StartTimeToc;
                end
                
            end
            %report # of cycles
           outputSingleScan(dio.TrigAIFV,[0,0]);%
    end
catch ME1
    %PTB error
    Screen('CloseAll');
    rethrow(ME1);
end
end

%%
function FistLoop(session,sobj)
global recobj

% Start AI & FV
if sobj.ScrNum ~= 0
    % set timer @ 1st loop
    recobj.STARTloop = tic;
    setDO(session,[1,1], sobj);
end
end
%%
function setDO(session, condition, sobj)
global recobj

if sobj.ScrNum ~= 0
    recobj.tRec = toc(recobj.STARTloop);
    outputSingleScan(session, condition)
end
end
%%




