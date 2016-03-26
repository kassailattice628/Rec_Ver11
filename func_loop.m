function func_loop(hObject, ~, hGui, Testmode)
% Loop start and stop

global recobj
global sobj
global s
global dio
%global DataSave %save
%global ParamsSave %save
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
        
        if Testmode == 1 && recobj.cycleNum == 10;
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
    disp('1st Trig')
else
    recobj.tRec = toc(recobj.STARTloop);
    generate_trigger([1,0]);
    disp('Trig')
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
    Trigger(Testmode, dio)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prep stimulation
    disp(sobj.pattern)
    
    % Set stim params
    switch sobj.pattern
        case 'Uni'
            Uni_stim(2);
            
        case 'Size_rand'
            Uni_stim(1);
            
        case '1P_Conc'
            Conc_1P;
        case '2P_Conc'
            Conc_2P;
            
        case {'B/W'}
            
        case {'Sin', 'Rect', 'Gabor'}
        case 'Images'
    end
    
    %AddPhoto Sensor (Left, UP in the monitor) for the stimulus timing check
    Screen('FillRect', sobj.wPtr, 255, [0 0 40 40]);
    
    % Flip and rap timer
    [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
        Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
    
    sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
    disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
    stim_monitor;
    
    % Prep Stim OFF
    Screen('FillRect', sobj.wPtr, sobj.bgcol);
    % After sobj.duration, flib BG color
    [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = ...
        Screen('Flip', sobj.wPtr, sobj.vbl_2+sobj.duration);
    sobj.sFlipTimeStamp_3 = toc(recobj.STARTloop);
    
    %GUI stim indicater
    stim_monitor_reset;
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
        
        % define stim position using center and size
        Rect = set_Rect(stim_center, stim_size);
        
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
        Screen(sobj.shape, sobj.wPtr, lumi, Rect);
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
        
        % define stim position using center and size
        Rect = set_Rect(stim_center, stim_size);
        
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
        Screen(sobj.shape, sobj.wPtr, lumi, Rect);
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
        
        stim_size2 = get_condition(2, sobj.size_pix_list, recobj.cycleNum,...
            length(sobj.size_pix_list), 2, sobj.stimsz2);
        
        % define stim position using center and size
        Rect = set_Rect(stim_center, stim_size);
        Rect2 = set_Rect(stim_center2, stim_size2);
        
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
        Screen(sobj.shape, sobj.wPtr, lumi, Rect);
        Screen(sobj.shape, sobj.wPtr, lumi, Rect2);
    end


%%

    function out = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
        % generate list order
        % n is the number of conditions
        % 1: stimulus center, 2: stimulus size, 3: luminace
        % 4: concentric_angle & distance matrix
        
        persistent list_order %keep in this function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if flag_random == 2 %fixed condition
            %list_order{n} = fix * ones(1,list_size);
            out = fix;
        else
            if cycleNum == 1 && n == 1
                list_order = cell(5,1); %とりあえず リストセット５個をloop中にkeep
            end
            i_in_cycle = mod(cycleNum, list_size);
            if i_in_cycle == 0
                i_in_cycle = list_size;
                disp(i_in_cycle)
                

            elseif i_in_cycle == 1 %Reset list order
                switch flag_random
                    case 1 %randomize
                        list_order{n} = randperm(list_size);
                    case 3 %ordered
                        list_order{n} = 1:list_size;
                end
            end
            out = list_mat(list_order{n}(i_in_cycle),:);
        end
    end

%%
    function Rect = set_Rect(stim_center, stim_size)
        %[left, top, right, bottom]
        Left = floor(stim_center(:,1) - stim_size(1)/2);
        Top = floor(stim_center(:,2) - stim_size(2)/2);
        Right = floor(stim_center(:,1) + stim_size(1)/2);
        Bottom = floor(stim_center(:,2) + stim_size(2)/2);
        
        Rect = [Left, Top, Right, Bottom];% position と size を確定
    end

%%
%{
function Stim_Presentation
        %Stim ON
        [sobj.vbl_2, sobj.OnsetTime_2, sobj.FlipTimeStamp_2] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_1+sobj.delayPTB);% put some delay for PTB
        
        sobj.sFlipTimeStamp_2=toc(recobj.STARTloop);
        disp(['AITrig; ',sobj.pattern, ': #', num2str(recobj.cycleNum)]);
        stim_monitor;
        
        % Prep Stim OFF
        Screen('FillRect', sobj.wPtr, sobj.bgcol);
        % After sobj.duration, flib BG color
        [sobj.vbl_3, sobj.OnsetTime_3, sobj.FlipTimeStamp_3] = ...
            Screen('Flip', sobj.wPtr, sobj.vbl_2+sobj.duration);
        sobj.sFlipTimeStamp_3 = toc(recobj.STARTloop);
        
        %GUI stim indicater
        stim_monitor_reset;
        
    end
%}


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