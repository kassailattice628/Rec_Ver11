function hGui = gui_window5(Testmode, Recmode, UseCam, GUI_x)
% gui_window4 creates a None But Air Graphical User Interface
% hGui = gui_window4(s, sTrig) returns a structure of graphics components
% handles (hGui) and create a GUI for PTB visual stimuli, data acquisition
% from a DAQ session (s), and control TTL output

%% call global vars
global sobj
global recobj
global s

%% %---------- Create GUI window ----------%
%open GUI window
hGui.fig = figure('Position', [GUI_x + 10, 20, 750, 750], 'Name', ['None But Air_Ver', recobj.NBAver], 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');


%% %%%%%%%%%%%%   Controler   %%%%%%%%%%%%
%Screen
hGui.ONSCR = uicontrol('Style', 'pushbutton', 'String', 'OpenScreen',...
   'Position', [5 705 80 30], 'Horizontalalignment', 'center', 'Callback', {@OpenSCR, sobj});

hGui.CLSCR = uicontrol('Style', 'pushbutton', 'String', 'CloseScreen',...
   'Position', [5 670 80 30], 'Horizontalalignment', 'center', 'Callback', {@CloseSCR, sobj});

hGui.stim = uicontrol('Style', 'togglebutton', 'String', 'Stim-OFF',...
   'Position', [110 705 100 30], 'Horizontalalignment', 'center', 'Callback', @ch_stimON);

hGui.EXIT = uicontrol('Style', 'pushbutton', 'String', 'EXIT',...
   'Position', [680 705 65 30], 'FontSize',12, 'Horizontalalignment', 'center', 'CallBack', {@quit_NBA, s, UseCam});

%Save ON/OFF
hGui.getfname = uicontrol('Style', 'pushbutton', 'String', 'File Name',...
   'Position', [365 705 80 30], 'Horizontalalignment', 'center', 'Callback', @SelectSaveFile);

hGui.showfname = uicontrol('Style', 'text', 'String', 'unset', 'Position', [455 710 120 20], 'FontSize', 13);

hGui.save = uicontrol('Style', 'togglebutton', 'String', 'Unsave',...
   'Position', [450 670 70 30], 'Callback', {@ch_save, hGui});

%Plot ON/OFF
hGui.PlotWindowON = uicontrol('Style', 'togglebutton', 'String', 'Plot ON',...
   'Position', [365 670 65 30], 'value', 1, 'BackGroundColor', 'g', 'FontSize',12,...
    'Horizontalalignment', 'center', 'CallBack', {@open_plot, hGui, Recmode, GUI_x});

%% %%%%%%%%%%%%    stim state monitor    %%%%%%%%%%%%
hGui.StimMonitor1 = uicontrol('Style', 'text', 'String', '', 'Position', [230 710 120 25], 'FontSize',13, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');
hGui.StimMonitor2 = uicontrol('Style', 'text', 'String', 'OFF', 'Position', [230 690 120 20], 'FontSize',12, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');
hGui.StimMonitor3 = uicontrol('Style', 'text', 'String', '', 'Position', [230 670 120 20], 'FontSize',12, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli1 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'Vis. Stim.1', 'FontSize', 12, 'Units', 'Pixels', 'Position', [5 10 195 650]);

%% Select stim position
uicontrol('Style', 'text', 'String', 'Position', 'Position', [10 620 90 15], 'Horizontalalignment', 'left');
hGui.mode = uicontrol('Style', 'popupmenu', 'Position', [10 600 90 20],...
    'String', [{'Rand_mat'}, {'Ord_mat'}, {'Concentric'}, {'Fix_Rep'}]);
set(hGui.mode, 'Callback', @set_fig_pos);


%% Select stim pattern
uicontrol('Style', 'text', 'String', 'Pattern', 'Position', [105 620 70 15], 'Horizontalalignment', 'left');
hGui.pattern = uicontrol('Style', 'popupmenu', 'Position', [105 600 90 20],...
    'String', [{'Uni'}, {'Size_rand'}, {'2P'}, {'B/W'}, {'Looming'}, ...
    {'Sin'}, {'Rect'}, {'Gabor'}, {'MoveBar'}, {'Images'}, {'Mosaic'},...
    {'FineMap'}]);
set(hGui.pattern, 'Callback', @change_stim_pattern2);
% New stimulus patterns will be added in the upper list
% and modify "change_stim_pattern2.m" and "visual stimulus.m".

%% Parameters
%%% Stim1 shape
uicontrol('Style', 'text', 'String', 'Stim.Shape', 'Position', [10 575 80 15], 'Horizontalalignment', 'left');
hGui.shape = uicontrol('Style', 'popupmenu', 'Position', [10 555 80 20], 'String', [{'Rect'}, {'Circle'}]);
set(hGui.shape, 'value', 2); % default: 'FillOval'

%%% the nubmer of division for concentric positions
hGui.div_zoom_txt = uicontrol('Style', 'text', 'String', 'Div', 'Position', [90 575 45 15], 'Horizontalalignment', 'left');
hGui.div_zoom = uicontrol('Style', 'edit', 'String', sobj.div_zoom, 'Position', [90 550 40 25], 'BackGroundColor', 'w');

%%% distance from the center position
hGui.dist_txt = uicontrol('Style', 'text', 'String', 'Dist', 'Position', [140 575 50 15], 'Horizontalalignment', 'left');
hGui.dist = uicontrol('Style', 'edit', 'String', sobj.dist, 'Position', [140 550 40 25], 'BackGroundColor', 'w');

%%% Luminance %%%
uicontrol('Style', 'text', 'String', 'S.Lumi', 'Position', [10 530 55 15], 'Horizontalalignment', 'left');
hGui.stimlumi = uicontrol('Style', 'edit', 'String', sobj.stimlumi, 'Position', [10 505 45 25], 'BackGroundColor', 'w');
set(hGui.stimlumi, 'Callback', @check_stim_lumi);

uicontrol('Style', 'text', 'String', 'BG.Lumi', 'Position', [65 530 45 15], 'Horizontalalignment', 'left');
hGui.bgcol = uicontrol('Style', 'edit', 'String', sobj.bgcol, 'Position', [65 505 45 25], 'BackGroundColor', 'w');
set(hGui.bgcol, 'Callback', @check_stim_lumi);

uicontrol('Style', 'text', 'String', 'Lumi', 'Position', [120 530 40 15], 'Horizontalalignment', 'left');
hGui.lumi = uicontrol('Style', 'popupmenu', 'Position', [120 510 75 20], 'String', [{'Fix'}, {'Rand'}]);

%%% RGB %%% sobj.stimRGB
uicontrol('Style', 'text', 'String', 'S.RGB', 'Position', [120,480,70,15], 'Horizontalalignment', 'left');
hGui.stimRGB = uicontrol('Style', 'popupmenu', 'Position', [120,455,70,25], 'String', [{'BW'}, {'Blu'}, {'Gre'}, {'Yel'}, {'Red'}]);
set(hGui.stimRGB, 'Callback', @get_stimRGB);

%%% Durtion
uicontrol('Style', 'text', 'String', 'S.Duration', 'Position', [10 480 80 15], 'Horizontalalignment', 'left');
hGui.flipNum = uicontrol('Style', 'edit', 'String', sobj.flipNum, 'Position', [10 455 30 25], 'BackGroundColor', 'w');
set(hGui.flipNum, 'Callback', @check_stim_duration);

sobj.duration = sobj.flipNum*sobj.m_int;
hGui.stimDur = uicontrol('Style', 'text', 'Position', [45 455 75 15],...
    'String', ['flips=',num2str(floor(sobj.duration*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Delay Frames
uicontrol('Style', 'text', 'String', 'PTB delay flip', 'Position', [10 430 75 15], 'Horizontalalignment', 'left');
hGui.delayPTBflip = uicontrol('Style', 'edit', 'Position', [10 405 30 25], 'String', sobj.delayPTBflip, 'BackGroundColor', 'w');
set(hGui.delayPTBflip, 'Callback', @check_stim_duration);

sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
hGui.delayPTB = uicontrol('Style', 'text', 'Position', [45 405 75 15],...
    'String', ['flips=',num2str(floor(sobj.delayPTB*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Blank Frames
uicontrol('Style', 'text', 'String', 'Set Blank', 'Position', [10 380 70 15], 'Horizontalalignment', 'left');
hGui.prestimN = uicontrol('Style', 'edit', 'String', recobj.prestim, 'Position', [10 355 30 25], 'BackGroundColor', 'w');
set(hGui.prestimN, 'Callback', @check_stim_duration);

hGui.prestim = uicontrol('Style', 'text', 'Position', [45 355 100 15],...
    'String', ['loops=',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)), 'sec'], 'Horizontalalignment', 'left');

%%% Size
uicontrol('Style', 'text', 'String', 'Size (Diamiter)', 'Position', [10 330 130 15], 'Horizontalalignment', 'left');
hGui.size = uicontrol('Style', 'edit', 'String', 1, 'Position', [10 305 50 25], 'BackGroundColor', 'w');
uicontrol('Style', 'text', 'String', 'deg', 'Position', [65 305 30 15], 'Horizontalalignment', 'left');

%%% Auto-Fill
hGui.auto_size = uicontrol('Style', 'togglebutton', 'String', 'Auto OFF', 'Position', [105 300 70 30], 'Horizontalalignment', 'center');
set(hGui.auto_size, 'Callback', {@autosizing, hGui});

%%% Center/Position
uicontrol('Style', 'text', 'String', 'Monitor Div.', 'Position', [10 280 70 15], 'Horizontalalignment', 'left');
hGui.divnum = uicontrol('Style', 'edit', 'String', sobj.divnum, 'Position', [10 255 50 25], 'BackGroundColor', 'w');
set(hGui.divnum, 'Callback', {@reload_params, Testmode, Recmode, 0});

hGui.divnumN = uicontrol('Style', 'text', 'Position', [65 255 70 15],...
    'String', ['(' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'], 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'String', 'Fixed Pos.', 'Position', [10 230 70 15], 'Horizontalalignment', 'left');
hGui.fixpos = uicontrol('Style', 'edit', 'String', sobj.fixpos, 'Position', [10 205 50 25], 'BackGroundColor', 'w');
set(hGui.fixpos, 'Callback', {@reload_params, Testmode, Recmode, 0});

hGui.fixposN = uicontrol('Style', 'text', 'Position', [65 205 70 15],...
    'String', ['(in' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'], 'Horizontalalignment', 'left');

%%% Get fine position
hGui.get_fine_pos = uicontrol('Style', 'togglebutton', 'String', 'get Pos', 'Position', [130 250 60 30], 'Horizontalalignment', 'center');
set(hGui.get_fine_pos, 'Callback', {@get_fine_pos, hGui, GUI_x});

%%% The number of Image stimli
hGui.ImageNum_txt = uicontrol('Style', 'text', 'String', '# of Imgs', 'Position', [10 180 60 15], 'HorizontalAlignment', 'left');
hGui.ImageNum = uicontrol('Style', 'edit', 'String', sobj.ImageNum, 'Position', [10 155 40 25], 'BackGroundColor', 'w');

%%% Mosaic Dot Density
hGui.dots_density_txt = uicontrol('Style', 'text', 'String', 'Density', 'Position', [10 180 50 15], 'HorizontalAlignment', 'left');
hGui.dots_density = uicontrol('Style', 'edit', 'String', sobj.dots_density, 'Position', [10 155 30 25], 'BackGroundColor', 'w');
set(hGui.dots_density, 'Callback', {@check_mosaic, hGui});
hGui.dots_density_txt2 = uicontrol('Style', 'text', 'String', '%', 'Position', [40 155 20 15], 'HorizontalAlignment', 'left');

%%% Direction for grating stimulis or concentirc positions
hGui.shiftDir_txt = uicontrol('Style', 'text', 'Position', [10 180 180 15], 'String', 'Direction (0 => right)', 'Horizontalalignment', 'left');
hGui.shiftDir = uicontrol('Style', 'popupmenu', 'Position', [10 155 90 25],...
    'String', [{'0'}, {'45'}, {'90'}, {'135'}, {'180'}, {'225'}, {'270'}, {'315'}, {'Ord8'}, {'Rand8'}, {'Rand16'}]);
hGui.shiftDir_txt2 = uicontrol('Style', 'text', 'String', 'deg', 'Position', [100 160 25 15], 'Horizontalalignment', 'left');

%%% Temporal Frequecy for grating stimuli
hGui.shiftSpd_txt = uicontrol('Style', 'text', 'String', 'Tempo Freq', 'Position', [10 135 80 15], 'Horizontalalignment', 'left');
hGui.shiftSpd = uicontrol('Style', 'popupmenu', 'Position', [10 110 70 25],...
    'String', [{'0.5'}, {'1'}, {'2'}, {'4'}, {'8'}], 'value',3, 'BackGroundColor', 'w');
hGui.shiftSpd_txt2 = uicontrol('Style', 'text', 'String', 'Hz', 'Position', [75 115 20 15], 'Horizontalalignment', 'left');

%%% Spatial Frequency for grating stimuli
hGui.gratFreq_txt = uicontrol('Style', 'text', 'String', 'Spatial Freq', 'Position', [10 90 75 15], 'Horizontalalignment', 'left');
hGui.gratFreq = uicontrol('Style', 'popupmenu', 'Position', [10 65 100 25],...
    'String', [{'0.01'}, {'0.02'}, {'0.04'}, {'0.08'}, {'0.16'}, {'0.32'}], 'value',4, 'BackGroundColor', 'w');
hGui.gratFreq_txt2 = uicontrol('Style', 'text', 'String', 'cycle/deg', 'Position', [110 70 60 15], 'Horizontalalignment', 'left');

%%% Looming Speed/MoveBar Speed
hGui.loomSpd_txt = uicontrol('Style', 'text', 'String', 'Loom Spd/Size', 'Position', [10 135 100 15], 'Horizontalalignment', 'left');
hGui.loomSpd = uicontrol('Style', 'popupmenu', 'Position', [10, 110, 70, 25],...
    'String', [{'5'}, {'10'}, {'20'}, {'40'}, {'80'}, {'160'}]);
set(hGui.loomSpd, 'Callback', @change_moving_params);
hGui.loomSpd_txt2 = uicontrol('Style', 'text', 'String', 'deg/s', 'Position', [80 110 35 15], 'Horizontalalignment', 'left');

% Looming Max Size
hGui.loomSize_txt = uicontrol('Style', 'text', 'String', 'Max Size', 'Position', [125 135 100 15], 'Horizontalalignment', 'left');
hGui.loomSize = uicontrol('Style', 'edit', 'String', sobj.looming_Size, 'Position', [125 110 30 25], 'BackGroundColor', 'w');
set(hGui.loomSize, 'Callback',  @change_moving_params);
hGui.loomSize_txt2 = uicontrol('Style', 'text', 'String', 'deg', 'Position', [160 110 35 15], 'Horizontalalignment', 'left');

%%
%%% Distance b/w the LCD monitor and eye
uicontrol('Style', 'text', 'String', 'Monior Dist.', 'Position', [10 45 70 15], 'Horizontalalignment', 'left');
hGui.MonitorDist = uicontrol('Style', 'edit', 'String', sobj.MonitorDist, 'Position', [10 20 50 25], 'BackGroundColor', 'y');
uicontrol('Style', 'text', 'String', 'mm', 'Position', [65 20 30 15], 'Horizontalalignment', 'left');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli2 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.s2_panel = uipanel('Title', 'Vis. Stim.2', 'FontSize',12, 'Units', 'Pixels', 'Position', [205 240 195 420]);

uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'Stim.Shape2', 'Position', [10 380 80 15], 'Horizontalalignment', 'left');
hGui.shape2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'popupmenu', 'Position', [5 360 90 20], 'String', [{'Rect'}, {'Circle'}]);
set(hGui.shape2, 'value', 2);

%%% Luminace
uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'Stim.Lumi2', 'Position', [10 335 60 15], 'Horizontalalignment', 'left');
hGui.stimlumi2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'edit', 'String', sobj.stimlumi2, 'Position', [10 310 50 25], 'BackGroundColor', 'w');
set(hGui.stimlumi2, 'Callback', @check_stim_lumi);

%%% Duration
uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'Stim.Duration2', 'Position', [10 285 85 15], 'Horizontalalignment', 'left');
hGui.flipNum2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'edit', 'String', sobj.flipNum2, 'Position', [10 260 30 25], 'BackGroundColor', 'w');
set(hGui.flipNum2, 'Callback', @check_stim_duration);
sobj.duration2 = sobj.flipNum2*sobj.m_int;
hGui.stimDur2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'Position', [45 260 75 15],...
    'String', ['flips=',num2str(floor(sobj.duration2*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Delay flip
uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'PTB delay flip2', 'Position', [10 235 85 15], 'Horizontalalignment', 'left');
hGui.delayPTBflip2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'edit', 'String', sobj.delayPTBflip2, 'Position', [10 210 30 25], 'BackGroundColor', 'w');
set(hGui.delayPTBflip2, 'Callback', @check_stim_duration);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
hGui.delayPTB2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'Position', [45 210 75 15],...
    'String', ['flips=',num2str(floor(sobj.delayPTB2*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Size
uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'Stim.Size2 (Diamiter)', 'Position', [10 185 130 15], 'Horizontalalignment', 'left');
hGui.size2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'edit', 'String', 1, 'Position', [10 160 50 25], 'BackGroundColor', 'w');
uicontrol('Parent', hGui.s2_panel, 'Style', 'text', 'String', 'deg', 'Position', [65 1560 25 15], 'Horizontalalignment', 'left');

%%% Stim2 condition matching to Stim1
hGui.matchS1S2 = uicontrol('Parent', hGui.s2_panel, 'Style', 'pushbutton', 'String', 'Match S2 & S1', 'Position', [100, 355, 90, 30], 'Horizontalalignment', 'center');
set(hGui.matchS1S2, 'Callback', {@match_stim2cond, hGui})


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Electrophysiology %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'Rec Setting', 'FontSize', 12, 'Units', 'Pixels', 'Position', [405 350 340 310]);
%%
uicontrol('Style', 'text', 'String', 'Samp.Freq', 'Position', [410 625 60 15], 'Horizontalalignment', 'left');
hGui.sampf = uicontrol('Style', 'edit', 'String', recobj.sampf/1000, 'Position', [410 600 50 25], 'BackGroundColor', 'g');
uicontrol('Style', 'text', 'String', 'kHz', 'Position', [465 600 25 15], 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'String', 'Rec.Time', 'Position', [495 625 50 15], 'Horizontalalignment', 'left');
hGui.rect = uicontrol('Style', 'edit', 'String', recobj.rect, 'Position', [495 600 50 25], 'BackGroundColor', 'g');
set(hGui.rect, 'Callback', {@check_duration, Recmode});
uicontrol('Style', 'text', 'String', 'ms', 'Position', [550 600 20 15], 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'String', 'Loop Interval', 'Position', [580 625 80 15], 'Horizontalalignment', 'left');
hGui.interval = uicontrol('Style', 'edit', 'String', recobj.interval, 'Position', [580 600 50 25], 'BackGroundColor', 'g');
set(hGui.interval, 'Callback', @check_stim_duration);
uicontrol('Style', 'text', 'String', 'sec', 'Position', [635 600 25 15], 'Horizontalalignment', 'left');


if Recmode == 2
    uicontrol('Style', 'text', 'Position', [540 580 80 15], 'String', 'V range (mV)')
    hGui.VYmin = uicontrol('Style', 'edit', 'Position', [540 555 40 25], 'String', -100, 'BackGroundColor', 'w');
    hGui.VYmax = uicontrol('Style', 'edit', 'Position', [590 555 40 25], 'String', 30, 'BackGroundColor', 'w');
    
    uicontrol('Style', 'text', 'Position', [635 580 80 15], 'String', 'C range (nA)')
    hGui.CYmin = uicontrol('Style', 'edit', 'Position', [635 555 40 25], 'String', -5, 'BackGroundColor', 'w');
    hGui.CYmax = uicontrol('Style', 'edit', 'Position', [680 555 40 25], 'String', 3, 'BackGroundColor', 'w');
    
    %% pulse %%%
    %Duration
    uicontrol('Style', 'text', 'Position', [485 530 60 15], 'String', 'Duration', 'Horizontalalignment', 'left');
    hGui.pulseDuration = uicontrol('Style', 'edit', 'Position', [485 505 40 25],...
        'String', recobj.pulseDuration, 'Callback', @check_pulse_duration, 'BackGroundColor', 'w');
    uicontrol('Style', 'text', 'Position', [525 505 25 15], 'String', 'sec', 'Horizontalalignment', 'left');
    
    %Delay
    uicontrol('Style', 'text', 'Position', [555 530 60 15], 'String', 'Delay', 'Horizontalalignment', 'left');
    hGui.pulseDelay = uicontrol('Style', 'edit', 'Position', [555 505 40 25],...
        'String', recobj.pulseDelay, 'Callback', @check_pulse_duration, 'BackGroundColor', 'w');
    uicontrol('Style', 'text', 'Position', [595 505 25 15], 'String', 'sec', 'Horizontalalignment', 'left');
    
    %Amplitude
    uicontrol('Style', 'text', 'Position', [625 530 60 15], 'String', 'Amp.', 'Horizontalalignment', 'left');
    hGui.pulseAmp = uicontrol('Style', 'edit', 'Position', [625 505 40 25], 'String', recobj.pulseAmp, 'BackGroundColor', 'w');
    set(hGui.pulseAmp, 'Callback', @check_pulse_Amp);
    hGui.ampunit = uicontrol('Style', 'text', 'Position', [665 505 25 15], 'String', 'nA', 'Horizontalalignment', 'left');
    
    %Step
    uicontrol('Style', 'text', 'Position', [450 485 30 15], 'String', 'start', 'Horizontalalignment', 'left');
    uicontrol('Style', 'text', 'Position', [485 485 30 15], 'String', 'end', 'Horizontalalignment', 'left');
    uicontrol('Style', 'text', 'Position', [520 485 30 15], 'String', 'step', 'Horizontalalignment', 'left');
    
    %for Current Clamp
    uicontrol('Style', 'text', 'Position', [410 460 40 15], 'String', 'C (nA)', 'Horizontalalignment', 'left');
    hGui.Cstart = uicontrol('Style', 'edit', 'Position', [450 460 30 25], 'String', recobj.stepCV(1,1), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Cend = uicontrol('Style', 'edit', 'Position', [485 460 30 25], 'String', recobj.stepCV(1,2), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Cstep = uicontrol('Style', 'edit', 'Position', [520 460 30 25], 'String', recobj.stepCV(1,3), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    
    %for Voltage Clamp
    uicontrol('Style', 'text', 'Position', [410 430 40 15], 'String', 'V (mV)', 'Horizontalalignment', 'left');
    hGui.Vstart = uicontrol('Style', 'edit', 'Position', [450 430 30 25], 'String', recobj.stepCV(2,1), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Vend = uicontrol('Style', 'edit', 'Position', [485 430 30 25], 'String', recobj.stepCV(2,2), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Vstep = uicontrol('Style', 'edit', 'Position', [520 430 30 25], 'String', recobj.stepCV(2,3), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    
    hGui.stepf = uicontrol('Style', 'togglebutton', 'Position', [555 455 40 30], 'String', 'step', 'Callback', @change_plot);
    hGui.pulse = uicontrol('Style', 'togglebutton', 'Position', [410 505 70 30], 'String', 'Pulse ON', 'Callback', @change_plot);
    
    % preset_Testpulse Amplitude
    uicontrol('Style', 'text', 'Position', [695 530 40 15], 'String', 'Preset', 'Horizontalalignment', 'left');
    hGui.presetAmp = uicontrol('Style', 'togglebutton', 'Position', [690 505 50 25], 'String', '10 mV');
    set(hGui.presetAmp, 'Callback', @preset_pulseAmp);
    
    % DAQ range:: TTL3 out put is 5V, iRecHS2 is +-10 V input.
    %{
        uicontrol('Style', 'text', 'Position', [410 405 80 15], 'String', 'Daq Range (V)', 'Horizontalalignment', 'left');
        hGui.DAQrange = uicontrol('Style', 'popupmenu', 'Position', [410 380 160 25], ....
            'String', [{'x1: [-10,10]'}, {'x10: [-1,1]'}, {'x50: [-0.2,0.2]'}, {'x100: [-0.1,0.1]'}], 'value',1);
        set(hGui.DAQrange, 'Callback', @ch_DaqRange);
    %}
    
    % select plot channel %%
    uicontrol('Style', 'text', 'Position', [410 580 55 15], 'String', 'Plot Type ', 'Horizontalalignment', 'left');
    hGui.plot = uicontrol('Style', 'togglebutton', 'Position', [410 550 60 30], 'String', 'V-plot', 'ForegroundColor', 'white', 'BackGroundColor', 'b');
    set(hGui.plot, 'Callback', @change_plot);
    
    uicontrol('Style', 'text', 'Position', [475 580 55 15], 'String', 'Y-axis', 'Horizontalalignment', 'left');
    hGui.yaxis = uicontrol('Style', 'togglebutton', 'Position', [475 550 60 30], 'value', 0, 'String', [{'Auto'}, {'Fix'}]);
    set(hGui.yaxis, 'Callback', @ch_yaxis);
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Imaq Camera     %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title', 'CAM Setting', 'FontSize', 12, 'Units', 'Pixels', 'Position', [405 10 340 330]);
switch UseCam
    case 0
        uicontrol('Style', 'text', 'Position', [410 290 200 30],...
            'String', 'Imaq Camera is not used.', 'FontSize', 12);
    case 1
        hGui.setCam = uicontrol('Style', 'togglebutton', 'Position', [410 290 50 30],...
            'String', 'ON', 'Callback', {@ch_ButtonColor, 'g'},'FontSize', 13);
        
        hGui.imaqPrev = uicontrol('Style', 'togglebutton', 'Position', [470 290 100 30],...
            'String', 'Preview', 'Callback', @Cam_Preview,'FontSize', 13);
        
        %hGui.saveCam = uicontrol('Style', 'togglebutton', 'Position', [410 250 120 30],...
        %   'String', 'Disk', 'Callback', {@ch_saveCam}, 'FontSize', 13);
        
        
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   TTL out DIO3    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'TTL3', 'FontSize', 12, 'Units', 'Pixels', 'Position', [205 10 195 230]);
%% DIO3 (outer TTL);
uicontrol('Style', 'text', 'Position', [210 165 60 15], 'String', 'Delay', 'Horizontalalignment', 'left');
hGui.delayTTL3 = uicontrol('Style', 'edit', 'Position', [210,140,40,25], 'String', recobj.TTL3.delay*1000, 'BackGroundColor', 'w');
set(hGui.delayTTL3, 'Callback', @setTTL3);
uicontrol('Style', 'text', 'Position', [250 140 20 15], 'String', 'ms', 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'Position', [285 165 60 15], 'String', 'Duration', 'Horizontalalignment', 'left');
hGui.durationTTL3 = uicontrol('Style', 'text', 'Position', [285,140,60,15], 'String', recobj.TTL3.duration*1000);
set(hGui.durationTTL3, 'Callback', @setTTL3);
uicontrol('Style', 'text', 'Position', [345 140 20 15], 'String', 'ms', 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'Position', [210 120 60 15], 'String', 'Freq.', 'Horizontalalignment', 'left');
hGui.freqTTL3 = uicontrol('Style', 'edit', 'Position', [210 95 40 25], 'String', recobj.TTL3.Freq, 'BackGroundColor', 'w');
set(hGui.freqTTL3, 'Callback', @setTTL3);
uicontrol('Style', 'text', 'Position', [250 95 20 15], 'String', 'Hz', 'Horizontalalignment', 'left');

uicontrol('Style', 'text', 'Position', [285 120 60 15], 'String', 'PulseNum', 'Horizontalalignment', 'left');
hGui.pulsenumTTL3 = uicontrol('Style', 'edit', 'Position', [285 95 60 25], 'String', recobj.TTL3.PulseNum, 'BackGroundColor', 'w');
set(hGui.pulsenumTTL3, 'Callback', @setTTL3);

uicontrol('Style', 'text', 'Position', [210 75 60 15], 'String', 'DutyCycle', 'Horizontalalignment', 'left');
hGui.dutycycleTTL3 = uicontrol('Style', 'edit', 'Position', [210 50 40 25], 'String', recobj.TTL3.DutyCycle, 'BackGroundColor', 'w');
set(hGui.dutycycleTTL3, 'Callback', @setTTL3);

uicontrol('Style', 'text', 'Position', [285 75 100 15], 'String', 'Single Pulse Width', 'Horizontalalignment', 'left');
hGui.widthTTL3 = uicontrol('Style', 'text', 'Position', [285 50 40 15], 'String', recobj.TTL3.DutyCycle/recobj.TTL3.Freq*1000, 'Horizontalalignment', 'center');
uicontrol('Style', 'text', 'Position', [325 50 20 15], 'String', 'ms', 'Horizontalalignment', 'left');

hGui.TTL3 = uicontrol('Style', 'togglebutton', 'Position', [210 185 65 30], 'String', 'TTL-OFF', 'Horizontalalignment', 'center');
set(hGui.TTL3, 'Callback', {@TTL3, Testmode})

hGui.TTL3_select = uicontrol('Style', 'togglebutton', 'Position', [285 185 90 30], 'String', 'Fix:Duration', 'Horizontalalignment', 'center');
set(hGui.TTL3_select, 'Callback', {@TTL3_select, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   Loop Start Button   %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main_loopingtest
hGui.loop = uicontrol('Style', 'togglebutton', 'Position', [110 670 100 30],...
    'String', 'Loop-OFF', 'Callback', {@main_loop, hGui, Testmode, Recmode}, 'BackGroundColor', 'r');

%%

end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% sub functions for Callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback fucntions need at lest 2 parameters.
% other input parameters are used after 2nd var.
% function func_name(hObject, Callbackdata, usr1, usr2, ...)

%%
function OpenSCR(~, ~, sobj)
[sobj.wPtr, ~] = Screen('OpenWindow', sobj.ScrNum, sobj.bgcol);
end

%%
function CloseSCR(~, ~, sobj)
global flag
flag.start = 1;
Screen('Close', sobj.wPtr);
end

%%
function ch_stimON(hObject,~)
switch get(hObject, 'value')
    case 1
        set(hObject, 'String', 'Stim-ON');
    case 0
        set(hObject, 'String', 'Stim-OFF');
end
ch_ButtonColor(hObject, [], 'y');

end

%%
function quit_NBA(~, ~, s, UseCam)
global sobj
global dev
global plotUIobj
global getfineUIobj
global imaq

delete(s)

if UseCam==1
    if exist('imaq' ,'var')
        delete(imaq.vid)
        clear imaq
    end
end

if isempty(dev)
else
    daq.reset;
end

if sobj.ScrNum ~= 0
    sca;
end

%clear windows, variables
if isstruct(plotUIobj)
    if isfield(plotUIobj, 'fig')
        close(plotUIobj.fig)
    end
end

if isstruct(getfineUIobj)
    if isfield(getfineUIobj, 'fig')
        close(getfineUIobj.fig)
    end
end
sca;
close all hidden;

end

%%
function open_plot(hObject, ~, hGui, Recmode, GUI_x)
global plotUIobj

if get(hObject, 'value')
    plotUIobj = open_plot_window(hGui, Recmode, GUI_x);
    disp('open plot window')
else
    if isfield(plotUIobj, 'fig')
        close(plotUIobj.fig)
        clearvars -global plotUIobj
    end
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function get_fine_pos(hObject, ~, hGui, GUI_x)
global getfineUIobj
global sobj

if strcmp(sobj.pattern, '1P_Conc') || strcmp(sobj.pattern, 'FineMap')
    if get(hObject, 'value')
        getfineUIobj = open_get_fine_pos(hGui, GUI_x);
        disp('get fine pos from concentric grid');
    else
        if isfield(getfineUIobj, 'fig')
            close(getfineUIobj.fig)
            clearvars -global getfineUIobj
        end
    end
else
    if isfield(getfineUIobj, 'fig')
        close(getfineUIobj.fig)
        clearvars -global getfineUIobj
    end
    set(hObject, 'value', 0)
end

ch_ButtonColor(hObject, [], 'g')
end

%%
function set_fig_pos(hObject, ~)
global sobj
global figUIobj

if get(hObject, 'value') == 2
    set(figUIobj.fixpos, 'BackGroundColor', 'g');
else
    switch sobj.pattern
        case {'FineMap'}
            set(figUIobj.fixpos, 'BackGroundColor', 'g');
        otherwise
            set(figUIobj.fixpos, 'BackGroundColor', 'w');
    end
end
end

%%
function get_stimRGB(hObject,~)
global sobj

% [{'BW'}, {'Blu'}, {'Gre'}, {'Yel'}, {'Red'}];
switch get(hObject, 'value')
    case 1
        sobj.stimRGB = [1,1,1];
    case 2
        sobj.stimRGB = [0,0,1];
    case 3
        sobj.stimRGB = [0,1,0];
    case 4
        sobj.stimRGB = [1,1,0];
    case 5
        sobj.stimRGB = [1,0,0];
end
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
end

%%
function autosizing(hObject, ~, hGui)
%automatically set stimulus size to one division
global sobj

if get(hObject, 'value')==1
    set(hObject, 'String', 'Auto FILL');
    Rx = floor((sobj.RECT(3)/sobj.divnum));
    Ry = floor((sobj.RECT(4)/sobj.divnum));
    sobj.stimsz = [Rx,Ry];
    stimsz_deg = round(Pix2Deg([sobj.stimsz], sobj.MonitorDist));
    set(hGui.size, 'String', [num2str(stimsz_deg(1)), ' x ', num2str(stimsz_deg(2))]);
    
elseif get(hObject, 'value')==0
    set(hObject, 'String', 'Auto OFF');
    % seg to 1 deg
    sobj.stimsz = round(ones(1,2)*Deg2Pix(1, sobj.MonitorDist, sobj.pixpitch));
    set(hGui.size, 'String', 1);
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function check_mosaic(hObject, ~, hGui)
global sobj
%the number of dots is zero, use default settings.
div_zoom = str2double(get(hGui.div_zoom, 'String'));
dist = str2double(get(hGui.dist, 'String'));
step = dist/div_zoom;
total_dots = length(-(dist-1)/2:step:(dist-1)/2);
select_dots = round(total_dots * str2double(get(hObject, 'String'))/100);

if strcmp(sobj.pattern, 'Mosaic') && select_dots == 0
    errordlg('the number of dots is less than 1');
    set(hGui.div_zoom, 'String', 5);
    set(hGui.dist, 'String', 15);
    set(hObject, 'String', 30);
end
end

%%
function match_stim2cond(hObject, ~, hGui)
global sobj
if get(hObject, 'value')==1
    %Stim.Shape2
    set(hGui.shape2, 'value', get(hGui.shape, 'value'));
    sobj.shape2 = sobj.shapelist{get(hGui.shape2, 'value'),1};
    
    %Stim.Lumi2
    set(hGui.stimlumi2, 'String', get(hGui.stimlumi, 'String'));
    sobj.stimlumi2 = str2double(get(hGui.stimlumi2, 'String'));
    
    %Stim.Duration2
    set(hGui.flipNum2, 'String',get(hGui.flipNum, 'String'));
    sobj.flipNum2 = str2double(get(hGui.flipNum2, 'String'));
    sobj.duration2 = sobj.flipNum2*sobj.m_int;
    set(hGui.stimDur2, 'String', ['flips=',num2str(floor(sobj.duration2*1000)), 'ms']);
    
    %PTB delay2
    set(hGui.delayPTBflip2, 'String', get(hGui.delayPTBflip, 'String'));
    sobj.delayPTBflip2 = str2double(get(hGui.delayPTBflip2, 'String'));
    sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
    set(hGui.delayPTB2, 'String', ['flips=',num2str(floor(sobj.delayPTB2*1000)), 'ms']);
    
    
    %Stim.Size2
    set(hGui.size2, 'String', get(hGui.size, 'String'));
    sobj.stimsz2 = sobj.stimsz;
end
end

%%
%{
function ch_DaqRange(hObject, ~)
global InCh
i = get(hObject, 'value');

Ranges = [-10,10;-1,1;-0.2,0.2;-0.1,0.1];
InCh(1).Range = Ranges(i,:);
InCh(2).Range = Ranges(i,:);
InCh(3).Range = [-10 10];
end
%}

%%
function TTL3(hObject, ~, Testmode)
if Testmode == 0
    switch get(hObject, 'value')
        case 1
            set(hObject, 'String', 'TTL-ON');
        case 0
            set(hObject, 'String', 'TTL-OFF');
    end
end

ch_ButtonColor(hObject, [], 'g')
setTTL3;
end

%%
function TTL3_select(hObject, ~, hGui)
switch get(hObject, 'value')
    case 0
        set(hObject, 'String', 'Fix:Duration');
        set(hGui.durationTTL3, 'Style', 'text', 'Position', [285,140,60,15], 'BackGroundColor', [0.9400 0.9400 0.9400])
        set(hGui.pulsenumTTL3, 'Style', 'edit', 'Position', [285 95 60 25], 'BackGroundColor', 'w')
    case 1
        set(hObject, 'String', 'Fix:PulseNum');
        set(hGui.durationTTL3, 'Style', 'edit', 'Position', [285,140,60,25], 'BackGroundColor', 'w')
        set(hGui.pulsenumTTL3, 'Style', 'text', 'Position', [285 95 60 15], 'BackGroundColor', [0.9400 0.9400 0.9400])
end
end

%%
function ch_yaxis(hObject, ~)
global figUIobj
global plotUIobj

switch get(hObject, 'value')
    case 0
        set(hObject, 'String', 'Auto');
        set(plotUIobj.axes1, 'YlimMode', 'Auto');
        set(figUIobj.VYmax, 'BackGroundColor', 'w')
        set(figUIobj.VYmin, 'BackGroundColor', 'w')
        set(figUIobj.CYmax, 'BackGroundColor', 'w')
        set(figUIobj.CYmin, 'BackGroundColor', 'w')
    case 1
        set(hObject, 'String', 'Fix');
        set(plotUIobj.axes1, 'YlimMode', 'Manual');
        switch get(figUIobj.plot, 'value')
            case 0 %Vplot
                set(plotUIobj.axes1, 'Ylim', [str2double(get(figUIobj.VYmin, 'String')),str2double(get(figUIobj.VYmax, 'String'))]);
                set(figUIobj.VYmax, 'BackGroundColor', 'g')
                set(figUIobj.VYmin, 'BackGroundColor', 'g')
                set(figUIobj.CYmax, 'BackGroundColor', 'w')
                set(figUIobj.CYmin, 'BackGroundColor', 'w')
            case 1 %Iplot
                set(plotUIobj.axes1, 'Ylim', [str2double(get(figUIobj.CYmin, 'String')),str2double(get(figUIobj.CYmax, 'String'))]);
                set(figUIobj.VYmax, 'BackGroundColor', 'w')
                set(figUIobj.VYmin, 'BackGroundColor', 'w')
                set(figUIobj.CYmax, 'BackGroundColor', 'g')
                set(figUIobj.CYmin, 'BackGroundColor', 'g')
        end
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function preset_pulseAmp(hObject, ~)
global recobj
global figUIobj

switch get(figUIobj.plot, 'value')
    case 0 %Vplot::preset 1 nA
        switch get(hObject, 'value')
            case 1
                set(figUIobj.pulseAmp, 'String', '1')
                recobj.pulseAmp = 1;
            case 0
        end
    case 1%Iplot
        switch get(hObject, 'value')
            case 1
                set(figUIobj.pulseAmp, 'String', '10')
                recobj.pulseAmp = 10;
        end
        
end
end

%%
function check_duration(~, ~, Recmode)

check_stim_duration([], []);
if Recmode == 2
    check_pulse_duration([], []);
end
end

%%
function Cam_Preview(hObject, ~)
global prevobj
if get(hObject, 'value')
    prevobj = open_prev_window(hObject);
    disp('open preview')
else
    if isfield(prevobj, 'fig')
        close(prevobj.fig)
        clearvars -global prevobj
    end
end
ch_ButtonColor(hObject, [], 'g')
end

%%
%{
function ch_saveCam(hObject, ~)
global recobj
global imaq
if get(hObject, 'value')
    set(hObject ,'String', 'memory');
    imaq = imaq_ini(recobj, 1);
elseif get(hObject, 'value')==0
    set(hObject ,'String', 'disk');
    imaq = imaq_ini(recobj, 0);
end
end
%}

%%%%%%%%%%%%% save setting %%%%%%%%%%%%%%
%%
function SelectSaveFile(~, ~)
global recobj

if isfield(recobj, 'dirname') == 0 % 1st time to define filename
    [recobj.fname, recobj.dirname] = uiputfile('*.mat');
else %open the same folder when any foder was selected previously.
    if recobj.dirname == 0
        recobj.dirname = pwd;
    else
        [recobj.fname, recobj.dirname] = uiputfile('*.mat', 'Select File to Write', recobj.dirname);
    end
end
end

%%
function ch_save(hObject, ~, hGui)
global recobj

switch get(hObject, 'value')
    case 1 %saving
        set(hObject, 'String', 'Saving')
        
        if isfield(recobj, 'fname') && ischar(recobj.fname)
        else
            SelectSaveFile;
        end
        
        [~, fname, ext] = fileparts([recobj.dirname, recobj.fname]);
        
        e_fname = dir([recobj.dirname, fname, '_*.mat']);
        
        if size(e_fname, 1) == 0
            recobj.savecount = 1;
        else
            ind = zeros(1, size(e_fname, 1));
            for n = 1:size(e_fname ,1)
                %[startIndex, ~] = regexp(e_fname(n).name, '\d');
                %ind(n) = str2double(e_fname(n).name(startIndex));
                [startIndex2, ~] = regexp(e_fname(n).name, '_');
                ind(n) = str2double(e_fname(n).name(startIndex2+1:end-4));
            end
            recobj.savecount = max(ind) + 1;
        end
        
        recobj.savefilename  = [recobj.dirname, fname, '_', num2str(recobj.savecount), ext];
        set(hGui.showfname, 'String', [fname, '_', num2str(recobj.savecount), ext]);
        disp(['Save as :: ', recobj.savefilename]);
        
    case 0 %unsave
        set(hObject, 'String', 'Unsave')
        set(hGui.showfname, 'String', 'unset');
end

ch_ButtonColor(hObject, [], 'g');
end

%%
function ch_ButtonColor(hObject, ~, col)
switch get(hObject, 'Value')
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor', [0.9400 0.9400 0.9400])
    case 1%
        set(hObject, 'BackgroundColor',col)
end
end
