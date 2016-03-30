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
        
        if Testmode == 1 && recobj.cycleNum == 3
            sca;
            set(hObject, 'value', 0);
            break;
        end
        
        % set 1st counter
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['Loop#: ',num2str(recobj.cycleNum)])
        
        %%%%%%%%%%%%%% loop contentes %%%%%%%%%%%%%%%
        % start loop (Trigger + Visual Stimulus)
        MainLoop(dio, hGui, Testmode)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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
            Trigger(Testmode, dio);
            %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%%
        case 1
            % start timer, start FV and start Stim
            AssertOpenGL;
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
% put TTL signal and start timer

global recobj
global sobj

%start timer & Trigger AI & FV
Screen('FillRect', sobj.wPtr, sobj.bgcol); %presenting background

%ScreenON;
[sobj.vbl_1,sobj. OnsetTime_1, sobj.FlipTimeStamp_1] = Screen('Flip', sobj.wPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timer start, digital out
if recobj.cycleNum == -recobj.prestim +1
    recobj.STARTloop = tic;
    generate_trigger([1,1]); %Start AI
    disp('Start AI & Imaging')
else
    recobj.tRec = toc(recobj.STARTloop);
    generate_trigger([1,0]);
    disp('Trig AI')
end
%reset Trigger level
generate_trigger([0,0]);

%%nested%%
    function generate_trigger(pattern)
        if Testmode == 0
            outputSingleScan(dio.TrigAIFV, pattern)
        end
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetTTLall(Testmode, dio)
% Reset all TTL to zero.

if Testmode == 0; %Test mode off
    outputSingleScan(dio.TrigAIFV,[0,0]);
    outputSingleScan(dio.VSon,0);
    outputSingleScan(dio.TTL3,0);
end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VisStim(Testmode, dio)
% define stimulus properties, start timer, recording, stimulus presentation

global figUIobj
global recobj
global sobj

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Start Recording, with/without Visual Stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if recobj.cycleNum <= 0
    %prestimulus
    Trigger(Testmode, dio)
    
elseif recobj.cycleNum > 0
    % Start AI
    Trigger(Testmode, dio)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(sobj.pattern, '2P_Conc')
        %Prep, ON, OFF
        Conc_2P;
        
    else
        if strcmp(sobj.pattern, 'Looming')
            %Prep, ON
            Looming;
            
        elseif strcmp(sobj.pattern, 'Sin') || strcmp(sobj.pattern, 'Gabor') || strcmp(sobj.pattern, 'Rect')
            %Prep, ON
            GratingGLSL;
            
        else
            if strcmp(sobj.pattern, 'Uni')
                %Prep,
                Uni_stim(2);
                
            elseif strcmp(sobj.pattern, 'Size_rand')
                %Prep,
                Uni_stim(1);
                
            elseif strcmp(sobj.pattern, '1P_Conc')
                %Prep,
                Conc_1P;
                
            elseif strcmp(sobj.pattern, 'B/W')
                %Prep,
                Uni_BW;
                
            elseif strcmp(sobj.pattern, 'Images')
                %Prep,
                Imgs_stim;
            end
            
            %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
            Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
            
            %%% stim ON %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Flip and rap timer
            [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
            
            sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
            disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
            stim_monitor;
        end
        
        %%% stim OFF %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Prep BG
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        % After sobj.duration, flib BG color
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_2+sobj.duration);
        sobj.sFlipTimeStamp_3 = toc(recobj.STARTloop);
        
        %GUI stim indicater
        stim_monitor_reset;
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nestrd functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function Uni_stim(flag_size_random)
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode,'value'), fix_center);
        % Set stim size
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), flag_size_random, sobj.stimsz);
        disp(sobj.stimsz);
        maxDiameter = max(stim_size) * 1.01;
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,stim_size],stim_center(1), stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, lumi, Rect, maxDiameter);
    end

