function func_loop(hObject, ~, hGui, Testmode)
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
    if Testmode == 1 && get(hGui.stim,'value')
        %open screen
        [sobj.wPtr, ~] = Screen('OpenWindow', sobj.ScrNum, sobj.bgcol);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject,'value') == 1
        
        if Testmode == 1 && recobj.cycleNum == 5;
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
        save(recobj.savefilename, 'DataSave', 'ParamsSave', 'recobj', 'sobj');
        disp(['data saved as ::' recobj.savefilename])
        recobj.savecount = recobj.savecount + 1;
        set(hGui.save, 'value', 0, 'string', 'Unsave', 'BackGroundColor',[0.9400 0.9400 0.9400])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    %reset all triggers
    ResetTTLall(Testmode, dio);
    % Reset Cycle Counter %
    recobj.cycleNum = 0- recobj.prestim;
    disp(['Loop-Out:', num2str(recobj.cycleNum)]);
    recobj = rmfield(recobj,'STARTloop');
end
end

%% subfunctions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MainLoop(dio, hGui, Testmode)
% Main structure%

global s

% ready to start DAQ
if Testmode == 0
    if s.IsRunning
    else
        s.startBackground; %session start, listener ON, *** Waiting Analog Trigger (AI3)
    end
end

try %error check
    switch get(hGui.stim, 'value')
%%%%%%%%%%%%%%%%%%%% Visual Stimulus OFF %%%%%%%%%%%%%%%%%%%%
        case 0
            % start timer and start FV
            Trigger(Testmode, dio)
%%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%%
        case 1
            % start timer, start FV and start Stim
            VisStim(Testmode, dio);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
global figUIobj

if Testmode == 0 %Test mode off
    %start timer & Trigger AI & FV
    Screen('FillRect', sobj.wPtr, sobj.bgcol); %presenting background
    [sobj.vbl_1,sobj.OnsetTime_1, sobj.FlipTimeStamp_1] = Screen(sobj.wPtr, 'Flip');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % timer start, digital out
    if recobj.cycleNum == -recobj.prestim +1
        recobj.STARTloop = tic;
        outputSingleScan(dio.TrigAIFV, [1,1]); %Start AI
        disp('1st Trig')
    else
        recobj.tRec = toc(recobj.STARTloop);
        outputSingleScan(dio.TrigAIFV, [1,0]);
        disp('Trig')
    end
    %reset Trigger level
    outputSingleScan(dio.TrigAIFV,[0,0]);
    
    
elseif Testmode == 1 %Test mode on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %in the Test mode, dio is not used
    %start timer & Trigger AI & FV
    if get(figUIobj.stim,'value')
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_1,sobj.OnsetTime_1, sobj.FlipTimeStamp_1] = Screen(sobj.wPtr, 'Flip');
    end
    if recobj.cycleNum == -recobj.prestim +1
        recobj.STARTloop = tic;
        disp('1st Trig_test')
    else
        recobj.tRec = toc(recobj.STARTloop);
        disp('Trig_test')
    end
end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetTTLall(Testmode, dio)

if Testmode == 0; %Test mode off
    outputSingleScan(dio.TrigAIFV,[0,0]);
    outputSingleScan(dio.VSon,0);
    outputSingleScan(dio.TTL3,0);
end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% define stimulus properties, start timer, recording, stimulus presentation

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
            Concentric_pos_stim(i_pos, sobj.stimcol, Testmode, dio)
        case {'Sin', 'Rect', 'Gabor'}
        case {'Size_rand'}
        case 'Zoom'
        case '2stim'
        case 'Image'
    end
    
    
    
    
    
    
