function loopON(hObject, ~, hGui, Testmode)
% Loop start and stop

global recobj
global sobj
global s
global dio
global DataSave %save
global ParamsSave %save
global lh

%%
if get(hObject, 'value')==1 % loop ON
    reload_params([], [], Testmode);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Testmode == 1
        %open screen
        [sobj.wPtr, ~] = Screen('OpenWindow', sobj.ScrNum, sobj.bgcol);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject,'value') == 1
        if Testmode == 1 && recobj.cycleNum == 10;
            set(hObject, 'value', 0);
            Screen('Close', sobj.wPtr);
            break;
        end
        % set 1st counter
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['Loop#: ',num2str(recobj.cycleNum)])
        % start loop (Trigger + Visual Stimulus)
        MainLoop(dio, hGui, Testmode)
        
        %%%%%%%%%%%%%% loop interval %%%%%%%%%%%%%%%%
        pause(recobj.rect/1000 + recobj.interval);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
else %loop OFF
    set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
    % stop loop & data acquiring
    if Testmode==0 && s.IsRunning
        stop(s)
        delete(lh)
        disp('delete lh')
    end
    
    %%%%%% Save Data %%%%%%%%
    if get(hGui.save, 'value')
        save([recobj.dirname,recobj.fname], 'DataSave', 'ParamsSave', 'recobj', 'sobj');
        recobj.savecount = recobj.savecount + 1;
    end
    %reset all triggers
    ResetTTLall(Testmode, dio);
    
    % Reset Cycle Counter %
    recobj.cycleNum = 0- recobj.prestim;
    
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    recobj = rmfield(recobj,'STARTloop');
end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Contentes in the Loop%%
function MainLoop(dio, hGui, Testmode)
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
            Trigger(Testmode, dio)
            disp('Recording Start')
            
            %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%
        case 1 %
            VisStim(Testmode, dio);
    end
catch ME1
    %PTB error
    Screen('CloseAll');
    rethrow(ME1);
end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Trigger(Testmode, dio)
global recobj
global sobj

if Testmode == 0 %Test mode off
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % timer start, digital out
    if recobj.cycleNum == -recobj.prestim +1
        %start timer & Trigger AI & FV
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_1,sobj.OnsetTime_1, sobj.FlipTimeStamp_1] = Screen(sobj.wPtr, 'Flip');
        recobj.STARTloop = tic;
        outputSingleScan(dio.TrigAIFV, [1,1]);
        disp('Trig')
    else
        recobj.tRec = toc(recobj.STARTloop);
        outputSingleScan(dio.TrigAIFV, [1,0]);
        disp('Trig')
    end
    outputSingleScan(dio.TrigAIFV,[0,0]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %in the Test mode, digital out is not used
elseif Testmode == 1 %Test mode on
    if recobj.cycleNum == -recobj.prestim +1
        %start timer & Trigger AI & FV
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_1,sobj.OnsetTime_1, sobj.FlipTimeStamp_1] = Screen(sobj.wPtr, 'Flip');
        recobj.STARTloop = tic;
        disp('Trig_test')
    else
        recobj.tRec = toc(recobj.STARTloop);
        disp('Trig_test')
    end
end
end
%%
function ResetTTLall(Testmode, dio)

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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VisStim(Testmode, dio)
global figUIobj
global recobj
global sobj

% Set stim position
set_stim_position;
if recobj.cycleNum == -recobj.prestim +1
    ch_position;
end

% Set Luminance
set_luminance;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Start Recording, with/without Visual Stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if recobj.cycleNum > 0 %Stimulus ON
    if i_pos == 1 %reset, random position
        ch_position;
    end
    sobj.position = sobj.poslist(i_pos);
    
    disp(sobj.pattern)
    
    %stimON
    switch sobj.pattern
        case 'Uni'
            Uni_stim(i_pos, sobj.stimcol, Testmode, dio);
        case 'BW'
        case {'Sin', 'Rect', 'Gabor'}
        case {'Size_rand'}
        case 'Zoom'
        case '2stim'
        case 'Image'
    end
