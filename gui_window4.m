function hGui = gui_window4(Testmode)
% gui_window3 creates a None But Air Graphical User Interface
% hGui = gui_window3(s, sTrig) returns a structure of graphics components
% handles (hGui) and create a GUI for PTB visual stimuli, data acquisition
% from a DAQ session (s), and control TTL output

global sobj
global recobj
global s

%% %---------- Create GUI window ----------%
%open GUI window
hGui.fig = figure('Position',[sobj.GUI_Display_x + 10, 20, 750, 750], 'Name','None But Air11', 'NumberTitle', 'off', 'Menubar','none', 'Resize', 'off');

%GUI components
hGui.ONSCR = uicontrol('style','pushbutton','string','OpenScreen','position',[5 705 80 30],'Horizontalalignment','center');
set(hGui.ONSCR,'Callback', {@OpenSCR, sobj});
hGui.CLSCR = uicontrol('style','pushbutton','string','CloseScreen','position', [5 670 80 30],'Horizontalalignment','center');
set(hGui.CLSCR, 'Callback',{@CloseSCR, sobj});

hGui.stim = uicontrol('style','togglebutton', 'string', 'Stim-OFF', 'position',[110 705 100 30],'Horizontalalignment','center');
set(hGui.stim, 'Callback',@ch_stimON);

hGui.EXIT = uicontrol('style', 'pushbutton', 'string','EXIT','position',[680 705 65 30],'FontSize',12,'Horizontalalignment','center');
set(hGui.EXIT, 'CallBack', {@quit_NBA, s});

%% save %%
hGui.getfname = uicontrol('style', 'pushbutton', 'string','File Name','position', [345 705 80 30],'Horizontalalignment','center');
set(hGui.getfname, 'Callback',@SelectSaveFile);

hGui.save=uicontrol('style','togglebutton','string','Unsave','position', [430 705 70 30],'Callback',@ch_save);

%% plot %%
hGui.PlotWindowON = uicontrol('style', 'togglebutton', 'string','Plot ON','position',[345 670 65 30],...
    'value', 1, 'BackGroundColor', 'g', 'FontSize',12,'Horizontalalignment','center');
set(hGui.PlotWindowON, 'CallBack', {@open_plot, hGui});
%%
%stim state monitor% %%
hGui.StimMonitor1=uicontrol('style','text','position',[230 670 100 20], 'string','','FontSize',12,'BackGroundColor','w');
hGui.StimMonitor2=uicontrol('style','text','position',[230 690 100 25], 'string','OFF','FontSize',12,'BackGroundColor','w','Horizontalalignment','center');
hGui.StimMonitor3=uicontrol('style','text','position',[230 715 100 20], 'string','','FontSize',12,'BackGroundColor','w');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli1 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title','Vis. Stim.1','FontSize',12,'Units', 'Pixels', 'Position',[5 10 195 650]);

uicontrol('style','text','string','Mode (Position)','position',[10 620 90 15],'Horizontalalignment','left');

hGui.mode=uicontrol('style','popupmenu','position',[10 600 90 20],'string',[{'Random'},{'Fix_Rep'},{'Ordered'}]);
set(hGui.mode, 'callback', @set_fig_pos);

%%
uicontrol('style','text','string','Stim.Pattern','position',[105 620 70 15],'Horizontalalignment','left');
hGui.pattern=uicontrol('style','popupmenu','position',[105 600 90 20],...
    'string',[{'Uni'},{'Size_rand'},{'1P_Conc'},{'2P_Conc'},{'B/W'},...
    {'Looming'},{'Sin'},{'Rect'},{'Gabor'},{'Images'},{'Mosaic'},{'FineMap'}]);
set(hGui.pattern, 'callback', @check_change_params);
% New stimulus patterns will be added this list and, change stim_pattern and "visual stimulus.m".

%%
%%% Stim1 shape
uicontrol('style','text','string','Stim.Shape','position',[10 575 60 15],'Horizontalalignment','left');
hGui.shape=uicontrol('style','popupmenu','position',[10 555 75 20],...
    'string',[{'Rect'},{'Circle'}]);
set(hGui.shape, 'value', 2); % default: 'FillOval'

