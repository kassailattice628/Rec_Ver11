function main_loop(hObject, ~, hGui, Testmode, Recmode)
% Main loop structure and subfunctions for GUI setting and visual stimuli

%% call global vars


%% call global vars
global sobj
global recobj

global s
global sOut

global dio

global imaq

global lh

global DataSave % save
global ParamsSave % save

%%
if isfield(hGui, 'setCam')
    SetCam = get(hGui.setCam, 'value');
else
    SetCam = 0;
end
%% Loop Start/ Loop Stop
if get(hObject, 'value')==1 % loop ON
    reload_params([], [], Testmode, Recmode, SetCam);
    recobj.cycleCount = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if sobj.Num_screens == 1 && get(hGui.stim, 'value')
        %open screen in single monitor condition
        [sobj.wPtr, ~] = Screen('OpenWindow', sobj.ScrNum, sobj.bgcol);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while get(hObject, 'value') == 1
        % set 1st counter
        recobj.cycleCount = recobj.cycleCount + 1; % for ParamsSave
        recobj.cycleNum = recobj.cycleNum + 1;
        set(hObject, 'string', 'Looping', 'BackGroundColor', 'g');
        
        %%%%%%%%%%%%%% loop contentes %%%%%%%%%%%%%%%
        % start loop (Trigger + Visual Stimulus)
        Loop_contents(dio, hGui, Testmode, SetCam)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % for Testing with single display condition
        if sobj.Num_screens == 1 && recobj.cycleNum == 5
            set(hObject, 'value', 0);
            Loop_Off
        end
    end
    
else %loop OFF
    Loop_Off;
end

%% %%%%%%%%%%%% nested functions %%%%%%%%%%%%%%
%%
    function Loop_contents(dio, hGui, Testmode, SetCam)
        % ready to start DAQ
        if Testmode == 0
            if s.IsRunning == false
                s.startBackground; %session start, listener ON, *** Waiting Analog Trigger (AI3)
            end
            
            if get(hGui.TTL3, 'value') == 1
                %TTLpulse
                queueOutputData(sOut, 5 * recobj.TTL3AO); %max 10V
                sOut.startBackground
            end
        end
        

        if SetCam && get(hGui.save, 'value')
            
            [~, fname] = fileparts([recobj.dirname, recobj.fname]);
            if exist([recobj.dirname, 'Movie_', fname, num2str(recobj.savecount)], 'dir') == 0
                mkdir([recobj.dirname, 'Movie_', fname, num2str(recobj.savecount)]);
            end
            
            dirname_movie = [recobj.dirname, 'Movie_', fname, num2str(recobj.savecount), '/'];
            logvid = VideoWriter([dirname_movie, '_mov_', num2str(recobj.cycleCount)], 'MPEG-4');
            logvid.FrameRate = imaq.frame_rate;
            logvid.Quality = 50;
            imaq.vid.DiskLogger = logvid;
            
            if isrunning(imaq.vid) == 0
                start(imaq.vid)
            end
        end

        try %error check
            switch get(hGui.stim, 'value')
                %%%%%%%%%%%%%%%%%%%% Visual Stimulus OFF %%%%%%%%%%%%%%%%%%%%
                case 0
                    % start timer and start FV
                    Trigger_Rec(Testmode, SetCam, dio);
                    disp(['AITrig; PreStim', ': #', num2str(recobj.cycleNum)]);
                    
                    % loop interval %
                    pause(recobj.rect/1000 + recobj.interval);
                    
                    %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%%
                case 1
                    % start timer, start FV and start Visu Stim
                    VisStim(Testmode, SetCam, dio);
            end
            %
            if Testmode && get(hGui.save, 'value')
                ParamsSave{1, recobj.cycleCount} = get_save_params(recobj, sobj);
            end
            
            % IMAQ save data check
            if SetCam && get(hGui.save, 'value')
                while islogging(imaq.vid)
                    disp([num2str(imaq.vid.DiskLoggerFrameCount), '/', num2str(imaq.vid.FramesAcquired),...
                        ' frames are written in disk.'])
                    pause(.2);
                end
                
                %check actual FPS
                [~ , timeStamp] = getdata(imaq.vid);
                %figure;
                %plot(timeStamp,'x');
                FPS = imaq.vid.DiskLoggerFrameCount/(timeStamp(end)-timeStamp(1));
                disp(['actual FPS = ', num2str(FPS)]);
            end
            
        catch ME1
            % if any error occurs
            Screen('CloseAll');
            rethrow(ME1);
        end
    end

