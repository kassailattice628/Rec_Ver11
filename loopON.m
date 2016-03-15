function loopON(hObject, ~, hGui, Testmode)
% Loop start and stop

global recobj
global sobj
global s
global dio
global DataSave %save
global ParamsSave %save
global lh

if get(hObject, 'value')==1 % loop ON
    reload_params([], [], Testmode);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject,'value') == 1
        % set 1st counter
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['#: ',num2str(recobj.cycleNum)])
        % start loop (Trigger + Visual Stimulus)
        MainLoop(dio, hGui, sobj, Testmode)
        
        
        %%%%%%%%%%%%%% loop interval %%%%%%%%%%%%%%%%
        pause(recobj.interval+recobj.rect/1000);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    %reset all triggers
    ResetTrigger(Testmode);
    
    % Reset Cycle Counter %
    recobj.cycleNum = 0- recobj.prestim;
    
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    recobj = rmfield(recobj,'STARTloop');
end
end

%% Main Contentes in the Loop%%
function MainLoop(dio, hGui, sobj, Testmode)
global recobj
global s

% start DAQ
if Testmode == 0
    if s.IsRunning
    else
        s.startBackground; %session start, listener ON, wait Trigger
    end
end

try %error check
    switch get(hGui.stim, 'value')
        case 0 % Vis.Stim off
            % start timer and start FV
            if recobj.cycleNum == -recobj.prestim +1
                Trigger(Testmode)
                disp('Recording Start')
            else
                % Trig AI only %%% start timer
                outputSingleScan(dio.TrigAIFV,[1,0]);% start timer(recobj.STARTLoop)
            end
            %report # of cycles
            outputSingleScan(dio.TrigAIFV,[0,0]);%
            
            %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%
        case 1 %
            VisStim(get(hGui.mode, 'value'));
    end
catch ME1
    %PTB error
    Screen('CloseAll');
    rethrow(ME1);
end
end

%%
function Trigger(Testmode)
global recobj
global dio

if Testmode == 0 %Test mode off
    if recobj.cycleNum == -recobj.prestim +1
        %start timer & Trigger AI & FV
        recobj.STARTloop = tic;
        outputSingleScan(dio.TrigAIFV, [1,1]);
        disp('Trig')
    else
        recobj.tRec = toc(recobj.STARTloop);
        outputSingleScan(dio.TrigAIFV, [1,0]);
        disp('Trig')
    end
end
end
%%
function ResetTrigger(Testmode)
global dio

if Testmode == 0; %Test mode off
    outputSingleScan(dio.TrigAIFV,[0,0]);
    outputSingleScan(dio.VSon,0);
    outputSingleScan(dio.TTL3,0);
end
end
%%
%{
function tRec = TimeTrigger(Testmode, session, condition)
global recobj

if Testmode == 0
    tRec = toc(recobj.STARTloop);
    outputSingleScan(session, condition);
end
end
%}


