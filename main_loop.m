function main_loop(hObject, ~, hGui, Testmode, Recmode)
% Main loop structure and subfunctions for GUI setting and visual stimuli

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
        set(hObject, 'String', 'Looping', 'BackGroundColor', 'g');
        
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
        persistent fname
        
        %% ready to start USB Cam
        if SetCam && get(hGui.save, 'value')
            if recobj.cycleCount == 1
                [~, fname] = fileparts([recobj.dirname, recobj.fname]);
                if exist([recobj.dirname, 'Movie_', fname, num2str(recobj.savecount)], 'dir') == 0
                    mkdir([recobj.dirname, 'Movie_', fname, num2str(recobj.savecount)]);
                end
            end
            dirname_movie = [recobj.dirname, 'Movie_', fname, num2str(recobj.savecount), '/'];
            logvid = VideoWriter([dirname_movie, 'mov_', num2str(recobj.cycleCount)], 'MPEG-4');
            logvid.FrameRate = imaq.frame_rate;
            logvid.Quality = 50;
            if isrunning(imaq.vid) == 0
                start(imaq.vid)
            end
        end
        
        %% ready to start DAQ
        if Testmode == 0
            if get(hGui.TTL3, 'value') == 1
                %TTLpulse
                queueOutputData(sOut, 5 * recobj.TTL3AO); %max 10V
                sOut.startBackground
            end
            %DAQ timer start
            if s.IsRunning == false
                s.startBackground; %session start, listener ON, *** Waiting Analog Trigger (AI3)
            end
        end
        
        %%
        try %error check
            switch get(hGui.stim, 'value')
                %%%%%%%%%%%%%%%%%%%% Visual Stimulus OFF %%%%%%%%%%%%%%%%%%%%
                case 0
                    % start timer and start FV
                    disp(['AITrig; NoStim', ': #', num2str(recobj.cycleNum)]);
                    Trigger_Rec(Testmode, SetCam, dio);
                    
                    % loop interval %
                    pause(recobj.rect/1000);
                    
                    %%%%%%%%%%%%%%%%%%%% Visual Stimulus ON %%%%%%%%%%%%%%%%%%%%%
                case 1
                    % start timer, start FV and start Visu Stim
                    VisStim(Testmode, SetCam, dio);
            end
            
            %%%%%%%%%%%%%%%%%%%% SAVE parameters %%%%%%%%%%%%%%%%%%%%%
            if Testmode && get(hGui.save, 'value')
                ParamsSave{1, recobj.cycleCount} = get_save_params(Testmode, recobj, sobj);
            end
            
            %%%%%%%%%%%%%%%%%%%% SAVE IMAQ %%%%%%%%%%%%%%%%%%%%%
            if SetCam && get(hGui.save, 'value')
                disp('save movie')
                [Img, timeStamp] = getdata(imaq.vid, imaq.vid.FramesAcquired);
                open(logvid)
                start_vid = tic;
                for ii = 1:length(timeStamp)
                    writeVideo(logvid, Img(:,:,:,ii))
                end
                t_vid_save = toc(start_vid);
                close(logvid)
                disp('finish save movie')
                
                %ParamsSave{1, recobj.cycleCount}.Img = Img;
                clear Img
                %figure;
                %plot(timeStamp,'x');
                FPS = length(timeStamp)/(timeStamp(end)-timeStamp(1));
                disp(['actual FPS = ', num2str(FPS)]);
                
                flushdata(imaq.vid)
                clear logvid
            end
            
            %%%%% loop interval %%%%%
            if exist('t_vid_save', 'var') && t_vid_save < recobj.interval
                pause(recobj.interval - t_vid_save)
                
            else
                pause(recobj.interval)
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
        set(hObject, 'String', 'Loop-Off', 'BackGroundColor', 'r');
        
        %%%%%% Stop DAQ %%%%%%
        if Testmode==0
            if s.IsRunning
                stop(s)
            end
            if sOut.IsRunning
                stop(sOut)
            end
            delete(lh)
            disp('stop daq sessions, delete event listenner.')
        end
        
        %%%%%% Stop Cam %%%%%%
        if SetCam == 1
            if isrunning(imaq.vid)
                stop(imaq.vid)
                disp('stop imaq.')
            end
            %delete(imaq.vid)
        end
        
        %%%%%% Save Data %%%%%%
        if get(hGui.save, 'value')
            if Testmode == 0
                save(recobj.savefilename, 'DataSave', 'ParamsSave', 'recobj', 'sobj');
            else
                save(recobj.savefilename, 'ParamsSave', 'recobj', 'sobj');
            end
            
            disp(['Captured Data was saved as :: ', recobj.savefilename])
            recobj.savecount = recobj.savecount + 1;
            set(hGui.save, 'value', 0, 'String', 'Unsave', 'BackGroundColor', [0.9400 0.9400 0.9400])
        end
        
        % clear save data from memory
        DataSave = [];
        ParamsSave = [];
        
        disp(':::Loop-Out:::');
        
        %reset all triggers
        ResetTTLall(Testmode, dio, sobj);
    end

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% subfunctions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function Trigger_Rec(Testmode, UseCam, dio)
% put TTL signal and start timer