%%
    function Loop_Off
        %%
        % check the number of screen.
        if sobj.Num_screens==1
            sca;
        end
        set(hObject, 'string', 'Loop-Off', 'BackGroundColor', 'r');
        
        %%%%%% Stop DAQ %%%%%%
        if Testmode==0
            if s.IsRunning
                stop(s)
            end
            if sOut.IsRunning
                stop(sOut)
            end
            delete(lh)
            disp('stop daq sessions, delete event listenner')
        end
        
        %%%%%% Stop Cam %%%%%%
        if SetCam == 1
            if isrunning(imaq.vid)
                stop(imaq.vid)
            end
        end
        
        %%%%%% Save Data %%%%%%
        if get(hGui.save, 'value')
            if Testmode==0
                save(recobj.savefilename, 'DataSave', 'ParamsSave', 'recobj', 'sobj');
            else
                save(recobj.savefilename, 'ParamsSave', 'recobj', 'sobj');
            end
            
            disp(['Captured Data was saved as :: ' recobj.savefilename])
            recobj.savecount = recobj.savecount + 1;
            set(hGui.save, 'value', 0, 'string', 'Unsave', 'BackGroundColor',[0.9400 0.9400 0.9400])
        end
        
        %%%%%% Reset Cycle Counter %%%%%%
        recobj.cycleNum = 0 - recobj.prestim;
        disp(['Loop-Out:', num2str(recobj.cycleNum)]);
        
        if isfield(recobj, 'STARTloop')
            recobj = rmfield(recobj, 'STARTloop');
        end
        
        %reset all triggers
        ResetTTLall(Testmode, dio, sobj);
    end

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% subfunctions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function Trigger_Rec(Testmode, UseCam,  dio)
% put TTL signal and start timer

global recobj
global sobj
global imaq

%start timer & Trigger AI & FV
Screen('FillRect', sobj.wPtr, sobj.bgcol); %presenting background

