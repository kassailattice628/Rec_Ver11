function hGui = gui_window4(Testmode, Recmode, UseCam, GUI_x)
% gui_window3 creates a None But Air Graphical User Interface
% hGui = gui_window3(s, sTrig) returns a structure of graphics components
% handles (hGui) and create a GUI for PTB visual stimuli, data acquisition
% from a DAQ session (s), and control TTL output

%% call global vars
global sobj
global recobj
global s

%% %---------- Create GUI window ----------%
%open GUI window
hGui.fig = figure('Position', [GUI_x + 10, 20, 750, 750], 'Name', ['None But Air_Ver', recobj.NBAver], 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

%GUI components
hGui.ONSCR = uicontrol('style', 'pushbutton', 'string', 'OpenScreen', 'position', [5 705 80 30], 'Horizontalalignment', 'center');
set(hGui.ONSCR, 'Callback', {@OpenSCR, sobj});

hGui.CLSCR = uicontrol('style', 'pushbutton', 'string', 'CloseScreen', 'position', [5 670 80 30], 'Horizontalalignment', 'center');
set(hGui.CLSCR, 'Callback', {@CloseSCR, sobj});

hGui.stim = uicontrol('style', 'togglebutton', 'string', 'Stim-OFF', 'position', [110 705 100 30], 'Horizontalalignment', 'center');
set(hGui.stim, 'Callback', @ch_stimON);

hGui.EXIT = uicontrol('style', 'pushbutton', 'string', 'EXIT', 'position', [680 705 65 30], 'FontSize',12, 'Horizontalalignment', 'center');
set(hGui.EXIT, 'CallBack', {@quit_NBA, s, UseCam});

%% save %%
hGui.getfname = uicontrol('style', 'pushbutton', 'string', 'File Name', 'position', [365 705 80 30], 'Callback', @SelectSaveFile, 'Horizontalalignment', 'center');

hGui.showfname = uicontrol('style', 'text', 'string', 'unset', 'position', [455 710 120 20], 'FontSize', 13);% , 'BackGroundColor', 'w');

hGui.save = uicontrol('style', 'togglebutton', 'string', 'Unsave', 'position', [450 670 70 30], 'Callback', {@ch_save, hGui});

%% plot %%
hGui.PlotWindowON = uicontrol('style', 'togglebutton', 'string', 'Plot ON', 'position', [365 670 65 30],...
    'value', 1, 'BackGroundColor', 'g', 'FontSize',12, 'Horizontalalignment', 'center');
set(hGui.PlotWindowON, 'CallBack', {@open_plot, hGui, Recmode, GUI_x});