global recobj
global sobj
global imaq

%start timer & Trigger AI & FV
Screen('FillRect', sobj.wPtr, sobj.bgcol); %prepare background

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if UseCam && isrunning(imaq.vid)
    trigger(imaq.vid)
end
% timer start, digital out
if recobj.cycleNum == -recobj.prestim +1
    %background ScreenON;
    [sobj.vbl_1, sobj.onset, sobj.flipend] = Screen('Flip', sobj.wPtr);
    generate_trigger([1,1]); % Start AI & FV
    disp('Timer Start')
    recobj.t_START = tic;
    recobj.t_AIstart = 0;
    
else
    %background ScreenON;
    [sobj.vbl_1, sobj.onset, sobj.flipend] = Screen('Flip', sobj.wPtr);
    generate_trigger([1,0]); % Start AI
    AItime = toc(recobj.t_START);
    recobj.t_AIstart = AItime - recobj.t_START;
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
    disp(['AITrig; PreStim', ': #', num2str(recobj.cycleNum)]);
    Trigger_Rec(Testmode, UseCam, dio)
    stim_monitor;
    pause_time = recobj.rect/1000;
    pause(pause_time);
    
elseif recobj.cycleNum > 0 %StimON
    % Start AI
    disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
    Trigger_Rec(Testmode, UseCam, dio)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch sobj.pattern
        case 'Uni'
            %Prep
            Uni_stim(3); %fixed size (=3)
            VisStimON;
            VisStimOFF;
            
        case 'Size_rand'
            %Prep
            Uni_stim(1); %random size (=1)
            VisStimON;
            VisStimOFF;
            
        case {'B/W'}
            %Prep
            Conc_1P;
            VisStimON;
            VisStimOFF;
            
        case '2P'
            %Prep, ON, OFF
            Conc_2P;
            time1 = recobj.rect/1000 - (sobj.vbl_3 - sobj.vbl_1);
            time2 = recobj.rect/1000 - (sobj.vbl2_3 - sobj.vbl_1);
            pause_time = min([time1, time2]);
            
        case 'Looming'
            %Prep ON, OFF
            Looming;
            %GUI stim indicater
            stim_monitor_reset;
            time1 = recobj.rect/1000 - (sobj.vbl_3 - sobj.vbl_1);
            pause_time = time1;
            
        case {'Sin', 'Rect', 'Gabor'}
            %Prep, ON
            GratingGLSL(2);
            VisStimOFF;
            
        case {'MoveBar'}
            Movebar_stim;
            stim_monitor_reset;
            time1 = recobj.rect/1000 - (sobj.vbl_3 - sobj.vbl_1);
            pause_time = time1;
            %VisStimON;
            %VisStimOFF;
            
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
        %flag_size_random
        %<get_condition ‚Ì random_flag ‚Í 1:random, 2:ordered, 3:fix>
        
        Set_stim_position;
        
        %%%%%%%%%%%%%%%%
        % Set stim size
        %%%%%%%%%%%%%%%%
        [sobj.stim_size, sobj.size_index] = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), flag_size_random, sobj.stimsz);
        if flag_size_random == 3
            %fix size
            sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        else
            %random size
            sobj.size_deg = sobj.stimsz_deg_list(sobj.size_index);
        end
        
        maxDiameter = max(sobj.stim_size) * 1.01;
        
        %%%%%%%%%%%%%%%%
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0,sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        %%%%%%%%%%%%%%%%
        % Set Luminance
        %%%%%%%%%%%%%%%%
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 3; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %%%%%%%%%%%%%%%%%%%
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
    end

