function func_loop(hObject, ~, hGui, Testmode)
% Loop start and stop

global recobj
global sobj
global s
global dio
%global DataSave %save
global ParamsSave %save
global lh

%%
if get(hObject, 'value')==1 % loop ON
    reload_params([], [], Testmode);
    recobj.cycleCount = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Testmode == 1 && get(hGui.stim,'value')
        %open screen
        [sobj.wPtr, ~] = Screen('OpenWindow', sobj.ScrNum, sobj.bgcol);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject,'value') == 1
        % set 1st counter
        recobj.cycleCount = recobj.cycleCount + 1; % for ParamsSave
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject,'string', 'Looping', 'BackGroundColor', 'g');
        % report the cycle number
        disp(['Loop#: ',num2str(recobj.cycleNum)])
        
        %%%%%%%%%%%%%% loop contentes %%%%%%%%%%%%%%%
        % start loop (Trigger + Visual Stimulus)
        MainLoop(dio, hGui, Testmode)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if Testmode == 1 && recobj.cycleNum == 5
            set(hObject, 'value', 0);
            func_Loop_Off
        end
    end
else %loop OFF
    func_Loop_Off;
end
%%
    function func_Loop_Off
        set(hObject,'string', 'Loop-Off', 'BackGroundColor', 'r');
        % stop loop & data acquiring
        if Testmode==0
            if s.IsRunning
                stop(s)
            end
            delete(lh)
            disp('stop daq sessions, delete event listenner')
        end
        
        %%%%%% Save Data %%%%%%%%
        if get(hGui.save, 'value')
            if Testmode==0
                save(recobj.savefilename, 'DataSave', 'ParamsSave', 'recobj', 'sobj');
            else
                save(recobj.savefilename, 'ParamsSave', 'recobj', 'sobj');
            end
            
            disp(['data saved as ::' recobj.savefilename])
            recobj.savecount = recobj.savecount + 1;
            set(hGui.save, 'value', 0, 'string', 'Unsave', 'BackGroundColor',[0.9400 0.9400 0.9400])
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Reset Cycle Counter %
        recobj.cycleNum = 0- recobj.prestim;
        disp(['Loop-Out:', num2str(recobj.cycleNum)]);
        recobj = rmfield(recobj,'STARTloop');
        
        %reset all triggers
        ResetTTLall(Testmode, dio);
    end

end

%% subfunctions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MainLoop(dio, hGui, Testmode)
% Main structure%
global s
global recobj
global sobj
global ParamsSave
global sOut

% ready to start DAQ
if Testmode == 0
    if s.IsRunning==false
        s.startBackground; %session start, listener ON, *** Waiting Analog Trigger (AI3)
    end
    
    if get(hGui.TTL3,'value')==1
        %TTLpulse
        queueOutputData(sOut, 5 * recobj.TTL3AO); %max 10V
        sOut.startBackground
    end
end

try %error check
    switch get(hGui.stim, 'value')
        %%%%%%%%%%%%%%%%%%%% Visual Stimulus OFF %%%%%%%%%%%%%%%%%%%%
        case 0
            % start timer and start FV
            Trigger(Testmode, dio);
            % loop interval %
            pause(recobj.rect/1000 + recobj.interval); 
        %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%%
        case 1
            % start timer, start FV and start Stim
            VisStim(Testmode, dio);
    end
    
    if Testmode == 1
        ParamsSave{1, recobj.cycleCount} = get_save_params(recobj, sobj);
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
[sobj.vbl_1, sobj. OnsetTime_1, sobj.FlipTimeStamp_1] = Screen('Flip', sobj.wPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timer start, digital out
if recobj.cycleNum == -recobj.prestim +1
    recobj.STARTloop = tic;
    generate_trigger([1,1]); %Start AI
else
    recobj.tRec = toc(recobj.STARTloop);
    generate_trigger([1,0]);
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
function TriggerTTL3(Testmode, dio, value)
global recobj
if Testmode == 0
    if value == 1
        recobj.START_TTL3 = tic;
    end
    outputSingleScan(dio.TTL3, value);
end


end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ResetTTLall(Testmode, dio)
% Reset all TTL to zero.

if Testmode == 0; %Test mode off
    outputSingleScan(dio.TrigAIFV,[0,0]);
    outputSingleScan(dio.VSon,0);
    %outputSingleScan(dio.TTL3,0);
else
    sca;
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
if recobj.cycleNum <= 0 % prestimulus
    % Start AI
    Trigger(Testmode, dio)
    stim_monitor;
    pause_time = recobj.rect/1000 + recobj.interval;
    pause(pause_time);
    
elseif recobj.cycleNum > 0 %StimON
    % Start AI
    Trigger(Testmode, dio)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(sobj.pattern, '2P_Conc')
        %Prep, ON, OFF
        Conc_2P;
        time1 = recobj.rect/1000 - (sobj.vbl_3-sobj.vbl_1);
        time2 = recobj.rect/1000 - (sobj.vbl2_3-sobj.vbl_1);
        pause_time = min([time1,time2] + recobj.interval);
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
        time1 = recobj.rect/1000 - (sobj.vbl_3-sobj.vbl_1);
        pause_time = time1 + recobj.interval;
    end
    pause(pause_time);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nestrd functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function Uni_stim(flag_size_random)
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode,'value'), fix_center);
        if get(figUIobj.mode,'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % Set stim size
        [sobj.stim_size, sobj.size_index] = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), flag_size_random, sobj.stimsz);
        if flag_size_random == 2
            sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        else
            sobj.size_deg = sobj.stimsz_deg_list(sobj.size_index);
        end
        
        maxDiameter = max(sobj.stim_size) * 1.01;
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.lumi, Rect, maxDiameter);
    end