else %prestimulus
    Trigger(Testmode, dio)
    %Uni_stim_BG(i, sobj, bgcol);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nestrd functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function set_stim_position
        % define position as the number of divided matrix = i_pos
        % 1:left top -> sobj.div_num^2: right bottom
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
        % Stimulus position
        
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
    function Pos_cord = set_concentric_position(i_pos)
        % Set stimulus position on concentric circles
        % center: center pos [x, y]
        % dir: sobj.shiftDir（1:8, 9=Ord8, 10=Rand8, 11=Rand16);
        % dist: distance form the center_stim, degree
        
        %%%%% center of cencentric circles%%%%%%
        %[left, top, right, bottom]
        %stimulus
        x1 = sobj.pos(1,sobj.Y(i_pos))-sobj.stimsz(1)/2;
        y1 = sobj.pos(2,sobj.X(i_pos))-sobj.stimsz(2)/2;
        x2 = sobj.pos(1,sobj.Y(i_pos))+sobj.stimsz(1)/2;
        y2 = sobj.pos(2,sobj.X(i_pos))+sobj.stimsz(2)/2;
        sobj.position_cord = [x1,y1,x2,y2];
        
        
        %%%%% stim position on cncentric circles %%%%%%
        %reset randmize
        list = sobj.concentric_mat;
        i_list = RandCycle2(recobj.cycleNum,length(list));
        
        if sobj.shiftDir == 9 %order8
            sobj.list_order = 1:size(list,2);
        end
        
        %%%%%%%%%% distance from center
        i_dist = list(1,sobj.list_order(i_list));
        if i_dist== 0
            sobj.zoom_dist = 0;
        else
            sobj.zoom_dist = sobj.zoom_dist_deg(i_dist);
        end
        
        %%%%%%%%%% angle direction
        i_ang = list(2,sobj.list_order(i_list));
        if dir < 9 %angle fixed or orderd 8
            i_ang = sobj.shiftDir;
            angle_list = linspace(0, 315,8);
        elseif dir == 11 %random 16
            angle_list = linspace(0,337.5,16);
        else %random 8
            angle_list = linspace(0, 315,8);
        end
        
        if i_ang == 0
            sobj.zoom_ang = 0;
        else
            sobj.zoom_ang = angle_list(i_ang);
        end
        
        %%%%%%%%%% white or black %%%%%%%%%%%%%%
        %Fine mapping のときは B/W の刺激を Gray background でだす．%%
        if strcmp(sobj.pattern,'BW')
            i_col = list(3,sobj.list_order(i_list));%randomize した order の 1 or 2 を output
            if i_col == 1
                sobj.stimlumi = 255;
                sobj.stimcol = 255;
            elseif i_col == 2
                sobj.stimlumi = 0;
                sobj.stimcol = 0;
            end
        end
        
        % transform angle direction from 8 or 16 into radian.
        if sobj.zoom_dist  == 0 % center only
            %output
            Pos_cord = sobj.position_cord;
        else
            theta = (i_ang-1)*pi/4; %angle
            sobj.dist_pix = Deg2Pix(sobj.zoom_dist, 300); % マウスの目の 300 mm 前にdisplay
            [X, Y] = pol2cart(theta,sobj.dist_pix);
            %中心補正(monitor の left top が[0,0]右方向，下方向なので，X方向は+, Y方向は-）
            X = sobj.pos(1,sobj.Y(1))+X;
            Y = sobj.pos(2,sobj.X(1))-Y;
            sobj.stim2_center = [X,Y];
            %%%
            switch sobj.pattern
                case {'2stim'}
                    sx_half = sobj.stimsz2(1)/2;
                    sy_half = sobj.stimsz2(2)/2;
                case {'BW','Zoom'}
                    sx_half = sobj.stimsz(1)/2;
                    sy_half = sobj.stimsz(2)/2;
            end
            %output
            Pos_cord = round([X- sx_half, Y-sy_half, X+sx_half, Y+sy_half]);
        end
    end

%%
    function amari = RandCycle2(cyclenum,n_cycle)
        %サイクル数を割り算して，余を出力．amari == 1 のときに，ランダマイズ
        %cyclenum: 現在のサイクル数
        %n_cycle: サイクル一周分の数
        %ランダム化したベクトルを sobj.list_order に入れる
        
        global sobj
        amari = rem(cyclenum, n_cycle);
        
        if amari == 1% randomize
            %1 cycle 分はランダムベクトルを保存
            sobj.list_order = randperm(n_cycle);
        end
        if amari == 0;
            amari = n_cycle;
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
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = Screen(sobj.wPtr, 'Flip', sobj.vbl_2+sobj.duration); %%% sobj.duration 時間経過後 monitor stim off
        outputSingleScan(sTrig,[0,0,0]);% DIO resrt
        sobj.sFlipTimeStamp_3=toc(recobj.STARTloop);
        
    end
%}

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Uni_stim(i_pos, col, Testmode, dio)
        %[left, top, right, bottom]
        x1 = sobj.pos(1,sobj.Y(i_pos))-sobj.stimsz(1)/2;
        y1 = sobj.pos(2,sobj.X(i_pos))-sobj.stimsz(2)/2;
        x2 = sobj.pos(1,sobj.Y(i_pos))+sobj.stimsz(1)/2;
        y2 = sobj.pos(2,sobj.X(i_pos))+sobj.stimsz(2)/2;
        sobj.position_cord = [x1,y1,x2,y2];
        
        Trigger(Testmode, dio)
        %Prep Stim
        Screen(sobj.shape, sobj.wPtr, col, sobj.position_cord);
        
        Stim_Presentation;
    end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Concentric_pos_stim(i_pos, col, Testmode, dio)
        % stim position (and luminace for BW fine mapping)
        sobj.position_cord2 = set_concentric_position(i_pos,sobj.shiftDir);
        sobj.position_cord = sobj.position_cord2;
        
        Trigger(Testmode, dio)
        %Prep Stim
        Screen(sobj.shape, sobj.wPtr, col, sobj.position_cord2);
        
        Stim_Presentation;
    end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Stim_Presentation
        
        %Prepare signal for Photo Sensor (Left, UP in the monitor)
        %as the timing cheker.
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = Screen(sobj.wPtr, 'Flip', sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
        stim_monitor;
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        
        
        % Prep Stim OFF
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        % After sobj.duration, flib BG color
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = Screen(sobj.wPtr, 'Flip', sobj.vbl_2+sobj.duration);
        sobj.sFlipTimeStamp_3 = toc(recobj.STARTloop);
        %GUI stim indicater
        stim_monitor_reset;
        
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end if VisStim
end












%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%
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