%%
    function Conc_1P
        %%%%%%%%%%
        %Set concentric position and luminance
        %%%%%%%%%%
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 2; %ordered
        else
            flag_random_dir = 1; %random distance, direction
        end
        
        switch sobj.pattern
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
        
        %%%%%%%%%%%%%%%%%
        % Set stim center
        %%%%%%%%%%%%%%%%%
        Set_stim_position;
        
        % if conc_pos_mat is defined, changes stim_cneter position
        sobj.stim_center = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        % Set stim size, fixed
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        maxDiameter = max(sobj.stim_size) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0, 0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
    end

%%
    function Conc_2P
        % Set div, dist, angle, of 2nd stim position
        if get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_random_dir = 2;%ordered distance, direction
        else
            flag_random_dir = 1;%random distance, direction
        end
        [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat(1:end/2,:), recobj.cycleNum,...
            size(sobj.concentric_mat,1)/2, flag_random_dir);
        
        [concX, concY] = pol2cart(conc_pos_mat(2), conc_pos_mat(1));
        
        % Set stim center_fix
        Set_stim_position;
        
        sobj.stim_center2 = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        
        %Sizes are defiend in reload_params
        maxDiameter = max(sobj.stim_size) * 1.01;
        maxDiameter2 = max(sobj.stim_size2) * 1.01;
        
        % define stim position using center and size
        Rect = CenterRectOnPointd([0,0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        Rect2 = CenterRectOnPointd([0,0, sobj.stim_size2], sobj.stim_center2(1), sobj.stim_center2(2));
        
        % Set Luminance
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 3; %fix luminance
            case 2
                flag_lumi_random = 1; %random luminance
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
        Screen('FillRect', Stim1, 180, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        % Stim2 only
        Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape2, Stim2, sobj.stimcol2, Rect2, maxDiameter2);
        Screen('FillRect', Stim2, 180, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        
        % Both Stim1 & Stim2
        Both_Stim1_Stim2 = Screen('OpenOffscreenWindow', sobj.ScrNum, sobj.bgcol);
        Screen(sobj.shape, Both_Stim1_Stim2, sobj.stimcol, Rect);
        Screen(sobj.shape2, Both_Stim1_Stim2, sobj.stimcol2, Rect2);
        Screen('FillRect', Both_Stim1_Stim2, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        
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
            [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + duration1);
            
            TriggerVSon(Testmode, dio,0)
            
            sobj.vbl2_3 = sobj.vbl_3;
            sobj.BeamposOFF_2 = sobj.BeamposOFF;
            
        elseif duration1 < duration2
            Screen('DrawTexture', sobj.wPtr, Stim2);
            [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + duration1);
            
            TriggerVSon(Testmode, dio,0)
            
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl2_3, ~, ~, ~, sobj.BeamposOFF_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + duration2);
            
        elseif duration1 > duration2
            Screen('DrawTexture', sobj.wPtr, Stim1);
            [sobj.vbl2_3, ~, ~, ~, sobj.BeamposOFF_2] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + duration2);
            
            TriggerVSon(Testmode, dio,0)
            
            Screen('FillRect', sobj.wPtr, sobj.bgcol);
            [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] =...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + duration1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Close OffscreenWindow
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Screen(Stim1, 'Close');
        Screen(Stim2, 'Close');
        Screen(Both_Stim1_Stim2, 'Close');
        stim_monitor_reset;
    end

%%%% function for Conc_2P
    function Flip_Conc2(Stim1, Stim2, Both_Stim1_Stim2, type)
        switch type
            case 1
                % Stim1 appears earier thant Stm1
                Screen('DrawTexture', sobj.wPtr, Stim1)
                [sobj.vbl_2, ~, ~, ~, sobj.BeamposON,] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
                TriggerVSon(Testmode, dio,1)
                
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl2_2, ~, ~, ~, sobj.BeamposON_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
                
            case 2
                % Stim1 and Stim2 appear at the same timing
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
                TriggerVSon(Testmode, dio,1)
                
                sobj.vbl2_2 = sobj.vbl_2;
                sobj.BeamposON_2 = sobj.BeamposON;
                
            case 3
                % Stim1 appears after Stim2
                Screen('DrawTexture', sobj.wPtr, Stim2)
                [sobj.vbl2_2, ~, ~, ~, sobj.BeamposON_2] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB2);
                
                TriggerVSon(Testmode, dio,1)
                
                Screen('DrawTexture', sobj.wPtr, Both_Stim1_Stim2)
                [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] =...
                    Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);
                
        end
    end