%%% the nubmer of division for concentric positions
uicontrol('style','text','string','Division','position',[90 575 45 15],'Horizontalalignment','left');
hGui.div_zoom = uicontrol('style','edit','string',sobj.div_zoom,'position',[90 550 40 25],'BackGroundColor','w');

%%% distance from the center position
uicontrol('style','text','string','Dist(deg)','position',[140 575 50 15],'Horizontalalignment','left');
hGui.dist = uicontrol('style','edit','string',sobj.dist,'position',[140 550 40 25],'BackGroundColor','w');

%%% Luminance %%%
uicontrol('style','text','string','Stim.Lumi','position',[10 530 55 15],'Horizontalalignment','left');
hGui.stimlumi=uicontrol('style','edit','string',sobj.stimlumi,'position',[10 505 45 25],'BackGroundColor','w');
set(hGui.stimlumi, 'callback', @check_change_params);

uicontrol('style','text','string','BG.Lumi','position',[65 530 45 15],'Horizontalalignment','left');
hGui.bgcol=uicontrol('style','edit','string',sobj.bgcol,'position',[65 505 45 25],'BackGroundColor','w');
set(hGui.bgcol, 'callback', @check_change_params);

uicontrol('style','text','string','Lumi','position',[120 530 40 15],'Horizontalalignment','left');
hGui.lumi=uicontrol('style','popupmenu','position',[120 510 75 20],'string',[{'Fix'},{'Rand'}]);

%%% RGB %%% sobj.stimRGB
uicontrol('style','text','position',[120,480,70,15],'string','Stim.RGB','Horizontalalignment','left');
hGui.stimRGB = uicontrol('style','popupmenu','position',[120,455,70,25], 'string',[{'BW'},{'Blu'},{'Gre'},{'Yel'},{'Red'}]);
set(hGui.stimRGB, 'callback', @get_stimRGB);

%%% Durtion
uicontrol('style','text','string','Stim.Duration','position',[10 480 80 15],'Horizontalalignment','left');
hGui.flipNum=uicontrol('style','edit','string',sobj.flipNum,'position',[10 455 30 25],'BackGroundColor','w');
set(hGui.flipNum,'callback', @check_change_params);
sobj.duration = sobj.flipNum*sobj.m_int;
hGui.stimDur = uicontrol('style','text','position',[45 455 75 15],'string',['flips = ',num2str(floor(sobj.duration*1000)),' ms'],'Horizontalalignment','left');

%%% Delay Frames
uicontrol('style','text','position',[10 430 75 15],'string','PTB delay flip ','Horizontalalignment','left');
hGui.delayPTBflip = uicontrol('style','edit','position',[10 405 30 25],'string',sobj.delayPTBflip,'BackGroundColor','w');
set(hGui.delayPTBflip,'callback', @check_change_params);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
hGui.delayPTB = uicontrol('style','text','position',[45 405 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB*1000)),' ms'],'Horizontalalignment','left');

%%% Blank Frames
uicontrol('style','text','position',[10 380 70 15],'string','Set Blank','Horizontalalignment','left');
hGui.prestimN=uicontrol('style','edit','position',[10 355 30 25],'string',recobj.prestim,'BackGroundColor','w');
hGui.prestim=uicontrol('style','text','position',[45 355 100 15],...
    'string',['loops=',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),'sec'],'Horizontalalignment','left');

%%% The number of Image stimli
uicontrol('style', 'text','string','# of Imgs','position',[130 430 60 15],'HorizontalAlignment','left');
hGui.ImageNum = uicontrol('style','edit','string', sobj.ImageNum, 'position',[140 405 40 25],'BackGroundColor','w');

%%% Mosaic Dot Density
uicontrol('style', 'text','string','Density','position',[140 380 50 15],'HorizontalAlignment','left');
hGui.dots_density = uicontrol('style','edit','string', sobj.dots_density, 'position',[145 355 30 25],'BackGroundColor','w');
set(hGui.dots_density, 'callback', {@check_mosaic, hGui});
uicontrol('style', 'text','string','%','position',[175 355 20 15],'HorizontalAlignment','left');