else %prestimulus
    disp('prestim')
    Trigger(Testmode, dio)
    %Uni_stim_BG(i, sobj, bgcol);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nestrd functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function set_stim_position
        if recobj.cycleNum <= 0 %prestimulus
            i_pos = 1;
            sobj.position = 0;
        else %stim start
            switch sobj.mode;%{'Random'},{'Fix_Rep'},{'Ordered'}
                case {'Random', 'Ordered'}
                    i_pos = rem(recobj.cycleNum, sobj.divnum^2);
                    if i_pos == 0
                        i_pos = sobj.divnum^2;
                    end
                case {'Fix_Rep'}
                    i_pos = 1;
            end
        end
    end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function set_luminance
        if get(figUIobj.lumi, 'value') == 2 %Random Lumi
            %Random_luminace;
            %sobj.stimlumi = sobj.stimlumi_rand;
        end
    end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ch_position
        %
        sizeX = sobj.ScreenSize(1)/sobj.divnum;
        sizeY = sobj.ScreenSize(2)/sobj.divnum;
        
        %center of the stimulus position in the n*n dividion of the LCD monitor.
        sobj.pos = floor([sizeX/2:sizeX:(sobj.ScreenSize(1)-sizeX/2);sizeY/2:sizeY:(sobj.ScreenSize(2)-sizeY/2)]);
        stimset=1:sobj.divnum^2;
        stimset_mat = reshape(stimset,sobj.divnum,sobj.divnum);
        stimset_x = zeros(1,sobj.divnum^2);
        stimset_y = stimset_x;
        
        switch sobj.mode
            case 'Random' %random position
                %randamize
                stimset_rand = randperm(sobj.divnum^2);
                sobj.poslist = stimset_rand;
                
                for m = 1:length(stimset_rand)
                    [stimset_x(m),stimset_y(m)] = find(stimset_mat== stimset_rand(m));
                end
                sobj.X = stimset_x;
                sobj.Y = stimset_y;
                
            case 'Fix_Rep' %fixed position
                %%%% position error %%%%
                if sobj.fixpos > sobj.divnum^2
                    errordlg(['Fixed Pos. must be lower than the ' num2str(sobj.divnum) '^2 (= ' num2str(sobj.divnum^2) '). !!']);
                    sobj.fixpos = 1;
                    set(figUIobj.fixpos,'string',num2str(sobj.fixpos));
                    %
                else
                    [sobj.X, sobj.Y] = find(stimset_mat == sobj.fixpos);
                end
                sobj.poslist = sobj.fixpos;
                
            case 'Ordered' % oredered
                set(figUIobj.fixpos, 'BackGroundColor','w');
                sobj.poslist = stimset;
                for m = 1:length(stimset)
                    [stimset_x(m),stimset_y(m)] = find(stimset_mat== stimset(m));
                end
                sobj.X = stimset_x;
                sobj.Y = stimset_y;
        end
    end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
    function Uni_stim_BG(i_pos, col, Testmode, dio)
        sobj.dirNum = 0;
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        %stim_OFF
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = Screen(sobj.wPtr, 'Flip', sobj.vbl_2+sobj.duration); %%% sobj.duration ŽžŠÔŒo‰ßŒã monitor stim off
        outputSingleScan(sTrig,[0,0,0]);% DIO resrt
        sobj.sFlipTimeStamp_3=toc(recobj.STARTloop);
        
    end
%}

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Uni_stim(i_pos, col, Testmode, dio)
        sobj.dirNum = 0;
        %[left, top, right, bottom]€”õ
        x1 = sobj.pos(1,sobj.Y(i_pos))-sobj.stimsz(1)/2;
        y1 = sobj.pos(2,sobj.X(i_pos))-sobj.stimsz(2)/2;
        x2 = sobj.pos(1,sobj.Y(i_pos))+sobj.stimsz(1)/2;
        y2 = sobj.pos(2,sobj.X(i_pos))+sobj.stimsz(2)/2;
        sobj.position_cord = [x1,y1,x2,y2];
        
        Trigger(Testmode, dio)
        Screen(sobj.shape, sobj.wPtr, col, sobj.position_cord);
        %PhotoSensor (left, up)     Timing Checker
        if recobj.cycleNum > 0
            Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        end
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = Screen(sobj.wPtr, 'Flip', sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
        stim_monitor;
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        
        %stim_OFF
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = Screen(sobj.wPtr, 'Flip', sobj.vbl_2+sobj.duration); %%% sobj.duration ŽžŠÔŒo‰ßŒã monitor stim off
        sobj.sFlipTimeStamp_3=toc(recobj.STARTloop);
        stim_monitor_reset;
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end if VisStim
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stim_monitor
global figUIobj
global sobj
global recobj

if recobj.cycleNum <= 0 % prestim
    set(figUIobj.StimMonitor3,'string','', 'BackGroundColor','black');
    set(figUIobj.StimMonitor2,'string','Pre Stim','ForegroundColor','white','BackGroundColor','black');
    set(figUIobj.StimMonitor1,'string','', 'BackGroundColor','black');
else % during stimulation
    switch sobj.pattern
        case 'Uni'
            bgcol = 'm';
            stim_str3 = '';
        case 'BW'
            bgcol = 'y';
            stim_str3 = [num2str(sobj.zoom_dist), 'deg, ', num2str(sobj.zoom_ang), 'deg'];
        case 'Sin'
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
        case 'Rect'
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
        case 'Gabor'
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
        case 'Sz_r'
            bgcol = 'm';
            size = Pix2Deg(sobj.stimsz(1), sobj.MonitorDist);
            size = round(size*10)/10; % for disp
            stim_str3 = ['Sz: ', num2str(size),' deg'];
        case 'Zoom'
            bgcol = 'm';
            stim_str3 = [num2str(sobj.zoom_dist), 'deg, ', num2str(sobj.zoom_ang), 'deg'];
        case '2stim'
            bgcol = 'g';
            stim_str3 = [num2str(sobj.zoom_dist), 'deg, ', num2str(sobj.zoom_ang), 'deg'];
        case 'Images'
            bgcol = 'y';
            stim_str3 = ['Image #: ', num2str(sobj.img_i)];
    end
    
    set(figUIobj.StimMonitor3,'string',sobj.pattern, 'BackGroundColor',bgcol);
    set(figUIobj.StimMonitor2,'string',['POS: ',num2str(sobj.position),'/',num2str(sobj.divnum^2)],'ForegroundColor','black','BackGroundColor',bgcol);
    set(figUIobj.StimMonitor1,'string',stim_str3, 'BackGroundColor',bgcol);
end
drawnow;
end
%%
function stim_monitor_reset
global figUIobj

set(figUIobj.StimMonitor1, 'BackGroundColor', 'w');
set(figUIobj.StimMonitor2, 'BackGroundColor', 'w');
set(figUIobj.StimMonitor3, 'BackGroundColor', 'w');
drawnow;
end
%%