%%
    function Looming
        % Looming parameters
        
        Set_stim_position;
        
        % Spd
        sobj.stim_size = sobj.loomSize_pix;
        sobj.size_deg = NaN;
        
        %Set Luminance
        sobj.stimcol = sobj.stimlumi;
        
        %set flipnum
        flipnum = round(sobj.loomDuration/sobj.m_int);
        scaleFactor = sobj.loomSize_pix./flipnum;
        
        topPriorityLevel =  MaxPriority(sobj.wPtr);
        Priority(topPriorityLevel);
        
        %Prep first frame
        Rect = CenterRectOnPointd([0, 0, sobj.loomSize_pix] .* 0, sobj.stim_center(1), sobj.stim_center(2));
        
        
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect);
        Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        stim_monitor;
        %%% flip 1st img %%%%%%%%%%%%%%%%%%%%%%%%%%%
        [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
        TriggerVSon(Testmode, dio,1)
        
        %Prep flip
        Rect = zeros(flipnum-1, 4);
        for i = 1:flipnum
            Rect(i,:) = CenterRectOnPointd([0, 0, i .* scaleFactor], sobj.stim_center(1), sobj.stim_center(2));
        end
        %DrawFlip
        for i = 1:flipnum
            Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect(i,:));
            %Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
            Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
            Screen('Flip', sobj.wPtr);
        end
        
        %%% stim off %%%
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.loomDuration);
        
        TriggerVSon(Testmode, dio,0)
    end