%ScreenON;
[sobj.vbl_1, sobj. OnsetTime_1, sobj.FlipTimeStamp_1] = Screen('Flip', sobj.wPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timer start, digital out
if recobj.cycleNum == -recobj.prestim +1
    recobj.STARTloop = tic;
    generate_trigger([1,1]); % Start AI & FV
else
    recobj.tRec = toc(recobj.STARTloop);
    generate_trigger([1,0]); % Start AI
end

if UseCam
    trigger(imaq.vid)
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
function TriggerVSon(Testmode, dio, value)
%TTL output for visual stimulus timing
if Testmode == 0
    outputSingleScan(dio.VSon, value);
end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResetTTLall(Testmode, dio, sobj)
% Reset all TTL leve to zero.
if Testmode == 0; %Test mode off
    outputSingleScan(dio.TrigAIFV,[0,0]);
    outputSingleScan(dio.VSon,0);
else
    if sobj.Num_screens == 1
        %Close ScrWindow at Loop-Off
        Screen('CloseAll')
    end
end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VisStim(Testmode, UseCam, dio)
% define stimulus properties, start timer, recording, stimulus presentation

%% call globa params
global figUIobj
global recobj
global sobj

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Start Recording, with/without Visual Stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if recobj.cycleNum <= 0 % Prestimulus
    % Start AI
    Trigger_Rec(Testmode, UseCam, dio)
    stim_monitor;
    pause_time = recobj.rect/1000 + recobj.interval;
    pause(pause_time);
    
elseif recobj.cycleNum > 0 %StimON
    % Start AI
    Trigger_Rec(Testmode, UseCam, dio)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch sobj.pattern
        case 'Uni'
            %Prep
            Uni_stim(2);
            VisStimON;
            VisStimOFF;
            
        case 'Size_rand'
            %Prep
            Uni_stim(1);
            VisStimON;
            VisStimOFF;
            
        case {'1P_Conc', 'B/W'}
            %Prep
            Conc_1P;
            VisStimON;
            VisStimOFF;
        
        case '2P_Conc'
            %Prep, ON, OFF
            Conc_2P;
            time1 = recobj.rect/1000 - (sobj.vbl_3-sobj.vbl_1);
            time2 = recobj.rect/1000 - (sobj.vbl2_3-sobj.vbl_1);
            pause_time = min([time1,time2] + recobj.interval);
            
        case 'Looming'
            %Prep ON, OFF
            Looming;
            %GUI stim indicater
            stim_monitor_reset;
            time1 = recobj.rect/1000 - (sobj.vbl_3-sobj.vbl_1);
            pause_time = time1 + recobj.interval;
        
        case {'Sin', 'Rect', 'Gabor'}
            %Prep, ON
            GratingGLSL;
            VisStimOFF;
            
        case 'Images'
            %Prep
            Img_stim;
            VisStimON;
            VisStimOFF;
            
        case 'Mosaic'
            %Prep
            Mosaic_Dots;
            VisStimON;
            VisStimOFF;
            
        case 'FineMap'
            %Prep
            Fine_Mapping;
            VisStimON;
            VisStimOFF;
    end
    pause(pause_time);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nested functions in 'VisStim' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function Uni_stim(flag_size_random)
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
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
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
    end

%%
    function Conc_1P
        %Set concentric position and luminance
        
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 3;%ordered
        else
            flag_random_dir = 1;%random distance, direction
        end
        
        switch sobj.pattern
            case '1P_Conc'
                %conc_pos_mat(1,i): distance(pix), conc_pos_mat(2,i): angle(rad)
                [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
                    size(sobj.concentric_mat,1)/2, flag_random_dir);
                
                % Set Luminance
                switch get(figUIobj.lumi, 'value')
                    case 1
                        flag_lumi_random = 2; %fix
                    case 2
                        flag_lumi_random = 1; %randomize
                end
                sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
                    length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
                
                sobj.stimcol = sobj.lumi * sobj.stimRGB;
                
            case 'B/W'
                [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat, recobj.cycleNum,...
                    size(sobj.concentric_mat,1), flag_random_dir);
                
                % Set Luminance
                switch conc_pos_mat(3)
                    case 1
                        sobj.lumi = 255;
                    case 2
                        sobj.lumi = 0;
                end
                sobj.stimcol = sobj.lumi;
                
        end
        
        [concX, concY] = pol2cart(conc_pos_mat(2),conc_pos_mat(1));
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % if conc_pos_mat is defined, changes stim_cneter position
        sobj.stim_center = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        maxDiameter = max(sobj.stim_size) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
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
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %use get_condition(5,~)
        sobj.lumi2 = get_condition(5, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi2);
        sobj.stimcol2 = sobj.lumi2 * sobj.stimRGB;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %PrepScreen Screen by OffscreenTexture
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Stim1 only
        Stim1 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Stim1, sobj.stimcol, Rect, maxDiameter);
        Screen('FillRect', Stim1, 180, [0 0 40 40]);
        
        % Stim2 only
        Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape2, Stim2, sobj.stimcol2, Rect2, maxDiameter2);
        Screen('FillRect', Stim2, 180, [0 0 40 40]);
        
        % Both Stim1 & Stim2
        Both_Stim1_Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Both_Stim1_Stim2, sobj.stimcol, Rect);
        Screen(sobj.shape2, Both_Stim1_Stim2, sobj.stimcol2, Rect2);
        Screen('FillRect', Both_Stim1_Stim2, 255, [0 0 40 40]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ScreenFlip
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if sobj.delayPTB < sobj.delayPTB2
            % Stim1 appears earier thant Stim2
            Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, 1);
            
        elseif sobj.delayPTB == sobj.delayPTB2
            % Stim1 and Stim2 appear at the same timing
            Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, 2);
            
        elseif sobj.delayPTB > sobj.delayPTB2
            % Stim1 appears after Stim2
            Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, 3);
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
            
            TriggerVSon(Testmode, dio,0)
            
            sobj.vbl2_3 = sobj.vbl_3;
            sobj.OnsetTime2_3 = sobj.OnsetTime_3;
            sobj.FlipTimeStamp2_3 = sobj.FlipTimeStamp_3;
        elseif duration1 < duration2
            Screen('DrawTexture', sobj.wPtr, Stim2);
            [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration1);
            
            TriggerVSon(Testmode, dio,0)
            
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl2_3, sobj.OnsetTime2_3, sobj.FlipTimeStamp2_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration2);
        elseif duration1 > duration2
            Screen('DrawTexture', sobj.wPtr, Stim1);
            [sobj.vbl2_3, sobj.OnsetTime2_3, sobj.FlipTimeStamp2_3] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1+duration2);
            
            TriggerVSon(Testmode, dio,0)
            
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