%%
    function Conc_1P
        
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
            size(sobj.concentric_mat,1)/2, flag_random_dir);
        
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode,'value'), fix_center);
        if get(figUIobj.mode,'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % if conc_pos_mat is defined, changes stim_cneter position
        sobj.stim_center = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.lumi, Rect);
    end

%%
    function Uni_BW
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat, recobj.cycleNum,...
            size(sobj.concentric_mat,1), flag_random_dir);
        
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode,'value'), fix_center);
        if get(figUIobj.mode,'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % if conc_pos_mat is defined, changes stim_cneter position
        sobj.stim_center = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        % Set stim size
        stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        maxDiameter = max(stim_size) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        % Set Luminance
        switch conc_pos_mat(3)
            case 1
                sobj.lumi = 255;
            case 2
                sobj.lumi = 0;
        end
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.lumi, Rect, maxDiameter);
    end

%%
    function Looming
        %initialize Looming parameters
        time =  0;
        waitframes =  1;
        
        % Set stim center as fixed position
        sobj.stim_center = sobj.center_pos_list(sobj.fixpos,:); %fixed position
        sobj.center_index = sobj.fixpos;
        
        stim_size =  [0, 0, sobj.loomSize_pix];% max_Stim_Size
        sobj.stim_size = sobj.loomSize_pix;
        
        topPriorityLevel =  MaxPriority(sobj.wPtr);
        Priority(topPriorityLevel);
        
        %Prep first frame
        Rect = CenterRectOnPointd(stim_size .* 0, sobj.stim_center(1), sobj.stim_center(2));
        
        Screen(sobj.shape, sobj.wPtr, 255, Rect);
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        
        % onscreen に １枚目提示してタイマースタート
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
        stim_monitor
        vbl=sobj.vbl_2;
        
        
        looming_timer = tic;
        %for count = 1:sobj.flipNum
        while toc(looming_timer) < sobj.loomDuration
            %scaleFactor =  abs(amp * sin(angFreq * time + startPhase));
            scaleFactor = time/sobj.loomDuration;
            Rect = CenterRectOnPointd(stim_size .* scaleFactor, sobj.stim_center(1), sobj.stim_center(2));
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
        [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
            size(sobj.concentric_mat,1)/2, flag_random_dir);
        %conc_pos_mat(1,i): distance(pix)
        %conc_pos_mat(2,i): angle(rad)
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center_fix
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, 2, fix_center);
        sobj.center_index = sobj.fixpos;
        
        sobj.stim_center2 = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        % Set stim size, size(fix)
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        maxDiameter = max(sobj.stim_size) * 1.01;
        
        sobj.stim_size2 = sobj.stimsz2;
        sobj.size_deg2 = str2double(get(figUIobj.size2, 'string'));
        maxDiameter2 = max(sobj.stim_size2) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        Rect2 = CenterRectOnPointd([0,0, sobj.stim_size2], sobj.stim_center2(1), sobj.stim_center2(2));
        
        % Set Luminance
        switch get(figUIobj.lumi,'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PrepScreen Screen by OffscreenTexture
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stim1 only
        Stim1 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Stim1, sobj.lumi, Rect, maxDiameter);
        Screen('FillRect', Stim1, 180, [0 0 40 40]);
        
        % Stim2 only
        Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape2, Stim2, sobj.lumi, Rect2, maxDiameter2);
        Screen('FillRect', Stim2, 180, [0 0 40 40]);
        
        % Both Stim1 & Stim2
        Both_Stim1_Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Both_Stim1_Stim2, sobj.lumi, Rect);
        Screen(sobj.shape2, Both_Stim1_Stim2, sobj.lumi, Rect2, max([maxDiameter, maxDiameter2]));
        Screen('FillRect', Both_Stim1_Stim2, 255, [0 0 40 40]);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ScreenFlip
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if sobj.delayPTB < sobj.delayPTB2
            % Stim1 appears earier thant Stm1
            
            if (recobj.delayTTL3 + recobj.durationTTL3) <= recobj.delayPTB
                %wait TTL3 delay
                while toc(recobj.STARTloop) < recobj.delayTTL3
                end
                TriggerTTL3(Testmode, dio, 1) % TTL3 ON
                while toc(recobj.START_TTL3) < recobj.duration
                end
                TriggerTTL3(Testmode, dio, 0) % TTL3 OFF
                
                Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, 1);
                
            elseif recobj.delayTTL3 < recobj.delayPTB
                %wait TTL3 delay
                while toc(recobj.STARTloop) < recobj.delayTTL3
                end
                TriggerTTL3(Testmode, dio, 1) % TTL3 ON
                
                Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, 1);
                
            end
            
        elseif sobj.delayPTB == sobj.delayPTB2
            % Stim1 and Stim2 appear at the same timing
            Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
            [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
            sobj.vbl2_2 = sobj.vbl_2;
            sobj.OnsetTime2_2 = sobj.OnsetTime_2;
            sobj.FlipTimeStamp2_2 = sobj.FlipTimeStamp_2;
            
        elseif sobj.delayPTB > sobj.delayPTB2
            % Stim1 appears after Stim2
            Screen('DrawTexture', sobj.wPtr, Stim2)
            [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
            Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
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
        Screen(Both_Stim1_Stim2, 'Close');
        stim_monitor_reset;
    end


    function Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, type)
        switch type
            case 1
                % Stim1 appears earier thant Stm1
                Screen('DrawTexture', sobj.wPtr, Stim1)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
            case 2
                % Stim1 and Stim2 appear at the same timing
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                sobj.vbl2_2 = sobj.vbl_2;
                sobj.OnsetTime2_2 = sobj.OnsetTime_2;
                sobj.FlipTimeStamp2_2 = sobj.FlipTimeStamp_2;
            case 3
                % Stim1 appears after Stim2
                Screen('DrawTexture', sobj.wPtr, Stim2)
                [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
        end
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
            angle_list = sobj.concentric_angle_deg_list(get(figUIobj.shiftDir, 'value'));
        elseif get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_rand_dir=3;
        else %randomize
            flag_rand_dir=1;
        end
        
        [sobj.angle, sobj.angle_index] = get_condition(5, angle_list, recobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode,'value'), fix_center);
        if get(figUIobj.mode,'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % get  Spatial frequency of the grating
        % cycles/deg
        gratFreq_list_deg = get(figUIobj.gratFreq, 'string');
        sobj.gratFreq_deg = str2double(gratFreq_list_deg(get(figUIobj.gratFreq,'value')));
        % deg/cyclesca
        deg_per_cycle = 1/sobj.gratFreq_deg;
        % deg/cycle -> pix/cycle
        pix_per_cycle = Deg2Pix(deg_per_cycle, sobj.MonitorDist, sobj.pixpitch);
        cycles_per_pix = 1/pix_per_cycle;
        
        phase = 0;
        contrast = 100;
        %sRect = [0, 0, sobj.ScreenSize(1), sobj.ScreenSize(2)];
        base_stimRect = [0, 0, sobj.stim_size(1), sobj.stim_size(2)];
        stimRect = CenterRectOnPointd(base_stimRect, sobj.stim_center(1), sobj.stim_center(2));
        
        % generate grating texture
        if flag_gabor ==  0
            % 0 deg: left->right, 90 deg: up, 180 deg : right->left, 270 deg: down
            angle = 180 - sobj.angle;
            if flag_sin == 0
                contrastPreMultiplicator = 1;
            else
                contrastPreMultiplicator = 2.55/sobj.stimlumi;
            end
            
            if get(figUIobj.shape, 'value')==1
                radius = [];
            else
                radius = sobj.stim_size(1)/2;
            end
            
            %CreateProceduralSineGrating(windowPtr, width, height [, backgroundColorOffset =(0,0,0,0)] [, radius=inf] [, contrastPreMultiplicator=1])
            gratingtex =  CreateProceduralSineGrating(sobj.wPtr, sobj.stim_size(1), sobj.stim_size(2), [0,0,0,0.0], radius, contrastPreMultiplicator);
            Screen('DrawTexture', sobj.wPtr, gratingtex, [], stimRect, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
            
        elseif flag_gabor == 1
            sc = sobj.stim_size(1) * 0.16; %sc = 50.0;
            % 0 deg: left->right, 90 deg: up, 180 deg : right->left, 270 deg: down
            angle = sobj.angle - 180;
            bgcol = sobj.bgcol/sobj.stimlumi;
            gabortex = CreateProceduralGabor(sobj.wPtr, sobj.stim_size(1), sobj.stim_size(2), [], [bgcol bgcol bgcol 0.0]);
            Screen('DrawTexture', sobj.wPtr, gabortex, [], stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, cycles_per_pix, sc, contrast, 1, 0, 0, 0]);
        end
        
        % prep 1st frame
        %%%%%%%%%%%%%%%%%%
        %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        % Flip and rap timer
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        stim_monitor;
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
        
        % Set stim center as fixed position
        sobj.stim_center = sobj.center_pos_list(sobj.fixpos,:); %fixed position
        sobj.center_index = sobj.fixpos;
        
        
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        %
        
        base_stimRect = [0, 0, sobj.stim_size];
        stimRect = CenterRectOnPointd(base_stimRect, sobj.stim_center(1), sobj.stim_center(2));
        
        Screen('DrawTexture', sobj.wPtr, imgtex, [], stimRect);
        
    end

%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    function [out, index] = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
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
            index = [];
            out = fix;
            
        else
            if cycleNum == 1 && n == 1
                list_order = cell(6,1);
            end
            i_in_cycle = mod(cycleNum, list_size);
            
            if i_in_cycle == 0
                i_in_cycle = list_size;
                disp('reset_rand_cycle')
                
            elseif i_in_cycle == 1 %Reset list order
                switch flag_random
                    case 1 %randomize
                        list_order{n,1} = randperm(list_size);
                    case 3 %ordered
                        list_order{n,1} = 1:list_size;
                end
            end
            index = list_order{n,1}(i_in_cycle);
            out = list_mat(index,:);
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
    set(figUIobj.StimMonitor3,'string','', 'BackGroundColor','k');
    set(figUIobj.StimMonitor2,'string','Pre Stim','ForegroundColor','white','BackGroundColor','k');
    set(figUIobj.StimMonitor1,'string','', 'BackGroundColor','k');
    
else % during stimulation
    switch sobj.pattern
        case 'Uni'
            bgcol = 'm';
            stim_str3 = '';
            
        case 'Size_rand'
            bgcol = 'm';
            stim_str3 = ['Size: ', num2str(sobj.size_deg),' deg'];
            
        case '1P_Conc'
            bgcol = 'm';
            stim_str3 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            
        case '2P_Conc'
            bgcol = 'g';
            stim_str3 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            
        case 'B/W'
            bgcol = 'c';
            stim_str3 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            
        case 'Looming'
            bgcol = 'y';
            stim_str3 = ['Spd: ', num2str(sobj.loomSpd_deg), 'deg/s'];
            
        case {'Sin', 'Rect','Gabor'}
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
            
        case 'Images'
            bgcol = 'y';
            stim_str3 = ['Image #: ', num2str(sobj.img_i)];
    end
    %position in matrix
    
    set(figUIobj.StimMonitor3,'string',sobj.pattern, 'BackGroundColor',bgcol);
    set(figUIobj.StimMonitor2,'string',['POS: ',num2str(sobj.center_index),'/',num2str(sobj.divnum^2)],'ForegroundColor','black','BackGroundColor',bgcol);
    set(figUIobj.StimMonitor1,'string', stim_str3, 'BackGroundColor',bgcol);
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