%% function to generate shifting grating stimulus
    function GratingGLSL(ver)
        
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
        angle_list = sobj.grating_angle_deg_list';
        
        if get(figUIobj.shiftDir, 'value') < 9
            flag_rand_dir = 3;
            angle_list = sobj.grating_angle_deg_list(get(figUIobj.shiftDir, 'value'));
        elseif get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_rand_dir = 2;
        else %randomize
            flag_rand_dir = 1;
        end
        
        
        [sobj.angle, sobj.angle_index] = get_condition(5, angle_list, recobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        
        % Position
        Set_stim_position;
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        
        sobj.lumi = sobj.stimlumi;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % get Spatial frequency of the grating
        % cycles/deg
        gratFreq_list_deg = get(figUIobj.gratFreq, 'String');
        sobj.gratFreq_deg = str2double(gratFreq_list_deg(get(figUIobj.gratFreq, 'value')));
        % deg/cycles
        deg_per_cycle = 1/sobj.gratFreq_deg;
        % deg/cycle -> pix/cycle
        pix_per_cycle = Deg2Pix(deg_per_cycle, sobj.MonitorDist, sobj.pixpitch);
        cycles_per_pix = 1/pix_per_cycle;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ver == 1
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
        %AddPhoto Sensor (Left, Bottom in the monitor) for the stimulus timing check
        Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        % Flip and rap timer
        [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
        
        TriggerVSon(Testmode, dio, 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for count = 1:sobj.flipNum-1
            phase = count * 360/sobj.frameRate * sobj.shiftSpd;
            
            if flag_gabor ==  0
                Screen('DrawTexture', sobj.wPtr, gratingtex, [], stimRect, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
            elseif flag_gabor == 1
                %Screen('DrawTexture', sobj.wPtr, gabortex, sRect, stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, gratFreq_deg, 50, 100, 1.0, 0, 0, 0]);
                Screen('DrawTexture', sobj.wPtr, gabortex, [], stimRect, angle, [], [], [], [], kPsychDontDoRotation, [phase, cycles_per_pix, sc, contrast, 1, 0, 0, 0]);
            end
            %Add Photo Sensor (Left, Bottom)
            Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
            Screen('Flip', sobj.wPtr);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif ver == 2
            angle = 180 - sobj.angle;
            fr = cycles_per_pix * 2 * pi; %spatial frequency in radian
            fullpix = 1700; %near sqrt(1024^2 + 1280^2)
            RECTsize = ceil(fullpix/pix_per_cycle) * pix_per_cycle;
            inc = sobj.white - sobj.gray;
            
            x = meshgrid(0:RECTsize-1,1);
            grating = sobj.gray + inc * cos(fr*x);
            
            gratingtex = Screen('MakeTexture', sobj.wPtr, grating, [], 1);
            
            waitframes = 1;
            waitduration = waitframes * sobj.m_int;
            
            %grating speed
            shift_per_frame = sobj.shiftSpd * pix_per_cycle * waitduration;
            
            
            %%%%%%%%%%%%%
            % prep first frame
            % add photosensor
            Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
            % Flip and rap timer
            [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] = ...
                Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
            TriggerVSon(Testmode, dio, 1);
            
            
            vbl_end_time = sobj.vbl_2 + sobj.duration;
            xoffset = 0;
            vbl = sobj.vbl_2;
            %Move gratings
            while vbl < vbl_end_time
                %shift
                xoffset = xoffset + shift_per_frame;
                
                srcRect = [xoffset 0 xoffset + RECTsize RECTsize];
                Screen('DrawTexture', sobj.wPtr, gratingtex, srcRect, [], angle);
                
                %%
                Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
                vbl = Screen('Flip', sobj.wPtr, vbl + (waitframes-0.5)*sobj.m_int);
            end
            
            % Gray Screen
            Screen('FillRect', sobj.wPtr, sobj.gray, [0 0 sobj.RECT(3),sobj.RECT(4)]);
            Screen('Flip', sobj.wPtr);
        end
        
    end
%%
    function Movebar_stim
        % get move direction
        angle_list = sobj.concentric_angle_deg_list';
        if get(figUIobj.shiftDir, 'value') < 9
            flag_rand_dir = 3;
            angle_list = sobj.concentric_angle_deg_list(get(figUIobj.shiftDir, 'value'));
        elseif get(figUIobj.shiftDir, 'value') == 9 %ord8
            flag_rand_dir = 2;
        else %randomize
            flag_rand_dir = 1;
        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set flipnum
        flipnum = round(sobj.moveDuration/sobj.m_int);
        
        %transFactor (pix/flip)
        switch get(figUIobj.shiftDir, 'value')
            case {1, 5} %horizontal
                transFactor = round(sobj.RECT(3)/flipnum);
            case {2, 4, 6, 8, 9, 10} % diagonal
                transFactor = round((sobj.RECT(3) + sobj.RECT(4))/flipnum);
            case {3, 7} %vertical
                transFactor = round(sobj.RECT(4)/flipnum);
            case 11
                transFactor = round((sobj.RECT(3) + sobj.RECT(4)*2)/flipnum);
        end
        
        %Enable alpha blending
        Screen('BlendFunction', sobj.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        %moving direction setting
        topPriorityLevel =  MaxPriority(sobj.wPtr);
        Priority(topPriorityLevel);
        % Make base stim texture
        bar_h = ceil(sobj.RECT(4)*3);
        bar_w = sobj.stim_size(1);
        mat_bar = ones(bar_h, bar_w) * sobj.stimlumi;
        
        %%%
        [sobj.angle, sobj.angle_index] = get_condition(5, angle_list, recobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        angle = -sobj.angle;
        
        %%% initialize xy position
        x0 = 0;
        y0 = 0;
        
        %MakeTexture
        im_tex = Screen('MakeTexture', sobj.wPtr, mat_bar, angle, 4);
        
        %%% prep stim %%%
        tex_pos = zeros(flipnum, 4);
        
        
        %% 
        for i = 1:flipnum
            switch sobj.angle
                case 0 %horizontal rightward
                    xmove = x0 + i*transFactor;
                    tex_pos(i,:) = [xmove-(bar_w/2), 0, xmove+(bar_w/2), sobj.RECT(4)];
                    sRect = [1, bar_w; 1. sobj.RECT(4)];
                    
                case 180 %leftward
                    xmove = sobj.RECT(3) - i*transFactor;
                    tex_pos(i,:) = [xmove-(bar_w/2), sobj.ScrCenterY-(bar_h/2), xmove+(bar_w/2), sobj.ScrCenterY+(bar_h/2)];
                    sRect = [1, bar_w; 1. sobj.RECT(4)];
                    
                case 90 %upward
                    ymove = sobj.RECT(4) - i*transFactor;
                    tex_pos(i,:) = [sobj.ScrCenterX-(bar_w/2), ymove-(bar_h/2), sobj.ScrCenterX+(bar_w/2), ymove+(bar_h/2)];
                    sRect = [1, bar_w; 1. sobj.RECT(3)];
                    
                case 270 %downward
                    ymove = y0 + i*transFactor;
                    tex_pos(i,:) = [sobj.ScrCenterX-(bar_w/2), ymove-(bar_h/2), sobj.ScrCenterX+(bar_w/2), ymove+(bar_h/2)];
                    sRect = [1, bar_w; 1. sobj.RECT(3)];
                    
                case {45, 315, 22.5,  67.5, 292.5, 337.5} %diagonal rightward
                    xmove = -round(sobj.RECT(4)/2) + i*transFactor;
                    tex_pos(i,:) = [xmove-(bar_w/2), sobj.ScrCenterY-(bar_h/2), xmove+(bar_w/2), sobj.ScrCenterY+(bar_h/2)];
                    sRect = [1, bar_w; 1. ceil(sobj.RECT(4)*sqrt(2))];
                    
                case {112.5, 157.5, 135, 202.5, 225, 247.5} %diagonal leftward
                    xmove = sobj.RECT(3)+round(sobj.RECT(4)/2) - i*transFactor;
                    tex_pos(i,:) = [xmove-(bar_w/2), sobj.ScrCenterY-(bar_h/2), xmove+(bar_w/2), sobj.ScrCenterY+(bar_h/2)];
                    sRect = [1, bar_w; 1. ceil(sobj.RECT(4)*sqrt(2))];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Draw Screen
        Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        Screen('DrawTexture', sobj.wPtr, im_tex, sRect, tex_pos(1,:), angle)
        
        [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
        stim_monitor;
        TriggerVSon(Testmode, dio,1)
        vbl = sobj.vbl_2;
        
        for i = 2:flipnum
            Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
            Screen('DrawTexture', sobj.wPtr, im_tex, sRect, tex_pos(i,:), angle);
            vbl = Screen('Flip', sobj.wPtr, vbl+(sobj.m_int/2));
        end
        %%% stim off %%%
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] =...
            Screen('Flip', sobj.wPtr, sobj.vbl_2 + sobj.moveDuration);
        
        TriggerVSon(Testmode, dio,0)
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
        
        % Set stim center
        Set_stim_position;
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        %
        
        base_stimRect = [0, 0, sobj.stim_size];
        stimRect = CenterRectOnPointd(base_stimRect, sobj.stim_center(1), sobj.stim_center(2));
        
        Screen('DrawTexture', sobj.wPtr, imgtex, [], stimRect);
        
    end

%%
    function Mosaic_Dots
        % Set stim center
        Set_stim_position;
        
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
        
        if get(figUIobj.mode, 'value') == 4
            sobj.center_index_FineMap = 0;
        end
        
        % Set stim size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        maxDiameter = max(sobj.stim_size) * 1.01;
        % define stim position using center and size
        Rect = CenterRectOnPointd([0, 0, sobj.stim_size], sobj.stim_center(1), sobj.stim_center(2));
        
        % Set Luminance
        switch get(figUIobj.lumi, 'value')
            case 1
                flag_lumi_random = 3; %fix
            case 2
                flag_lumi_random = 1; %randomize
        end
        sobj.lumi = get_condition(3, sobj.stimlumi_list, recobj.cycleNum,...
            length(sobj.stimlumi_list), flag_lumi_random, sobj.stimlumi);
        
        sobj.stimcol = sobj.lumi * sobj.stimRGB;
        
        %PrepScreen Screen
        Screen(sobj.shape, sobj.wPtr, sobj.stimcol, Rect, maxDiameter);
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
    function Set_stim_position
        % set stim position that is defined by figUIobj.mode
        %%%%% stim center position %%%%%
        mode =  get(figUIobj.mode, 'Value');
        if mode ==  1
            %random matrix
            fix_center = [];
            f_pos_rand = 1;
            list_mat = sobj.center_pos_list;
            list_size = sobj.divnum^2;
            
        elseif mode == 2
            %orderd matrix
            fix_center = [];
            f_pos_rand = 2;
            list_mat = sobj.center_pos_list;
            list_size = sobj.divnum^2;
            
        elseif mode == 3 || mode == 4
            %concentric random or fixed center
            fix_center = sobj.center_pos_list(sobj.fixpos,:);
            f_pos_rand = 3;
            list_mat = [];
            list_size = [];
        end
        
        [sobj.stim_center, sobj.center_index] =  get_condition(1, list_mat, recobj.cycleNum,...
            list_size, f_pos_rand, fix_center);

        if mode == 3 || mode == 4
            sobj.center_index = sobj.fixpos;
        end
        
        %%%%% for concentric position %%%%%
        switch sobj.pattern
            case {'Sin', 'Rect', 'Gabor'}
                conc_dir = get(figUIobj.shiftDir2, 'Value');
            otherwise
                conc_dir = get(figUIobj.shiftDir, 'Value');
        end
        if mode ==  3
            if conc_dir ==  9 %ord8
                f_dir_rand = 2; % ord
            else
                f_dir_rand = 1; % randomize
            end
            
            [conc_pos_mat, sobj.conc_index] = get_condition(4, sobj.concentric_mat(1:end/2,:),...
                recobj.cycleNum, size(sobj.concentric_mat,1)/2, f_dir_rand);
            
            [concX, concY] = pol2cart(conc_pos_mat(2), conc_pos_mat(1));
            sobj.stim_center = [sobj.stim_center(1) + concX, sobj.stim_center(2) - concY];
        end
        
        sobj.stim_center = round(sobj.stim_center);
        
        %
    end

%%
    function [out, index] = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
        % generate list order
        % n is the number of conditions
        % 1: stimulus center
        % 2: stimulus size
        % 3: luminace
        % 4: concentric_angle & distance matrix
        % 5: grating angle
        % 6: tif images
        % 7: stimulus center for Fine Mapping
        
        persistent list_order %keep in this function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if flag_random == 3 %fixed condition
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
                    case 2 %ordered
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
        %Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
        %(Left, Bottum)
        Screen('FillRect', sobj.wPtr, 255, [0 sobj.RECT(4)-40, 40 sobj.RECT(4)]);
        %%% stim ON %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Flip and rap timer
        [sobj.vbl_2, ~, ~, ~, sobj.BeamposON] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delayPTB);% put some delay for PTB
        
        TriggerVSon(Testmode, dio, 1)
        stim_monitor;
    end

%%
    function VisStimOFF
        % Prep BacgGround Screen
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        % After sobj.duration, flib BG color
        [sobj.vbl_3, ~, ~, ~, sobj.BeamposOFF] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_2+sobj.duration);
        
        TriggerVSon(Testmode, dio, 0)
        
        %GUI stim indicater
        stim_monitor_reset;
        time1 = recobj.rect/1000 - (sobj.vbl_3 - sobj.vbl_1);
        pause_time = time1;
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
    set(figUIobj.StimMonitor3, 'String', '', 'BackGroundColor', 'k');
    set(figUIobj.StimMonitor2, 'String', 'Pre Stim', 'ForeGroundColor', 'w', 'BackGroundColor', 'k');
    set(figUIobj.StimMonitor1, 'String', '', 'BackGroundColor', 'k');
    
else % during stimulation
    switch sobj.pattern
        case 'Uni'
            bgcol = 'm';
            stim_str3 = [];

        case 'Size_rand'
            bgcol = 'y';
            stim_str3 = ['Size: ', num2str(sobj.size_deg), 'deg'];
            
        case {'2P', 'B/W'}
            bgcol = 'm';
            stim_str3 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            
        case 'Looming'
            bgcol = 'y';
            stim_str3 = ['Spd: ', num2str(sobj.loomSpd_deg), 'deg/s'];
            
        case {'Sin', 'Rect', 'Gabor'}
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle), ' deg'];
            
        case 'MoveBar'
            bgcol = 'c';
            stim_str3 = ['Dir: ', num2str(sobj.angle)];%, '/Spd: ', num2str(sobj.moveSpd_deg)];
            sobj.center_index = sobj.fixpos;
            
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
    %%% STR1: stim pattern & cycle num
    set(figUIobj.StimMonitor1, 'String', [sobj.pattern, ': #', num2str(recobj.cycleNum)], 'BackGroundColor',bgcol);
    
    %%% STR2: stim position
    switch sobj.mode
        case 'Concentric'
            stim_str2 = ['Dist:',num2str(sobj.concentric_mat_deg(sobj.conc_index,1)),...
                '/Ang:', num2str(sobj.concentric_mat_deg(sobj.conc_index,2))];
            set(figUIobj.StimMonitor2, 'String', stim_str2, 'ForeGroundColor', 'k', 'BackGroundColor', bgcol);
        otherwise
            set(figUIobj.StimMonitor2, 'String',['POS: ',num2str(sobj.center_index), '/',num2str(sobj.divnum^2)], 'ForeGroundColor', 'k', 'BackGroundColor', bgcol);
    end
    %%% STR3: stim properties
    set(figUIobj.StimMonitor3, 'String', stim_str3, 'BackGroundColor', bgcol);
end
drawnow;
%drawnow nocallbacks;
end
%%
function stim_monitor_reset
global figUIobj

set(figUIobj.StimMonitor1, 'BackGroundColor', 'w');
set(figUIobj.StimMonitor2, 'BackGroundColor', 'w');
set(figUIobj.StimMonitor3, 'BackGroundColor', 'w');
drawnow;
%drawnow nocallbacks;
end
%%