%%
    function Conc_1P
        
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        conc_pos_mat = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
            size(sobj.concentric_mat,1)/2, flag_random_dir);
        
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        
        % if conc_pos_mat is defined, changes stim_cneter position
        stim_center = [stim_center(1) + concX, stim_center(2) - concY];
        
        % Set stim size
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz);
        maxDiameter = max(stim_size) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,stim_size],stim_center(1), stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, lumi, Rect, maxDiameter);
    end

%%
    function Uni_BW
        
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        conc_pos_mat = get_condition(4, sobj.concentric_mat, recobj.cycleNum,...
            size(sobj.concentric_mat,1), flag_random_dir);
        
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        
        % if conc_pos_mat is defined, changes stim_cneter position
        stim_center = [stim_center(1) + concX, stim_center(2) - concY];
        
        % Set stim size
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz);
        maxDiameter = max(stim_size) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,stim_size],stim_center(1), stim_center(2));
        
        % Set Luminance
        switch conc_pos_mat(3)
            case 1
                lumi = 255;
            case 2
                lumi = 0;
        end
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, lumi, Rect, maxDiameter);
    end

%%
    function Looming
        %initialize Looming parameters
        time =  0;
        waitframes =  1;
        
        stim_center = sobj.center_pos_list(sobj.fixpos,:); %fixed position
        stim_size =  [0, 0, sobj.loomSize_pix];% max_Stim_Size
        
        topPriorityLevel =  MaxPriority(sobj.wPtr);
        Priority(topPriorityLevel);
        
        %Prep first frame
        Rect = CenterRectOnPointd(stim_size .* 0, stim_center(1), stim_center(2));
        Screen(sobj.shape, sobj.wPtr, 255, Rect);
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        
        % onscreen に １枚目提示してタイマースタート
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
        vbl=sobj.vbl_2;
        
        
        looming_timer = tic;
        %for count = 1:sobj.flipNum
        while toc(looming_timer) < sobj.loomDuration
            %scaleFactor =  abs(amp * sin(angFreq * time + startPhase));
            scaleFactor = time/sobj.loomDuration;
            Rect = CenterRectOnPointd(stim_size .* scaleFactor, stim_center(1), stim_center(2));
            Screen(sobj.shape, sobj.wPtr, 255, Rect);
            Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
            vbl = Screen('Flip', sobj.wPtr, vbl + (waitframes - 0.5) * sobj. m_int);
            time = time + sobj.m_int;
        end
    end