%% stim state monitor% %%
hGui.StimMonitor1 = uicontrol('style', 'text', 'string', '', 'position', [230 710 120 25], 'FontSize',13, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');
hGui.StimMonitor2 = uicontrol('style', 'text', 'string', 'OFF', 'position', [230 690 120 20], 'FontSize',12, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');
hGui.StimMonitor3 = uicontrol('style', 'text', 'string', '', 'position', [230 670 120 20], 'FontSize',12, 'BackGroundColor', 'w', 'Horizontalalignment', 'center');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli1 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'Vis. Stim.1', 'FontSize', 12, 'Units', 'Pixels', 'Position', [5 10 195 650]);

%% Select stim position
uicontrol('style', 'text', 'string', 'Mode (Position)', 'position', [10 620 90 15], 'Horizontalalignment', 'left');
hGui.mode = uicontrol('style', 'popupmenu', 'position', [10 600 90 20], 'string', [{'Random'}, {'Fix_Rep'}, {'Ordered'}]);
set(hGui.mode, 'Callback', @set_fig_pos);

%% Select pattern
uicontrol('style', 'text', 'string', 'Stim.Pattern', 'position', [105 620 70 15], 'Horizontalalignment', 'left');
hGui.pattern = uicontrol('style', 'popupmenu', 'position', [105 600 90 20],...
    'string', [{'Uni'}, {'Size_rand'}, {'1P_Conc'}, {'2P_Conc'}, {'B/W'},...
    {'Looming'}, {'Sin'}, {'Rect'}, {'Gabor'}, {'Images'}, {'Mosaic'}, {'FineMap'}]);
set(hGui.pattern, 'Callback', @change_stim_pattern);
% New stimulus patterns will be added this list and, change stim_pattern and "visual stimulus.m".

%%
%%% Stim1 shape
uicontrol('style', 'text', 'string', 'Stim.Shape', 'position', [10 575 60 15], 'Horizontalalignment', 'left');
hGui.shape = uicontrol('style', 'popupmenu', 'position', [10 555 75 20], 'string', [{'Rect'}, {'Circle'}]);
set(hGui.shape, 'value', 2); % default: 'FillOval'

%%% the nubmer of division for concentric positions
uicontrol('style', 'text', 'string', 'Division', 'position', [90 575 45 15], 'Horizontalalignment', 'left');
hGui.div_zoom = uicontrol('style', 'edit', 'string', sobj.div_zoom, 'position', [90 550 40 25], 'BackGroundColor', 'w');

%%% distance from the center position
uicontrol('style', 'text', 'string', 'Dist(deg)', 'position', [140 575 50 15], 'Horizontalalignment', 'left');
hGui.dist = uicontrol('style', 'edit', 'string', sobj.dist, 'position', [140 550 40 25], 'BackGroundColor', 'w');

%%% Luminance %%%
uicontrol('style', 'text', 'string', 'Stim.Lumi', 'position', [10 530 55 15], 'Horizontalalignment', 'left');
hGui.stimlumi = uicontrol('style', 'edit', 'string', sobj.stimlumi, 'position', [10 505 45 25], 'BackGroundColor', 'w');
set(hGui.stimlumi, 'Callback', @check_stim_lumi);

uicontrol('style', 'text', 'string', 'BG.Lumi', 'position', [65 530 45 15], 'Horizontalalignment', 'left');
hGui.bgcol = uicontrol('style', 'edit', 'string', sobj.bgcol, 'position', [65 505 45 25], 'BackGroundColor', 'w');
set(hGui.bgcol, 'Callback', @check_stim_lumi);

uicontrol('style', 'text', 'string', 'Lumi', 'position', [120 530 40 15], 'Horizontalalignment', 'left');
hGui.lumi = uicontrol('style', 'popupmenu', 'position', [120 510 75 20], 'string', [{'Fix'}, {'Rand'}]);

%%% RGB %%% sobj.stimRGB
uicontrol('style', 'text', 'string', 'Stim.RGB', 'position', [120,480,70,15], 'Horizontalalignment', 'left');
hGui.stimRGB = uicontrol('style', 'popupmenu', 'position', [120,455,70,25], 'string', [{'BW'}, {'Blu'}, {'Gre'}, {'Yel'}, {'Red'}]);
set(hGui.stimRGB, 'Callback', @get_stimRGB);

%%% Durtion
uicontrol('style', 'text', 'string', 'Stim.Duration', 'position', [10 480 80 15], 'Horizontalalignment', 'left');
hGui.flipNum = uicontrol('style', 'edit', 'string', sobj.flipNum, 'position', [10 455 30 25], 'BackGroundColor', 'w');
set(hGui.flipNum, 'Callback', @check_stim_duration);

sobj.duration = sobj.flipNum*sobj.m_int;
hGui.stimDur = uicontrol('style', 'text', 'position', [45 455 75 15],...
    'string', ['flips=',num2str(floor(sobj.duration*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Delay Frames
uicontrol('style', 'text', 'string', 'PTB delay flip', 'position', [10 430 75 15], 'Horizontalalignment', 'left');
hGui.delayPTBflip = uicontrol('style', 'edit', 'position', [10 405 30 25], 'string', sobj.delayPTBflip, 'BackGroundColor', 'w');
set(hGui.delayPTBflip, 'Callback', @check_stim_duration);

sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
hGui.delayPTB = uicontrol('style', 'text', 'position', [45 405 75 15],...
    'string', ['flips=',num2str(floor(sobj.delayPTB*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Blank Frames
uicontrol('style', 'text', 'string', 'Set Blank', 'position', [10 380 70 15], 'Horizontalalignment', 'left');
hGui.prestimN = uicontrol('style', 'edit', 'string', recobj.prestim, 'position', [10 355 30 25], 'BackGroundColor', 'w');
set(hGui.prestimN, 'Callback', {@reload_params, Testmode, Recmode, 0});

hGui.prestim = uicontrol('style', 'text', 'position', [45 355 100 15],...
    'string', ['loops=',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)), 'sec'], 'Horizontalalignment', 'left');

%%% The number of Image stimli
uicontrol('style', 'text', 'string', '# of Imgs', 'position', [130 430 60 15], 'HorizontalAlignment', 'left');
hGui.ImageNum = uicontrol('style', 'edit', 'string', sobj.ImageNum, 'position', [140 405 40 25], 'BackGroundColor', 'w');

%%% Mosaic Dot Density
uicontrol('style', 'text', 'string', 'Density', 'position', [140 380 50 15], 'HorizontalAlignment', 'left');
hGui.dots_density = uicontrol('style', 'edit', 'string', sobj.dots_density, 'position', [145 355 30 25], 'BackGroundColor', 'w');
set(hGui.dots_density, 'Callback', {@check_mosaic, hGui});
uicontrol('style', 'text', 'string', '%', 'position', [175 355 20 15], 'HorizontalAlignment', 'left');

%%% Size
uicontrol('style', 'text', 'string', 'Size (Diamiter)', 'position', [10 330 130 15], 'Horizontalalignment', 'left');
hGui.size = uicontrol('style', 'edit', 'string', 1, 'position', [10 305 50 25], 'BackGroundColor', 'w');
uicontrol('style', 'text', 'string', 'deg', 'position', [65 305 30 15], 'Horizontalalignment', 'left');
% Auto-Fill
hGui.auto_size = uicontrol('style', 'togglebutton', 'string', 'Auto OFF', 'position', [105 300 70 30], 'Horizontalalignment', 'center');
set(hGui.auto_size, 'Callback', {@autosizing, hGui});

%%% Center/Position
uicontrol('style', 'text', 'string', 'Monitor Div.', 'position', [10 280 70 15], 'Horizontalalignment', 'left');
hGui.divnum = uicontrol('style', 'edit', 'string', sobj.divnum, 'position', [10 255 50 25], 'BackGroundColor', 'w');
set(hGui.divnum, 'Callback', {@reload_params, Testmode, Recmode, 0});

hGui.divnumN = uicontrol('style', 'text', 'position', [65 255 70 15],...
    'string', ['(' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'], 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'string', 'Fixed Pos.', 'position', [10 230 70 15], 'Horizontalalignment', 'left');
hGui.fixpos = uicontrol('style', 'edit', 'string', sobj.fixpos, 'position', [10 205 50 25], 'BackGroundColor', 'w');
set(hGui.fixpos, 'Callback', {@reload_params, Testmode, Recmode, 0});

hGui.fixposN = uicontrol('style', 'text', 'position', [65 205 70 15],...
    'string', ['(in' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'], 'Horizontalalignment', 'left');

%%% Get fine position
hGui.get_fine_pos = uicontrol('style', 'togglebutton', 'string', 'get Pos', 'position', [130 250 60 30], 'Horizontalalignment', 'center');
set(hGui.get_fine_pos, 'Callback', {@get_fine_pos, hGui});

%%% Direction for grating stimulis or concentirc positions
uicontrol('style', 'text', 'position', [10 180 180 15], 'string', 'Direction (Grating, Concentric)', 'Horizontalalignment', 'left');
hGui.shiftDir = uicontrol('style', 'popupmenu', 'position', [10 155 90 25],...
    'string', [{'0'}, {'45'}, {'90'}, {'135'}, {'180'}, {'225'}, {'270'}, {'315'}, {'Order8'}, {'Rand8'}, {'Rand16'}]);

uicontrol('style', 'text', 'string', 'deg', 'position', [100 160 25 15], 'Horizontalalignment', 'left');

%%% Temporal Frequecy for grating stimuli
uicontrol('style', 'text', 'string', 'Tempo Freq', 'position', [10 135 80 15], 'Horizontalalignment', 'left');
hGui.shiftSpd = uicontrol('style', 'popupmenu', 'position', [10 110 70 25],...
    'string', [{'0.5'}, {'1'}, {'2'}, {'4'}, {'8'}], 'value',3, 'BackGroundColor', 'w');

uicontrol('style', 'text', 'string', 'Hz', 'position', [75 115 20 15], 'Horizontalalignment', 'left');

%%% Spatial Frequency for grating stimuli
uicontrol('style', 'text', 'string', 'Spatial Freq', 'position', [10 90 75 15], 'Horizontalalignment', 'left');
hGui.gratFreq = uicontrol('style', 'popupmenu', 'position', [10 65 100 25],...
    'string', [{'0.01'}, {'0.02'}, {'0.04'}, {'0.08'}, {'0.16'}, {'0.32'}], 'value',4, 'BackGroundColor', 'w');

uicontrol('style', 'text', 'string', 'cycle/deg', 'position', [110 70 60 15], 'Horizontalalignment', 'left');

%%% Looming Speed
uicontrol('style', 'text', 'string', 'Loom Spd/Size', 'position', [95 140 100 15], 'Horizontalalignment', 'left');
hGui.loomSpd = uicontrol('style', 'popupmenu', 'position', [95, 115, 70, 25],...
    'string', [{'5'}, {'10'}, {'20'}, {'40'}, {'80'}, {'160'}]);
set(hGui.loomSpd, 'Callback', @change_looming_params);
uicontrol('style', 'text', 'string', 'deg/s', 'position', [160 120 35 15], 'Horizontalalignment', 'left');

% Looming Max Size
hGui.loomSize = uicontrol('style', 'edit', 'string', sobj.looming_Size, 'position', [125 90 30 25], 'BackGroundColor', 'w');
set(hGui.loomSize, 'Callback',  @change_looming_params);
uicontrol('style', 'text', 'string', 'deg', 'position', [160 90 35 15], 'Horizontalalignment', 'left');

%%% Distance b/w the LCD monitor and eye
uicontrol('style', 'text', 'string', 'Monior Dist.', 'position', [10 45 70 15], 'Horizontalalignment', 'left');
hGui.MonitorDist = uicontrol('style', 'edit', 'string', sobj.MonitorDist, 'position', [10 20 50 25], 'BackGroundColor', 'y');
uicontrol('style', 'text', 'string', 'mm', 'position', [65 20 30 15], 'Horizontalalignment', 'left');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli2 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title', 'Vis. Stim.2', 'FontSize',12, 'Units', 'Pixels', 'Position', [205 240 195 420]);

uicontrol('style', 'text', 'string', 'Stim.Shape2', 'position', [210 620 70 15], 'Horizontalalignment', 'left');
hGui.shape2 = uicontrol('style', 'popupmenu', 'position', [210 600 85 20], 'string', [{'Rect'}, {'Circle'}]);
set(hGui.shape2, 'value', 2);

%%% Luminace
uicontrol('style', 'text', 'string', 'Stim.Lumi2', 'position', [210 575 60 15], 'Horizontalalignment', 'left');
hGui.stimlumi2 = uicontrol('style', 'edit', 'string', sobj.stimlumi2, 'position', [210 550 50 25], 'BackGroundColor', 'w');
set(hGui.stimlumi2, 'Callback', @check_stim_lumi);

%%% Duration
uicontrol('style', 'text', 'string', 'Stim.Duration2', 'position', [210 525 85 15], 'Horizontalalignment', 'left');
hGui.flipNum2 = uicontrol('style', 'edit', 'string', sobj.flipNum2, 'position', [210 500 30 25], 'BackGroundColor', 'w');
set(hGui.flipNum2, 'Callback', @check_stim_duration);

sobj.duration2 = sobj.flipNum2*sobj.m_int;
hGui.stimDur2 = uicontrol('style', 'text', 'position', [245 500 75 15],...
    'string', ['flips=',num2str(floor(sobj.duration2*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Delay flip
uicontrol('style', 'text', 'string', 'PTB delay flip2', 'position', [210 475 85 15], 'Horizontalalignment', 'left');
hGui.delayPTBflip2 = uicontrol('style', 'edit', 'string', sobj.delayPTBflip2, 'position', [210 450 30 25], 'BackGroundColor', 'w');
set(hGui.delayPTBflip2, 'Callback', @check_stim_duration);

sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
hGui.delayPTB2 = uicontrol('style', 'text', 'position', [245 450 75 15],...
    'string', ['flips=',num2str(floor(sobj.delayPTB2*1000)), 'ms'], 'Horizontalalignment', 'left');

%%% Size
uicontrol('style', 'text', 'string', 'Stim.Size2 (Diamiter)', 'position', [210 425 130 15], 'Horizontalalignment', 'left');
hGui.size2 = uicontrol('style', 'edit', 'string', 1, 'position', [210 400 50 25], 'BackGroundColor', 'w');
uicontrol('style', 'text', 'string', 'deg', 'position', [265 400 25 15], 'Horizontalalignment', 'left');

%%% Stim2 condition matching to Stim1
hGui.matchS1S2 = uicontrol('style', 'pushbutton', 'string', 'Match S2 & S1', 'position', [300,595 95, 30], 'Horizontalalignment', 'center');
set(hGui.matchS1S2, 'Callback', {@match_stim2cond, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Electrophysiology %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'Rec Setting', 'FontSize', 12, 'Units', 'Pixels', 'Position', [405 350 340 310]);
%%
uicontrol('style', 'text', 'string', 'Samp.Freq', 'position', [410 625 60 15], 'Horizontalalignment', 'left');
hGui.sampf = uicontrol('style', 'edit', 'string', recobj.sampf/1000, 'position', [410 600 50 25], 'BackGroundColor', 'g');
uicontrol('style', 'text', 'string', 'kHz', 'position', [465 600 25 15], 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'string', 'Rec.Time', 'position', [495 625 50 15], 'Horizontalalignment', 'left');
hGui.rect = uicontrol('style', 'edit', 'string', recobj.rect, 'position', [495 600 50 25], 'BackGroundColor', 'g');
set(hGui.rect, 'Callback', {@check_duration, Recmode});
uicontrol('style', 'text', 'string', 'ms', 'position', [550 600 20 15], 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'string', 'Loop Interval', 'position', [580 625 80 15], 'Horizontalalignment', 'left');
hGui.interval = uicontrol('style', 'edit', 'string', recobj.interval, 'position', [580 600 50 25], 'BackGroundColor', 'g');
uicontrol('style', 'text', 'string', 'sec', 'position', [635 600 25 15], 'Horizontalalignment', 'left');


if Recmode == 2
    uicontrol('style', 'text', 'position', [540 580 80 15], 'string', 'V range (mV)')
    hGui.VYmin = uicontrol('style', 'edit', 'position', [540 555 40 25], 'string', -100, 'BackGroundColor', 'w');
    hGui.VYmax = uicontrol('style', 'edit', 'position', [590 555 40 25], 'string', 30, 'BackGroundColor', 'w');
    
    uicontrol('style', 'text', 'position', [635 580 80 15], 'string', 'C range (nA)')
    hGui.CYmin = uicontrol('style', 'edit', 'position', [635 555 40 25], 'string', -5, 'BackGroundColor', 'w');
    hGui.CYmax = uicontrol('style', 'edit', 'position', [680 555 40 25], 'string', 3, 'BackGroundColor', 'w');
    
    %% pulse %%%
    %Duration
    uicontrol('style', 'text', 'position', [485 530 60 15], 'string', 'Duration', 'Horizontalalignment', 'left');
    hGui.pulseDuration = uicontrol('style', 'edit', 'position', [485 505 40 25],...
        'string', recobj.pulseDuration, 'Callback', @check_pulse_duration, 'BackGroundColor', 'w');
    uicontrol('style', 'text', 'position', [525 505 25 15], 'string', 'sec', 'Horizontalalignment', 'left');
    
    %Delay
    uicontrol('style', 'text', 'position', [555 530 60 15], 'string', 'Delay', 'Horizontalalignment', 'left');
    hGui.pulseDelay = uicontrol('style', 'edit', 'position', [555 505 40 25],...
        'string', recobj.pulseDelay, 'Callback', @check_pulse_duration, 'BackGroundColor', 'w');
    uicontrol('style', 'text', 'position', [595 505 25 15], 'string', 'sec', 'Horizontalalignment', 'left');
    
    %Amplitude
    uicontrol('style', 'text', 'position', [625 530 60 15], 'string', 'Amp.', 'Horizontalalignment', 'left');
    hGui.pulseAmp = uicontrol('style', 'edit', 'position', [625 505 40 25], 'string', recobj.pulseAmp, 'BackGroundColor', 'w');
    set(hGui.pulseAmp, 'Callback', @check_pulse_Amp);
    hGui.ampunit = uicontrol('style', 'text', 'position', [665 505 25 15], 'string', 'nA', 'Horizontalalignment', 'left');
    
    %Step
    uicontrol('style', 'text', 'position', [450 485 30 15], 'string', 'start', 'Horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [485 485 30 15], 'string', 'end', 'Horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [520 485 30 15], 'string', 'step', 'Horizontalalignment', 'left');
    
    %for Current Clamp
    uicontrol('style', 'text', 'position', [410 460 40 15], 'string', 'C (nA)', 'Horizontalalignment', 'left');
    hGui.Cstart = uicontrol('style', 'edit', 'position', [450 460 30 25], 'string', recobj.stepCV(1,1), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Cend = uicontrol('style', 'edit', 'position', [485 460 30 25], 'string', recobj.stepCV(1,2), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Cstep = uicontrol('style', 'edit', 'position', [520 460 30 25], 'string', recobj.stepCV(1,3), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    
    %for Voltage Clamp
    uicontrol('style', 'text', 'position', [410 430 40 15], 'string', 'V (mV)', 'Horizontalalignment', 'left');
    hGui.Vstart = uicontrol('style', 'edit', 'position', [450 430 30 25], 'string', recobj.stepCV(2,1), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Vend = uicontrol('style', 'edit', 'position', [485 430 30 25], 'string', recobj.stepCV(2,2), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    hGui.Vstep = uicontrol('style', 'edit', 'position', [520 430 30 25], 'string', recobj.stepCV(2,3), 'Callback', @check_pulse_Amp, 'BackGroundColor', 'w');
    
    hGui.stepf = uicontrol('style', 'togglebutton', 'position', [555 455 40 30], 'string', 'step', 'Callback', @change_plot);
    hGui.pulse = uicontrol('style', 'togglebutton', 'position', [410 505 70 30], 'string', 'Pulse ON', 'Callback', @change_plot);
    
    % preset_Testpulse Amplitude
    uicontrol('style', 'text', 'position', [695 530 40 15], 'string', 'Preset', 'Horizontalalignment', 'left');
    hGui.presetAmp = uicontrol('style', 'togglebutton', 'position', [690 505 50 25], 'string', '10 mV');
    set(hGui.presetAmp, 'Callback', @preset_pulseAmp);
    
    % DAQ range:: TTL3 out put is 5V, iRecHS2 is +-10 V input.
    %{
        uicontrol('style', 'text', 'position', [410 405 80 15], 'string', 'Daq Range (V)', 'Horizontalalignment', 'left');
        hGui.DAQrange = uicontrol('style', 'popupmenu', 'position', [410 380 160 25], ....
            'string', [{'x1: [-10,10]'}, {'x10: [-1,1]'}, {'x50: [-0.2,0.2]'}, {'x100: [-0.1,0.1]'}], 'value',1);
        set(hGui.DAQrange, 'Callback', @ch_DaqRange);
    %}
    
    % select plot channel %%
    uicontrol('style', 'text', 'position', [410 580 55 15], 'string', 'Plot Type ', 'Horizontalalignment', 'left');
    hGui.plot = uicontrol('style', 'togglebutton', 'position', [410 550 60 30], 'string', 'V-plot', 'ForegroundColor', 'white', 'BackGroundColor', 'b');
    set(hGui.plot, 'Callback', @change_plot);
    
    uicontrol('style', 'text', 'position', [475 580 55 15], 'string', 'Y-axis', 'Horizontalalignment', 'left');
    hGui.yaxis = uicontrol('style', 'togglebutton', 'position', [475 550 60 30], 'value', 0, 'string', [{'Auto'}, {'Fix'}]);
    set(hGui.yaxis, 'Callback', @ch_yaxis);
    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Imaq Camera     %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'CAM Setting', 'FontSize', 12, 'Units', 'Pixels', 'Position', [405 10 340 330]);
switch UseCam
    case 0
        uicontrol('style', 'text', 'position', [410 290 200 30],...
            'string', 'Imaq Camera is not used.', 'FontSize', 12);
    case 1
        hGui.setCam = uicontrol('style', 'togglebutton', 'position', [410 290 50 30],...
            'string', 'ON', 'Callback', {@ch_ButtonColor, 'g'},'FontSize', 13);
        
        hGui.imaqPrev = uicontrol('style', 'togglebutton', 'position', [470 290 100 30],...
            'string', 'Preview', 'Callback', @Cam_Preview,'FontSize', 13);
        
        
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   TTL out DIO3    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title', 'TTL3', 'FontSize', 12, 'Units', 'Pixels', 'Position', [205 10 195 230]);
%% DIO3 (outer TTL);
uicontrol('style', 'text', 'position', [210 165 60 15], 'string', 'Delay', 'Horizontalalignment', 'left');
hGui.delayTTL3 = uicontrol('style', 'edit', 'position', [210,140,40,25], 'string', recobj.TTL3.delay*1000, 'BackGroundColor', 'w');
set(hGui.delayTTL3, 'Callback', @setTTL3);
uicontrol('style', 'text', 'position', [250 140 20 15], 'string', 'ms', 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'position', [285 165 60 15], 'string', 'Duration', 'Horizontalalignment', 'left');
hGui.durationTTL3 = uicontrol('style', 'text', 'position', [285,140,60,15], 'string', recobj.TTL3.duration*1000);
set(hGui.durationTTL3, 'Callback', @setTTL3);
uicontrol('style', 'text', 'position', [345 140 20 15], 'string', 'ms', 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'position', [210 120 60 15], 'string', 'Freq.', 'Horizontalalignment', 'left');
hGui.freqTTL3 = uicontrol('style', 'edit', 'position', [210 95 40 25], 'string', recobj.TTL3.Freq, 'BackGroundColor', 'w');
set(hGui.freqTTL3, 'Callback', @setTTL3);
uicontrol('style', 'text', 'position', [250 95 20 15], 'string', 'Hz', 'Horizontalalignment', 'left');

uicontrol('style', 'text', 'position', [285 120 60 15], 'string', 'PulseNum', 'Horizontalalignment', 'left');
hGui.pulsenumTTL3 = uicontrol('style', 'edit', 'position', [285 95 60 25], 'string', recobj.TTL3.PulseNum, 'BackGroundColor', 'w');
set(hGui.pulsenumTTL3, 'Callback', @setTTL3);

uicontrol('style', 'text', 'position', [210 75 60 15], 'string', 'DutyCycle', 'Horizontalalignment', 'left');
hGui.dutycycleTTL3 = uicontrol('style', 'edit', 'position', [210 50 40 25], 'string', recobj.TTL3.DutyCycle, 'BackGroundColor', 'w');
set(hGui.dutycycleTTL3, 'Callback', @setTTL3);

uicontrol('style', 'text', 'position', [285 75 100 15], 'string', 'Single Pulse Width', 'Horizontalalignment', 'left');
hGui.widthTTL3 = uicontrol('style', 'text', 'position', [285 50 40 15], 'string', recobj.TTL3.DutyCycle/recobj.TTL3.Freq*1000, 'Horizontalalignment', 'center');
uicontrol('style', 'text', 'position', [325 50 20 15], 'string', 'ms', 'Horizontalalignment', 'left');

hGui.TTL3 = uicontrol('style', 'togglebutton', 'position', [210 185 65 30], 'string', 'TTL-OFF', 'Horizontalalignment', 'center');
set(hGui.TTL3, 'Callback', {@TTL3, Testmode})

hGui.TTL3_select = uicontrol('style', 'togglebutton', 'position', [285 185 90 30], 'string', 'Fix:Duration', 'Horizontalalignment', 'center');
set(hGui.TTL3_select, 'Callback', {@TTL3_select, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   Loop Start Button   %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main_loopingtest
hGui.loop = uicontrol('style', 'togglebutton', 'position', [110 670 100 30],...
    'string', 'Loop-OFF', 'Callback', {@main_loop, hGui, Testmode, Recmode}, 'BackGroundColor', 'r');

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
        set(hObject, 'string', 'Stim-ON');
    case 0
        set(hObject, 'string', 'Stim-OFF');
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
    if isrunning(imaq.vid)
        stop(imaq.vid)
    end
    delete(imaq.vid)
    clear imaq
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
function get_fine_pos(hObject, ~, hGui)
global getfineUIobj
global sobj

if strcmp(sobj.pattern, '1P_Conc') || strcmp(sobj.pattern, 'FineMap')
    if get(hObject, 'value')
        getfineUIobj = open_get_fine_pos(hGui);
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
    set(hObject, 'string', 'Auto FILL');
    Rx = floor((sobj.RECT(3)/sobj.divnum));
    Ry = floor((sobj.RECT(4)/sobj.divnum));
    sobj.stimsz = [Rx,Ry];
    stimsz_deg = round(Pix2Deg([sobj.stimsz], sobj.MonitorDist));
    set(hGui.size, 'string', [num2str(stimsz_deg(1)), ' x ', num2str(stimsz_deg(2))]);
    
elseif get(hObject, 'value')==0
    set(hObject, 'string', 'Auto OFF');
    % seg to 1 deg
    sobj.stimsz = round(ones(1,2)*Deg2Pix(1, sobj.MonitorDist, sobj.pixpitch));
    set(hGui.size, 'string', 1);
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function check_mosaic(hObject, ~, hGui)
global sobj
%the number of dots is zero, use default settings.
div_zoom = str2double(get(hGui.div_zoom, 'string'));
dist = str2double(get(hGui.dist, 'string'));
step = dist/div_zoom;
total_dots = length(-(dist-1)/2:step:(dist-1)/2);
select_dots = round(total_dots * str2double(get(hObject, 'string'))/100);

if strcmp(sobj.pattern, 'Mosaic') && select_dots == 0
    errordlg('the number of dots is less than 1');
    set(hGui.div_zoom, 'string', 5);
    set(hGui.dist, 'string', 15);
    set(hObject, 'string', 30);
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
    set(hGui.stimlumi2, 'string', get(hGui.stimlumi, 'string'));
    sobj.stimlumi2 = str2double(get(hGui.stimlumi2, 'string'));
    
    %Stim.Duration2
    set(hGui.flipNum2, 'string',get(hGui.flipNum, 'string'));
    sobj.flipNum2 = str2double(get(hGui.flipNum2, 'string'));
    sobj.duration2 = sobj.flipNum2*sobj.m_int;
    set(hGui.stimDur2, 'string', ['flips=',num2str(floor(sobj.duration2*1000)), 'ms']);
    
    %PTB delay2
    set(hGui.delayPTBflip2, 'string', get(hGui.delayPTBflip, 'string'));
    sobj.delayPTBflip2 = str2double(get(hGui.delayPTBflip2, 'string'));
    sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
    set(hGui.delayPTB2, 'string', ['flips=',num2str(floor(sobj.delayPTB2*1000)), 'ms']);
    
    
    %Stim.Size2
    set(hGui.size2, 'string', get(hGui.size, 'string'));
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
            set(hObject, 'string', 'TTL-ON');
        case 0
            set(hObject, 'string', 'TTL-OFF');
    end
end

ch_ButtonColor(hObject, [], 'g')
setTTL3;
end

%%
function TTL3_select(hObject, ~, hGui)
switch get(hObject, 'value')
    case 0
        set(hObject, 'string', 'Fix:Duration');
        set(hGui.durationTTL3, 'style', 'text', 'position', [285,140,60,15], 'BackGroundColor', [0.9400 0.9400 0.9400])
        set(hGui.pulsenumTTL3, 'style', 'edit', 'position', [285 95 60 25], 'BackGroundColor', 'w')
    case 1
        set(hObject, 'string', 'Fix:PulseNum');
        set(hGui.durationTTL3, 'style', 'edit', 'position', [285,140,60,25], 'BackGroundColor', 'w')
        set(hGui.pulsenumTTL3, 'style', 'text', 'position', [285 95 60 15], 'BackGroundColor', [0.9400 0.9400 0.9400])
end
end

%%
function ch_yaxis(hObject, ~)
global figUIobj
global plotUIobj

switch get(hObject, 'value')
    case 0
        set(hObject, 'string', 'Auto');
        set(plotUIobj.axes1, 'YlimMode', 'Auto');
        set(figUIobj.VYmax, 'BackGroundColor', 'w')
        set(figUIobj.VYmin, 'BackGroundColor', 'w')
        set(figUIobj.CYmax, 'BackGroundColor', 'w')
        set(figUIobj.CYmin, 'BackGroundColor', 'w')
    case 1
        set(hObject, 'string', 'Fix');
        set(plotUIobj.axes1, 'YlimMode', 'Manual');
        switch get(figUIobj.plot, 'value')
            case 0 %Vplot
                set(plotUIobj.axes1, 'Ylim', [str2double(get(figUIobj.VYmin, 'string')),str2double(get(figUIobj.VYmax, 'string'))]);
                set(figUIobj.VYmax, 'BackGroundColor', 'g')
                set(figUIobj.VYmin, 'BackGroundColor', 'g')
                set(figUIobj.CYmax, 'BackGroundColor', 'w')
                set(figUIobj.CYmin, 'BackGroundColor', 'w')
            case 1 %Iplot
                set(plotUIobj.axes1, 'Ylim', [str2double(get(figUIobj.CYmin, 'string')),str2double(get(figUIobj.CYmax, 'string'))]);
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
                set(figUIobj.pulseAmp, 'string', '1')
                recobj.pulseAmp = 1;
            case 0
        end
    case 1%Iplot
        switch get(hObject, 'value')
            case 1
                set(figUIobj.pulseAmp, 'string', '10')
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
        set(hObject, 'string', 'Saving')
        
        if isfield(recobj, 'fname') == 1 && ischar(recobj.fname)
        else
            SelectSaveFile;
        end
        [~, fname, ext] = fileparts([recobj.dirname, recobj.fname]);
        
        e_fname = dir([recobj.dirname, '*.mat']);
        if size(e_fname, 1) == 0
            recobj.savecount = 1;
        else
            ind = zeros(1, size(e_fname, 1));
            for n = 1:size(e_fname ,1)
                [startIndex, ~] = regexp(e_fname(n).name, '\d');
                ind(n) = str2double(e_fname(n).name(startIndex));
            end
            recobj.savecount = max(ind) + 1;
        end
        
        recobj.savefilename  = [recobj.dirname, fname, num2str(recobj.savecount), ext];
        set(hGui.showfname, 'string', [fname, num2str(recobj.savecount), ext]);
        disp(['Save as :: ', recobj.savefilename]);
    case 0 %unsave
        set(hObject, 'string', 'Unsave')
        set(hGui.showfname, 'string', 'unset');
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