%% function for Conc_2P
    function Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, type)
        switch type
            case 1
                % Stim1 appears earier thant Stm1
                Screen('DrawTexture', sobj.wPtr, Stim1)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
                TriggerVSon(Testmode, dio,1)
                disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
                
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
            case 2
                % Stim1 and Stim2 appear at the same timing
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
                TriggerVSon(Testmode, dio,1)
                disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
                
                sobj.vbl2_2 = sobj.vbl_2;
                sobj.OnsetTime2_2 = sobj.OnsetTime_2;
                sobj.FlipTimeStamp2_2 = sobj.FlipTimeStamp_2;
            case 3
                % Stim1 appears after Stim2
                Screen('DrawTexture', sobj.wPtr, Stim2)
                [sobj.vbl2_2, sobj.OnsetTime2_2, sobj.FlipTimeStamp2_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
                
                TriggerVSon(Testmode, dio,1)
                disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
                
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
        end
    end

%%
    function Looming
        % Looming parameters
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        stim_size =  [0, 0, sobj.loomSize_pix];% max_Stim_Size
        sobj.stim_size = sobj.loomSize_pix;
        sobj.size_deg = NaN;
        
        %set flipnum
        flipnum = round(sobj.loomDuration/sobj.m_int);
        scaleFactor = sobj.loomSize_pix./flipnum;
        
        topPriorityLevel =  MaxPriority(sobj.wPtr);
        Priority(topPriorityLevel);
        
        %Prep first frame
        Rect = CenterRectOnPointd(stim_size .* 0, sobj.stim_center(1), sobj.stim_center(2));
        
        Screen(sobj.shape, sobj.wPtr, 255, Rect);
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        
        stim_monitor;
        %%% flip 1st img %%%%%%%%%%%%%%%%%%%%%%%%%%%
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        TriggerVSon(Testmode, dio,1)
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        
        for count = 1:flipnum
            Rect = CenterRectOnPointd([0, 0, count .* scaleFactor], sobj.stim_center(1), sobj.stim_center(2));
            Screen(sobj.shape, sobj.wPtr, 255, Rect);
            Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
            Screen('Flip', sobj.wPtr);
        end
        
        %%% stim off %%%
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.loomDuration);
        
        TriggerVSon(Testmode, dio,0)
    end

%% function to generate shifting grating stimulus
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
        % Set grating direction
        [sobj.angle, sobj.angle_index] = get_condition(5, angle_list, recobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        
        sobj.lumi = sobj.stimlumi;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % get  Spatial frequency of the grating
        % cycles/deg
        gratFreq_list_deg = get(figUIobj.gratFreq, 'string');
        sobj.gratFreq_deg = str2double(gratFreq_list_deg(get(figUIobj.gratFreq, 'value')));
        % deg/cycles
        deg_per_cycle = 1/sobj.gratFreq_deg;
        % deg/cycle -> pix/cycle
        pix_per_cycle = Deg2Pix(deg_per_cycle, sobj.MonitorDist, sobj.pixpitch);
        cycles_per_pix = 1/pix_per_cycle;
        
        phase = 0;
        contrast = 100;
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
        stim_monitor;
        % prep 1st frame
        %%%%%%%%%%%%%%%%%%
        %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        % Flip and rap timer
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        
        TriggerVSon(Testmode, dio, 1);
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
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

%% Simple simbols, alphabet
    function Img_stim
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
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        %
        
        base_stimRect = [0, 0, sobj.stim_size];
        stimRect = CenterRectOnPointd(base_stimRect, sobj.stim_center(1), sobj.stim_center(2));
        
        Screen('DrawTexture', sobj.wPtr, imgtex, [], stimRect);
        
    end

%%
    function Mosaic_Dots
        % Set stim area center
        % Set stim center
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index] = get_condition(1, sobj.center_pos_list, recobj.cycleNum,...
            sobj.divnum^2, get(figUIobj.mode, 'value'), fix_center);
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index = sobj.fixpos;
        end
        
        % Fix stim luminance
        sobj.lumi = sobj.stimlumi;
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Set seed1
        sobj.def_seed1 = sobj.int_seed(recobj.cycleNum);
        disp(sobj.def_seed1)
        rng(sobj.def_seed1);
        
        select = randperm(size(sobj.positions_deg,2));
        
        if sobj.num_dots == 0;
        else
            sobj.dot_position_deg = sobj.positions_deg(:, select(1:sobj.num_dots));
        end
        xy_select = Deg2Pix(sobj.dot_position_deg, sobj.MonitorDist, sobj.pixpitch);
        
        sobj.size_deg = sobj.dist/sobj.div_zoom;
        
        % Set seed2
        sobj.def_seed2 = sobj.int_seed(end - recobj.cycleNum);
        disp(sobj.def_seed2)
        rng(sobj.def_seed2);
        
        size_rand = sobj.size_deg*(rand(sobj.num_dots,1));
        sobj.dot_sizes_deg = ceil(size_rand);
        dot_sizes = Deg2Pix(sobj.dot_sizes_deg, sobj.MonitorDist, sobj.pixpitch);
        
        % Draw multiple dots,
        % Usage::Screen('DrawDots', windowPtr, xy [,size] [,color] [,center] [,dot_type]);
        % dot_type: 0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware)
        if get(figUIobj.shape, 'value') == 1
            shape = 0; %square
        else
            shape = 2; %circle
        end
        Screen('DrawDots', sobj.wPtr, xy_select, dot_sizes, sobj.stimcol, sobj.stim_center, shape);
    end