%%
    function Conc_2P
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        conc_pos_mat = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
            size(sobj.concentric_mat,1)/2, flag_random_dir);
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center_fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        
        % if conc_pos_mat is defined, changes stim_cneter position
        stim_center2 = [stim_center(1) + concX, stim_center(2) - concY];
        
        % Set stim size, size(fix)
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz);
        maxDiameter = max(stim_size) * 1.01;
        
        stim_size2 = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz2);
        maxDiameter2 = max(stim_size2) * 1.01;
        
        % define stim position using center and size
        
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,stim_size],stim_center(1), stim_center(2));
        Rect2 = CenterRectOnPointd([0,0,stim_size2],stim_center2(1), stim_center2(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PrepScreen Screen by OffscreenTexture
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stim1 only
        Stim1 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Stim1, lumi, Rect, maxDiameter);
        Screen('FillRect', Stim1, 180, [0 0 40 40]);
        % Stim2 only
        Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape2, Stim2, lumi, Rect2, maxDiameter2);
        Screen('FillRect', Stim2, 180, [0 0 40 40]);
        % Both Stim1 & Stim2
        Stim3 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Stim3, lumi, Rect);
        Screen(sobj.shape2, Stim3, sobj.stimcol2, Rect2, max([maxDiameter, maxDiameter2]));
        Screen('FillRect', Stim3, 255, [0 0 40 40]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ScreenFlip
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if sobj.delayPTB == sobj.delayPTB2 % same timing
            Screen('DrawTexture', sobj.wPtr, Stim3)
            [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
            sobj.vbl2_2 = sobj.vbl_2;
            sobj.OnsetTime2_2 = sobj.OnsetTime_2;
            sobj.FlipTimeStamp2_2 = sobj.FlipTimeStamp_2;
        elseif sobj.delayPTB < sobj.delayPTB2 % Stim1 appears earier thant Stm1
            Screen('DrawTexture', sobj.wPtr, Stim1)
            [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
            Screen('DrawTexture', sobj.wPtr, Stim3)
            [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
        elseif sobj.delayPTB > sobj.delayPTB2 %Stim2 appears earier than Stim1
            Screen('DrawTexture', sobj.wPtr, Stim2)
            [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
            Screen('DrawTexture', sobj.wPtr, Stim3)
            [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
        end
        stim_monitor;
        
        duration1 = sobj.delayPTB + sobj.duration;
        duration2 = sobj.delayPTB2 + sobj.duration2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % stim OFF
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if duration1 == duration2
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration1);
            sobj.vbl2_3 = sobj.vbl_3;
            sobj.OnsetTime2_3 = sobj.OnsetTime_3;
            sobj.FlipTimeStamp2_3 = sobj.FlipTimeStamp_3;
        elseif duration1 < duration2
            Screen('DrawTexture', sobj.wPtr, Stim2);
            [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration1);
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl2_3, sobj.OnsetTime2_3, sobj.FlipTimeStamp2_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration2);
        elseif duration1 > duration2
            Screen('DrawTexture', sobj.wPtr, Stim1);
            [sobj.vbl2_3, sobj.OnsetTime2_3, sobj.FlipTimeStamp2_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration2);
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration1);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Close OffscreenWindow
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Screen(Stim1, 'Close');
        Screen(Stim2, 'Close');
        Screen(Stim3, 'Close');
        stim_monitor_reset;
    end

%%
    function GratingGLSL
        if strcmp(sobj.pattern, 'Sin')
            flag_gabor = 0;
            flag_sin = 1;
        elseif strcmp(sobj.pattern, 'Rect')
            flag_gabor = 0;
            flag_sin = 0;
        elseif strcmp(sobj.pattern, 'Gabor')
            flag_gabor = 1;
            flag_sin = 0;
        end
        
        % get grating direction
        angle_list = sobj.concentric_angle_deg_list';
        
        if get(figUIobj.shiftDir, 'value') < 9
            flag_rand_dir = 2;
        elseif get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_rand_dir=3;
        else %randomize
            flag_rand_dir=1;
        end
        angle = get_condition(5, angle_list, recobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        
        % Set stim center_fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        
        % Set Stim Size fix
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % get  Spatial frequency of the grating
        % cycles/deg
        gratFreq_list_deg = get(figUIobj.gratFreq, 'string');
        gratFreq_deg = str2double(gratFreq_list_deg(get(figUIobj.gratFreq,'value')));
        % deg/cyclesca
        deg_per_cycle = 1/gratFreq_deg;
        % deg/cycle -> pix/cycle
        pix_per_cycle = Deg2Pix(deg_per_cycle, sobj.MonitorDist, sobj.pixpitch);
        cycles_per_pix = 1/pix_per_cycle;
        
        phase = 0;
        contrast = 100;
        %sRect = [0, 0, sobj.ScreenSize(1), sobj.ScreenSize(2)];
        base_stimRect = [0, 0, stim_size(1), stim_size(2)];
        stimRect = CenterRectOnPointd(base_stimRect, stim_center(1), stim_center(2));
        
        % generate grating texture
        if flag_gabor ==  0
            % 0 deg: left->right, 90 deg: up, 180 deg : right->left, 270 deg: down
            angle = 180 - angle;
            if flag_sin == 0
                contrastPreMultiplicator = 1;
            else
                contrastPreMultiplicator = 2.55/sobj.stimlumi;
            end
            %CreateProceduralSineGrating(windowPtr, width, height [, backgroundColorOffset =(0,0,0,0)] [, radius=inf] [, contrastPreMultiplicator=1])
            gratingtex =  CreateProceduralSineGrating(sobj.wPtr, stim_size(1), stim_size(2), [0,0,0,0.0], [], contrastPreMultiplicator);
            Screen('DrawTexture', sobj.wPtr, gratingtex, [], stimRect, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
            
        elseif flag_gabor == 1
            sc = stim_size(1) * 0.16; %sc = 50.0;
            % 0 deg: left->right, 90 deg: up, 180 deg : right->left, 270 deg: down
            angle = angle - 180;
            bgcol = sobj.bgcol/sobj.stimlumi;
            gabortex = CreateProceduralGabor(sobj.wPtr, stim_size(1), stim_size(2), [], [bgcol bgcol bgcol 0.0]);
            Screen('DrawTexture', sobj.wPtr, gabortex, [], stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, cycles_per_pix, sc, contrast, 1, 0, 0, 0]);
            
        end
        
        
        % prep 1st frame
        %%%%%%%%%%%%%%%%%%
        %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        % Flip and rap timer
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for count = 1:sobj.flipNum-1
            phase = count * 360/sobj.frameRate * sobj.shiftSpd;
            
            if flag_gabor ==  0
                Screen('DrawTexture', sobj.wPtr, gratingtex, [], stimRect, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
            elseif flag_gabor == 1
                %Screen('DrawTexture', sobj.wPtr, gabortex, sRect, stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, gratFreq_deg, 50, 100, 1.0, 0, 0, 0]);
                Screen('DrawTexture', sobj.wPtr, gabortex, [], stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, cycles_per_pix, sc, contrast, 1, 0, 0, 0]);
            end
            
            Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
            Screen('Flip', sobj.wPtr);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end

%%
    function Imgs_stim
        %Select Tiff Image from img folder.
        sobj.img_i = get_condition(6, sobj.img_sublist, recobj.cycleNum, length(sobj.img_sublist), 1);
        
        %get img file name
        imgFolder = ['Imgs', filesep];
        imgFileList = dir([imgFolder 'Im*.tif']);
        imgFileName = char(imgFileList(sobj.img_i).name);
        imgFileName2 = [imgFolder imgFileName];
        
        imgdata = imread(imgFileName2, 'TIFF');
        imgtex = Screen('MakeTexture',sobj.wPtr,imgdata);
        
        % Set stim center_fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        stim_center = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        stim_size = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz);
        %
        
        %base_stimRect = [0, 0, size(imgdata,1), size(imgdata,2)];
        base_stimRect = [0, 0, stim_size];
        stimRect = CenterRectOnPointd(base_stimRect, stim_center(1), stim_center(2));
        
        Screen('DrawTexture', sobj.wPtr, imgtex, [], stimRect);
        
    end

%% %% %% %%
    function out = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
        % generate list order
        % n is the number of conditions
        % 1: stimulus center, 2: stimulus size, 3: luminace
        % 4: concentric_angle & distance matrix
        % 5: grating angle
        % 6: tif images
        
        persistent list_order %keep in this function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if flag_random == 2 %fixed condition
            %list_order{n} = fix * ones(1,list_size);
            out = fix;
        else
            if cycleNum == 1 && n == 1
                list_order = cell(6,1);
            end
            i_in_cycle = mod(cycleNum, list_size);
            if i_in_cycle == 0
                i_in_cycle = list_size;
                disp(i_in_cycle)
            elseif i_in_cycle == 1 %Reset list order
                switch flag_random
                    case 1 %randomize
                        list_order{n,1} = randperm(list_size);
                    case 3 %ordered
                        list_order{n,1} = 1:list_size;
                end
            end
            out = list_mat(list_order{n,1}(i_in_cycle),:);
        end
    end

%%
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
        case 'B/W'
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
        case 'Size_rand'
            bgcol = 'm';
            size = Pix2Deg(sobj.stimsz(1), sobj.MonitorDist);
            size = round(size*10)/10; %for disp
            stim_str3 = ['Sz: ', num2str(size),' deg'];
        case '1P_Conc'
            bgcol = 'm';
            stim_str3 = [num2str(sobj.zoom_dist), 'deg, ', num2str(sobj.zoom_ang), 'deg'];
        case '2P_Conc'
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