%%% Size %%%%
uicontrol('style','text','position',[10 330 130 15],'string','Size (Diamiter)','Horizontalalignment','left');
hGui.size=uicontrol('style','edit','position',[10 305 50 25],'string','1','BackGroundColor','w');
uicontrol('style','text','position',[65 305 30 15],'string','deg','Horizontalalignment','left');
% Auto-Fill
hGui.auto_size=uicontrol('style','togglebutton','position',[105 300 70 30],'string','Auto OFF','Horizontalalignment','center');
set(hGui.auto_size, 'callback', {@autosizing, hGui});


%%% Center/Position %%%
uicontrol('style','text','position',[10 280 70 15],'string','Monitor Div.','Horizontalalignment','left');
hGui.divnum=uicontrol('style','edit','position',[10 255 50 25],'string',sobj.divnum,'BackGroundColor','w');
set(hGui.divnum, 'callback', {@reload_params, Testmode});
hGui.divnumN = uicontrol('style','text','position',[65 255 70 15],'string',['(' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'],'Horizontalalignment','left');

uicontrol('style','text','position',[10 230 70 15],'string','Fixed Pos.','Horizontalalignment','left');
hGui.fixpos=uicontrol('style','edit','position',[10 205 50 25],'string',sobj.fixpos,'BackGroundColor','w');
set(hGui.fixpos,'callback', {@reload_params, Testmode});
hGui.fixposN = uicontrol('style','text','position',[65 205 70 15],'string',['(in' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)'],'Horizontalalignment','left');

% Get fine position
hGui.get_fine_pos=uicontrol('style','togglebutton','position',[130 250 60 30],'string','get Pos','Horizontalalignment','center');
set(hGui.get_fine_pos, 'callback', {@get_fine_pos, hGui});

%%% Direction for grating stimulis or concentirc positions
uicontrol('style','text','position',[10 180 180 15],'string','Direction (Grating, Concentric)','Horizontalalignment','left');
hGui.shiftDir = uicontrol('style','popupmenu','position',[10 155 90 25],'string',[{'0'},{'45'},{'90'},{'135'},{'180'},{'225'},{'270'},{'315'},{'Order8'},{'Rand8'},{'Rand16'}]);
uicontrol('style','text','position',[100 160 25 15],'string','deg','Horizontalalignment','left');

%%% Temporal Frequecy for grating stimuli
uicontrol('style','text','position',[10 135 80 15],'string','Tempo Freq','Horizontalalignment','left');
hGui.shiftSpd=uicontrol('style','popupmenu','position',[10 110 70 25],'string',[{'0.5'},{'1'},{'2'},{'4'},{'8'}],'value',3,'BackGroundColor','w');
uicontrol('style','text','position',[75 115 20 15],'string','Hz','Horizontalalignment','left');

%%% Spatial Frequency for grating stimuli
uicontrol('style','text','position',[10 90 75 15],'string','Spatial Freq','Horizontalalignment','left');
hGui.gratFreq=uicontrol('style','popupmenu','position',[10 65 100 25],'string',[{'0.01'},{'0.02'},{'0.04'},{'0.08'},{'0.16'},{'0.32'}],'value',4,'BackGroundColor','w');
uicontrol('style','text','position',[110 70 60 15],'string','cycle/deg','Horizontalalignment','left');

%%% Looming Speed
uicontrol('style','text','position', [95 140 100 15],'string','Loom Spd/Size', 'Horizontalalignment','left');
hGui.loomSpd = uicontrol('style', 'popupmenu','position',[95, 115, 70, 25],'string',[{'5'},{'10'},{'20'},{'40'},{'80'},{'160'}]);
set(hGui.loomSpd,'callback', @check_change_params);
uicontrol('style','text','position',[160 120 35 15],'string','deg/s','Horizontalalignment','left');

% Looming Max Size
hGui.loomSize = uicontrol('style','edit','position',[125 90 30 25],'string',sobj.looming_Size,'BackGroundColor','w');
set(hGui.loomSize,'callback',  @check_change_params);
uicontrol('style','text','position',[160 90 35 15],'string','deg','Horizontalalignment','left');

%%% Distance b/w the LCD monitor and eye
uicontrol('style','text','position',[10 45 70 15],'string','Monior Dist.','Horizontalalignment','left');
hGui.MonitorDist=uicontrol('style','edit','position',[10 20 50 25],'string',sobj.MonitorDist,'BackGroundColor','y');
uicontrol('style','text','position',[65 20 30 15],'string','mm','Horizontalalignment','left');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli2 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','Vis. Stim.2','FontSize',12,'Units','Pixels','Position',[205 240 195 420]);

uicontrol('style','text','string','Stim.Shape2','position',[210 620 70 15],'Horizontalalignment','left');
hGui.shape2=uicontrol('style','popupmenu','position',[210 600 85 20],'string',[{'Rect'},{'Circle'}]);
set(hGui.shape2, 'value', 2);

%%% Luminace
uicontrol('style','text','string','Stim.Lumi2','position',[210 575 60 15],'Horizontalalignment','left');
hGui.stimlumi2=uicontrol('style','edit','string',sobj.stimlumi2,'position',[210 550 50 25],'BackGroundColor','w');
set(hGui.stimlumi2,'callback', @check_change_params);

%%% Duration
uicontrol('style','text','string','Stim.Duration2','position',[210 525 85 15],'Horizontalalignment','left');
hGui.flipNum2=uicontrol('style','edit','string',sobj.flipNum2,'position',[210 500 30 25],'BackGroundColor','w');
set(hGui.flipNum2, 'callback', @check_change_params);
sobj.duration2 = sobj.flipNum2*sobj.m_int;
hGui.stimDur2 = uicontrol('style','text','position',[245 500 75 15],...
    'string',['flips = ',num2str(floor(sobj.duration2*1000)),' ms'],'Horizontalalignment','left');

%%% Delay flip
uicontrol('style','text','string','PTB delay flip2','position',[210 475 85 15],'Horizontalalignment','left');
hGui.delayPTBflip2 = uicontrol('style','edit','string',sobj.delayPTBflip2,'position',[210 450 30 25],'BackGroundColor','w');
set(hGui.delayPTBflip2, 'callback', @check_change_params);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
hGui.delayPTB2 = uicontrol('style','text','position',[245 450 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB2*1000)),' ms'],'Horizontalalignment','left');

%%% Size
uicontrol('style','text','string','Stim.Size2 (Diamiter)','position',[210 425 130 15],'Horizontalalignment','left');
hGui.size2=uicontrol('style','edit','string', 1,'position',[210 400 50 25],'BackGroundColor','w');
uicontrol('style','text','string','deg','position',[265 400 25 15],'Horizontalalignment','left');

%%% Stim2 condition matching to Stim1
hGui.matchS1S2=uicontrol('style','pushbutton','string','Match S2 & S1','position',[300,595 95, 30],'Horizontalalignment','center');
set(hGui.matchS1S2, 'callback',{@match_stim2cond, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Electrophysiology %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title', 'Rec Setting', 'FontSize', 12, 'Units', 'Pixels', 'Position',[405 10 340 650]);

%%
uicontrol('style','text','position',[410 625 60 15],'string','Samp.Freq','Horizontalalignment','left');
hGui.sampf=uicontrol('style','edit','position',[410 600 50 25],'string',recobj.sampf/1000,'BackGroundColor','g');
uicontrol('style','text','position',[465 600 25 15],'string','kHz','Horizontalalignment','left');

uicontrol('style','text','position',[495 625 50 15],'string','Rec.Time','Horizontalalignment','left');
hGui.rect=uicontrol('style','edit','position',[495 600 50 25],'string',recobj.rect,'BackGroundColor','g');
set(hGui.rect,'callback', @check_change_params);
uicontrol('style','text','position',[550 600 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[580 625 80 15],'string','Loop Interval','Horizontalalignment','left');
hGui.interval=uicontrol('style','edit','position',[580 600 50 25],'string',recobj.interval,'BackGroundColor','g');
uicontrol('style','text','position',[635 600 25 15],'string','sec','Horizontalalignment','left');

%%
uicontrol('style','text','position',[540 580 80 15],'string','V range (mV)')
hGui.VYmin = uicontrol('style','edit','position',[540 555 40 25],'string',-100,'BackGroundColor','w');
hGui.VYmax = uicontrol('style','edit','position',[590 555 40 25],'string',30,'BackGroundColor','w');

uicontrol('style','text','position',[635 580 80 15],'string','C range (nA)')
hGui.CYmin = uicontrol('style','edit','position',[635 555 40 25],'string',-5,'BackGroundColor','w');
hGui.CYmax = uicontrol('style','edit','position',[680 555 40 25],'string',3,'BackGroundColor','w');

%% %%% pulse %%%
%Duration
uicontrol('style','text','position',[485 530 60 15],'string','Duration','Horizontalalignment','left');
hGui.pulseDuration = uicontrol('style','edit','position',[485 505 40 25],'string',recobj.pulseDuration,'BackGroundColor','w');
uicontrol('style','text','position',[525 505 25 15],'string','sec','Horizontalalignment','left');

%Delay
uicontrol('style','text','position',[555 530 60 15],'string','Delay','Horizontalalignment','left');
hGui.pulseDelay = uicontrol('style','edit','position',[555 505 40 25],'string',recobj.pulseDelay,'BackGroundColor','w');
uicontrol('style','text','position',[595 505 25 15],'string','sec','Horizontalalignment','left');

%Amplitude
uicontrol('style','text','position',[625 530 60 15],'string','Amp.','Horizontalalignment','left');
hGui.pulseAmp = uicontrol('style','edit','position',[625 505 40 25],'string',recobj.pulseAmp,'BackGroundColor','w');
set(hGui.pulseAmp,'callback',@check_change_params);
hGui.ampunit = uicontrol('style','text','position',[665 505 25 15],'string','nA','Horizontalalignment','left');

%Step
uicontrol('style','text','position',[450 485 30 15],'string','start','Horizontalalignment','left');
uicontrol('style','text','position',[485 485 30 15],'string','end','Horizontalalignment','left');
uicontrol('style','text','position',[520 485 30 15],'string','step','Horizontalalignment','left');

%for Current Clamp
uicontrol('style','text','position',[410 460 40 15],'string','C (nA)','Horizontalalignment','left');
hGui.Cstart = uicontrol('style','edit','position',[450 460 30 25],'string',recobj.stepCV(1,1),'callback', @check_change_params,'BackGroundColor','w');
hGui.Cend = uicontrol('style','edit','position',[485 460 30 25],'string',recobj.stepCV(1,2),'callback', @check_change_params,'BackGroundColor','w');
hGui.Cstep = uicontrol('style','edit','position',[520 460 30 25],'string',recobj.stepCV(1,3),'callback', @check_change_params,'BackGroundColor','w');

%for Voltage Clamp
uicontrol('style','text','position',[410 430 40 15],'string','V (mV)','Horizontalalignment','left');
hGui.Vstart = uicontrol('style','edit','position',[450 430 30 25],'string',recobj.stepCV(2,1), 'callback', @check_change_params, 'BackGroundColor','w');
hGui.Vend = uicontrol('style','edit','position',[485 430 30 25],'string',recobj.stepCV(2,2), 'callback', @check_change_params, 'BackGroundColor','w');
hGui.Vstep = uicontrol('style','edit','position',[520 430 30 25],'string',recobj.stepCV(2,3), 'callback', @check_change_params, 'BackGroundColor','w');

hGui.stepf = uicontrol('style','togglebutton','position',[555 455 40 30],'string','step','callback', @check_change_params);
hGui.pulse = uicontrol('style','togglebutton','position',[410 505 70 30],'string','Pulse ON', 'callback', @check_change_params);

% preset_Testpulse Amplitude
uicontrol('style','text','position',[695 530 40 15],'string','Preset','Horizontalalignment','left');
hGui.presetAmp = uicontrol('style','togglebutton','position',[690 505 50 25],'string','10 mV');
set(hGui.presetAmp,'Callback',@preset_pulseAmp);

%%
uicontrol('style','text','position',[410 405 80 15],'string','Daq Range (V)','Horizontalalignment','left');
hGui.DAQrange=uicontrol('style','popupmenu','position',[410 380 160 25],'string',[{'x1: [-10,10]'},{'x10: [-1,1]'},{'x50: [-0.2,0.2]'},{'x100: [-0.1,0.1]'}],'value',1);
set(hGui.DAQrange,'callback',@ch_DaqRange);
%%%%%%%
%% select plot channel %%
uicontrol('style','text','position',[410 580 55 15],'string','Plot Type ','Horizontalalignment','left');
hGui.plot=uicontrol('style','togglebutton','position',[410 550 60 30],'string','V-plot','ForegroundColor','white','BackGroundColor','b');
set(hGui.plot,'callback',@check_change_params);

uicontrol('style','text','position',[475 580 55 15],'string','Y-axis','Horizontalalignment','left');
hGui.yaxis=uicontrol('style','togglebutton','position',[475 550 60 30],'value',0, 'string',[{'Auto'},{'Fix'}]);
set(hGui.yaxis,'callback',@ch_yaxis);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   TTL out DIO3    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uipanel('Title','TTL3','FontSize',12,'Units', 'Pixels', 'Position',[205 10 195 230]);
%% DIO3 (outer TTL);
%{
uicontrol('style','text','position',[210 165 60 15],'string','Delay','Horizontalalignment','left');
hGui.delayTTL3=uicontrol('style','edit','position',[210,140,40,25],'string', recobj.TTL3.delay*1000,'BackGroundColor','w');
set(hGui.delayTTL3,'callback',@check_change_params);
uicontrol('style','text','position',[250 140 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[285 165 60 15],'string','Duration','Horizontalalignment','left');
hGui.durationTTL3=uicontrol('style', 'text', 'position', [285,140,60,15], 'string',recobj.TTL3.duration*1000);
set(hGui.durationTTL3,'callback',@setTTL3);
uicontrol('style','text','position',[345 140 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[210 120 60 15],'string','Freq.','Horizontalalignment','left');
hGui.freqTTL3=uicontrol('style','edit','position',[210 95 40 25],'string',recobj.TTL3.Freq,'BackGroundColor','w');
set(hGui.freqTTL3,'callback', @setTTL3);
uicontrol('style','text','position',[250 95 20 15],'string','Hz','Horizontalalignment','left');

uicontrol('style','text','position',[285 120 60 15],'string','PulseNum','Horizontalalignment','left');
hGui.pulsenumTTL3=uicontrol('style','edit','position',[285 95 60 25],'string',recobj.TTL3.PulseNum,'BackGroundColor','w');
set(hGui.pulsenumTTL3, 'callback', @setTTL3);

uicontrol('style', 'text', 'position', [210 75 60 15], 'string', 'DutyCycle', 'Horizontalalignment','left');
hGui.dutycycleTTL3=uicontrol('style','edit','position',[210 50 40 25],'string', recobj.TTL3.DutyCycle,'BackGroundColor','w');
set(hGui.dutycycleTTL3, 'callback', @setTTL3);

uicontrol('style','text','position',[285 75 100 15],'string','Single Pulse Width','Horizontalalignment','left');
hGui.widthTTL3=uicontrol('style','text','position',[285 50 40 15],'string', recobj.TTL3.DutyCycle/recobj.TTL3.Freq*1000,'Horizontalalignment','center');
uicontrol('style','text','position',[325 50 20 15],'string','ms','Horizontalalignment','left');
%}

hGui.TTL3=uicontrol('style','togglebutton','position',[210 185 65 30],'string','TTL-OFF','Horizontalalignment','left');
set(hGui.TTL3, 'Callback',{@TTL3, Testmode})

%hGui.TTL3_select=uicontrol('style','togglebutton','position',[285 185 90 30],'string','Fix:Duration','Horizontalalignment','left');
%set(hGui.TTL3_select, 'Callback',{@TTL3_select, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   Loop Start Button   %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main_loopingtest
hGui.loop=uicontrol('style','togglebutton','position',[110 670 100 30],...
    'string','Loop-OFF', 'callback',{@func_loop, hGui, Testmode},'BackGroundColor','r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% sub functions for callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% callback fucntions need at lest 2 parameters.
% other input parameters are used after 2nd var.
% function func_name(hObject, callbackdata, usr1, usr2, ...)

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
ch_ButtonColor(hObject,[],'y');

end

%%
function quit_NBA(~, ~, s)
global sobj
global dev
global plotUIobj
global getfineUIobj

delete(s)

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
function open_plot(hObject, ~, hGui)
global plotUIobj

if get(hObject,'value')
    plotUIobj = plot_window(hGui);
    disp('open plot window')
else
    if isfield(plotUIobj,'fig')
        close(plotUIobj.fig)
        clearvars -global plotUIobj
    end
end
ch_ButtonColor(hObject,[],'g')
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
        if isfield(getfineUIobj,'fig')
            close(getfineUIobj.fig)
            clearvars -global getfineUIobj
        end
    end
else
    if isfield(getfineUIobj,'fig')
        close(getfineUIobj.fig)
        clearvars -global getfineUIobj
    end
    set(hObject, 'value', 0)  
end

ch_ButtonColor(hObject,[],'g')
end

%%
function set_fig_pos(hObject,~)
global figUIobj
if get(hObject, 'value') == 2
    set(figUIobj.fixpos,'BackGroundColor','g');
else
    set(figUIobj.fixpos,'BackGroundColor','w');
end
end

%%
function get_stimRGB(hObject,~)
global sobj

% [{'BW'},{'Blu'},{'Gre'},{'Yel'},{'Red'}];
switch get(hObject,'value')
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
    set(hObject,'string','Auto FILL');
    Rx = floor((sobj.ScreenSize(1)/sobj.divnum));
    Ry = floor((sobj.ScreenSize(2)/sobj.divnum));
    sobj.stimsz = [Rx,Ry];
    stimsz_deg = round(Pix2Deg([sobj.stimsz], sobj.MonitorDist));
    set(hGui.size,'string',[num2str(stimsz_deg(1)), ' x ', num2str(stimsz_deg(2))]);
    
elseif get(hObject,'value')==0
    set(hObject,'string','Auto OFF');
    % seg to 1 deg
    sobj.stimsz = round(ones(1,2)*Deg2Pix(1, sobj.MonitorDist, sobj.pixpitch));
    set(hGui.size,'string', 1);
end
ch_ButtonColor(hObject,[],'g')
end

function check_mosaic(hObject, ~, hGui)
%the number of dots is zero, use default settings.
div_zoom = str2double(get(hGui.div_zoom,'string'));
dist = str2double(get(hGui.dist,'string'));
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
    set(hGui.shape2,'value', get(hGui.shape,'value'));
    sobj.shape2 = sobj.shapelist{get(hGui.shape2,'value'),1};
    
    %Stim.Lumi2
    set(hGui.stimlumi2, 'string', get(hGui.stimlumi,'string'));
    sobj.stimlumi2 = str2double(get(hGui.stimlumi2,'string'));
    
    %Stim.Duration2
    set(hGui.flipNum2,'string',get(hGui.flipNum,'string'));
    sobj.flipNum2 = str2double(get(hGui.flipNum2,'string'));
    
    %PTB delay2
    set(hGui.delayPTBflip2,'string', get(hGui.delayPTBflip,'string'));
    sobj.delayPTBflip2 = str2double(get(hGui.delayPTBflip2,'string'));
    sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
    
    %Stim.Size2
    set(hGui.size2,'string', get(hGui.size,'string'));
    sobj.stimsz2 = sobj.stimsz;
end
end

%%
function ch_DaqRange(hObject, ~)
global InCh
i = get(hObject,'value');

Ranges = [-10,10;-1,1;-0.2,0.2;-0.1,0.1];
InCh(1).Range = Ranges(i,:);
InCh(2).Range = Ranges(i,:);
InCh(3).Range = [-10 10];
end

%%
function TTL3(hObject, ~, Testmode)
if Testmode == 0
    switch get(hObject,'value')
        case 1
            set(hObject,'string', 'TTL-ON');
        case 0
            set(hObject,'string', 'TTL-OFF');
    end
end

ch_ButtonColor(hObject,[], 'g')
%setTTL3;
end

%%
%{
function TTL3_select(hObject, ~, hGui)
switch get(hObject,'value')
    case 0
        set(hObject, 'string', 'Fix:Duration');
        set(hGui.durationTTL3, 'style','text', 'position', [285,140,60,15],'BackGroundColor',[0.9400 0.9400 0.9400])
        set(hGui.pulsenumTTL3, 'style','edit', 'position', [285 95 60 25],'BackGroundColor','w')
    case 1
        set(hObject, 'string', 'Fix:PulseNum');
        set(hGui.durationTTL3, 'style','edit', 'position', [285,140,60,25],'BackGroundColor','w')
        set(hGui.pulsenumTTL3, 'style','text', 'position', [285 95 60 15],'BackGroundColor',[0.9400 0.9400 0.9400])
end
end
%}
%%
function ch_yaxis(hObject, ~)
global figUIobj
global plotUIobj

switch get(hObject,'value')
    case 0
        set(hObject, 'string', 'Auto');
        set(plotUIobj.axes1,'YlimMode','Auto');
        set(figUIobj.VYmax,'BackGroundColor','w')
        set(figUIobj.VYmin,'BackGroundColor','w')
        set(figUIobj.CYmax,'BackGroundColor','w')
        set(figUIobj.CYmin,'BackGroundColor','w')
    case 1
        set(hObject, 'string', 'Fix');
        set(plotUIobj.axes1,'YlimMode','Manual');
        switch get(figUIobj.plot,'value')
            case 0 %Vplot
                set(plotUIobj.axes1,'Ylim',[str2double(get(figUIobj.VYmin,'string')),str2double(get(figUIobj.VYmax,'string'))]);
                set(figUIobj.VYmax,'BackGroundColor','g')
                set(figUIobj.VYmin,'BackGroundColor','g')
                set(figUIobj.CYmax,'BackGroundColor','w')
                set(figUIobj.CYmin,'BackGroundColor','w')
            case 1 %Iplot
                set(plotUIobj.axes1,'Ylim',[str2double(get(figUIobj.CYmin,'string')),str2double(get(figUIobj.CYmax,'string'))]);
                set(figUIobj.VYmax,'BackGroundColor','w')
                set(figUIobj.VYmin,'BackGroundColor','w')
                set(figUIobj.CYmax,'BackGroundColor','g')
                set(figUIobj.CYmin,'BackGroundColor','g')
        end
end
ch_ButtonColor(hObject,[],'g')
end

%%
function ch_ButtonColor(hObject, ~, col)
switch get(hObject, 'Value')
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor',[0.9400 0.9400 0.9400])
    case 1%
        set(hObject, 'BackgroundColor',col)
end
end

%%

%%%%%%%%%%%%% save setting %%%%%%%%%%%%%%
%%
function SelectSaveFile(~, ~)
global recobj

if isfield(recobj,'dirname') == 0 % 1st time to define filename
    [recobj.fname, recobj.dirname] = uiputfile('*.*');
else %open the same folder when any foder was selected previously.
    if recobj.dirname == 0
        recobj.dirname = pwd;
    else
        [recobj.fname, recobj.dirname] = uiputfile('*.mat','Select File to Write',recobj.dirname);
    end
end
end

%%
function ch_save(hObject,~)
global recobj

switch get(hObject,'value')
    case 1 %saving
        set(hObject,'string','Saving')
        if isfield(recobj,'fname')==1 && ischar(recobj.fname)
        else
            SelectSaveFile;
        end
        [~, fname, ext] = fileparts([recobj.dirname, recobj.fname]);
        recobj.savefilename  = [recobj.dirname, fname, num2str(recobj.savecount), ext];
        disp(['filename ::', recobj.savefilename]);
    case 0 %unsave
        set(hObject, 'string', 'Unsave')
end

ch_ButtonColor(hObject,[],'g');
end

%%
function preset_pulseAmp(hObject, ~)
global recobj
global figUIobj

switch get(figUIobj.plot, 'value')
    case 0 %Vplot::preset 1 nA
        switch get(hObject,'value')
            case 1
                set(figUIobj.pulseAmp, 'string', '1')
                recobj.pulseAmp = 1;
            case 0
        end
    case 1%Iplot
        switch get(hObject,'value')
            case 1
                set(figUIobj.pulseAmp, 'string', '10')
                recobj.pulseAmp = 10;
        end
        
end
end