%%
    function Fine_Mapping
        % Set stim center for Fine Mapping, centered at fixed position
        fix_center = sobj.center_pos_list(sobj.fixpos,:);
        [sobj.stim_center, sobj.center_index_FineMap] = get_condition(7, sobj.center_pos_list_FineMap, recobj.cycleNum,...
            sobj.div_zoom^2, get(figUIobj.mode, 'value'), fix_center);
        sobj.center_index = sobj.fixpos;
        if get(figUIobj.mode, 'value') == 2
            sobj.center_index_FineMap = 0;
        end
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'string'));
        maxDiameter = max(sobj.stim_size) * 1.01;
        % define stim position using center and size
        Rect = CenterRectOnPointd([0, 0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 2; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
        
    end

%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    function [out, index] = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
        % generate list order
        % n is the number of conditions
        % 1: stimulus center, 2: stimulus size, 3: luminace
        % 4: concentric_angle & distance matrix
        % 5: grating angle
        % 6: tif images
        % 7: stimulus center for Fine Mapping
        
        persistent list_order %keep in this function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if flag_random == 2 %fixed condition
            %list_order{n} = fix * ones(1,list_size);
            index = [];
            out = fix;
        else
            if isempty(list_order) && cycleNum == 1 && n == 1
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
    function VisStimON
        %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
        Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        
        %%% stim ON %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Flip and rap timer
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
        
        TriggerVSon(Testmode, dio, 1)
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        stim_monitor;
    end

%%
    function VisStimOFF
        % Prep BacgGround Screen
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        % After sobj.duration, flib BG color
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_2+sobj.duration);
        
        TriggerVSon(Testmode, dio, 0)
        
        %GUI stim indicater
        stim_monitor_reset;
        time1 = recobj.rect/1000 - (sobj.vbl_3 - sobj.vbl_1);
        pause_time = time1 + recobj.interval;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of VisStim
end



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function stim_monitor
%
global figUIobj
global sobj
global recobj

%
if recobj.cycleNum <= 0 % prestim
    set(figUIobj.StimMonitor3, 'string', '', 'BackGroundColor', 'k');
    set(figUIobj.StimMonitor2, 'string', 'Pre Stim', 'ForeGroundColor', 'w', 'BackGroundColor', 'k');
    set(figUIobj.StimMonitor1, 'string', '', 'BackGroundColor', 'k');
    
else % during stimulation
    switch sobj.pattern
        case 'Uni'
            bgcol = 'm';
            stim_str3 = '';
            
        case 'Size_rand'
            bgcol = 'y';
            stim_str3 = ['Size: ', num2str(sobj.size_deg), 'deg'];
            
        case {'1P_Conc', '2P_Conc', 'B/W'}
            bgcol = 'm';
            stim_str3 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            
        case 'Looming'
            bgcol = 'y';
            stim_str3 = ['Spd: ', num2str(sobj.loomSpd_deg), 'deg/s'];
            
        case {'Sin', 'Rect', 'Gabor'}
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
            
        case 'Images'
            bgcol = 'y';
            stim_str3 = ['Image #: ', num2str(sobj.img_i)];
            
        case 'Mosaic'
            bgcol = 'm';
            stim_str3 = 'Mosaic';
            
        case 'FineMap'
            bgcol = 'm';
            stim_str3 = ['FinePos: ', num2str(sobj.center_index_FineMap),...
                '/', num2str(sobj.div_zoom^2)];     
    end
    set(figUIobj.StimMonitor1, 'string', [sobj.pattern, ': #', num2str(recobj.cycleNum)], 'BackGroundColor',bgcol);
    set(figUIobj.StimMonitor2, 'string',['POS: ',num2str(sobj.center_index), '/',num2str(sobj.divnum^2)], 'ForeGroundColor', 'k', 'BackGroundColor', bgcol);
    set(figUIobj.StimMonitor3, 'string', stim_str3, 'BackGroundColor',bgcol);
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