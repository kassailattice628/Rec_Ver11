function hGui = gui_window3
%gui_window3 creates a None But Air Graphical User Interface
% hGui = gui_window3(s, sTrig) returns a structure of graphics components
% handles (hGui) and create a GUI for PTB visual stimuli, data acquisition
% from a DAQ session (s), and control TTL output

global sobj
global recobj
global s

global FigAI12
global FigPhoto


%% %---------- Create GUI window ----------%
%open GUI window
hGui.fig = figure('Position',[10, 20, 1000, 750], 'Name','None But Air','Menubar','none', 'Resize', 'off');
%set(hGui.fig, 'DeleteFcn', {@quit_NBA, s});
%GUI components
hGui.ONSCR = uicontrol('style','pushbutton','string','OpenScreen','position',[5 705 80 30],'Horizontalalignment','center');
set(hGui.ONSCR,'Callback', {@OpenSCR, sobj});
hGui.CLSCR = uicontrol('style','pushbutton','string','CloseScreen','position', [5 670 80 30],'Horizontalalignment','center');
set(hGui.CLSCR, 'Callback',{@CloseSCR, sobj});

hGui.stim=uicontrol('style','togglebutton','position',[110 705 100 30],'string','Stim-OFF','callback',@ch_stimON,'Horizontalalignment','center');

hGui.EXIT=uicontrol('string','EXIT','position',[345 705 65 30],'FontSize',12,'Horizontalalignment','center');
set(hGui.EXIT, 'CallBack', {@quit_NBA, s});

%%
%stim state monitor% %%
hGui.StimMonitor1=uicontrol('style','text','position',[230 670 100 20], 'string','','FontSize',12,'BackGroundColor','w');
hGui.StimMonitor2=uicontrol('style','text','position',[230 690 100 25], 'string','OFF','FontSize',12,'BackGroundColor','w','Horizontalalignment','center');
hGui.StimMonitor3=uicontrol('style','text','position',[230 715 100 20], 'string','','FontSize',12,'BackGroundColor','w');

%%
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%    Plot Window   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trace 1, AI1 or AI2
%hGui.axes1 = subplot('position', [0.46 0.35 0.52 0.35]);
%[10, 20, 1000, 750]
hGui.axes1 = axes('Units', 'Pixels', 'Position',[455,255,515,255]);
set(hGui.axes1, 'XLimMode', 'manual','YlimMode', 'Auto');
hGui.plot1 = plot(0, NaN(1,1),'b');
xlabel('Time (sec)');
ylabel('mV');
title('V-DATA');

%hGui.flash2 = line('xdata',[0 0],'ydata',[0 0],'Color','r','LineWidth',1);
%hGui.flash3 = line('xdata',[0 0],'ydata',[0 0],'Color','r','LineWidth',1);

% trace 3, AI3:Photo Sensor
%hGui.axes2 = subplot('position', [0.46 0.1 0.52 0.15]);
hGui.axes2 = axes('Units', 'Pixels', 'Position',[455,75,515,110]);
set(hGui.axes1, 'XLimMode', 'manual','YlimMode', 'Auto');
hGui.plot2 = plot(NaN, NaN(1,1));
xlabel('Time (sec)');
ylabel('mV');
title('Photo Sensor');
%}
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli1 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','Vis. Stim.1','FontSize',12,'Position',[0.005 0.013 0.195 0.87]);

uicontrol('style','text','position',[10 620 90 15],'string','Mode (Position)','Horizontalalignment','left');
hGui.mode=uicontrol('style','popupmenu','position',[10 600 90 20],'string',[{'Random'},{'Fix_Rep'},{'Ordered'}]);
set(hGui.mode, 'callback', @reload_params);

uicontrol('style','text','position',[105 620 70 15],'string','Stim.Pattern','Horizontalalignment','left');
hGui.pattern=uicontrol('style','popupmenu','position',[105 600 90 20],'string',[{'Uni'},{'BW'},{'Sin'},{'Rect'},{'Gabor'},{'Sz_r'},{'Zoom'},{'2Stim'},{'Images'}]);
set(hGui.pattern, 'callback', @reload_params);
%% New stimulus patterns will be added this list and, change stim_pattern and "visual stimulus.m".

%%
uicontrol('style','text','position',[10 575 60 15],'string','Stim.Shape','Horizontalalignment','left');
hGui.shape=uicontrol('style','popupmenu','position',[10 555 75 20],'string',[{'Rect'},{'Circle'}]);
set(hGui.shape, 'callback', @reload_params);
set(hGui.shape, 'value', 2); % default: 'FillOval'

uicontrol('style','text','position',[90 575 45 15],'string','Div.Zoom','Horizontalalignment','left');
hGui.div_zoom = uicontrol('style','edit','position',[90 550 40 25],'string',sobj.div_zoom,'BackGroundColor','w');
set(hGui.div_zoom,'callback', @reload_params);

%distance from the center point
uicontrol('style','text','position',[140 575 50 15],'string','Dist(deg)','Horizontalalignment','left');
hGui.dist = uicontrol('style','edit','position',[140 550 40 25],'string',sobj.dist,'BackGroundColor','w');
set(hGui.dist, 'callback', @reload_params);

%%% Luminance %%%
uicontrol('style','text','position',[10 530 55 15],'string','Stim.Lumi','Horizontalalignment','left');
hGui.stimlumi=uicontrol('style','edit','position',[10 505 45 25],'string',sobj.stimlumi,'BackGroundColor','w');
set(hGui.stimlumi, 'callback', @reload_params);

uicontrol('style','text','position',[65 530 45 15],'string','BG.Lumi','Horizontalalignment','left');
hGui.bgcol=uicontrol('style','edit','position',[65 505 45 25],'string',sobj.bgcol,'BackGroundColor','w');
set(hGui.bgcol, 'callback', @reload_params);

uicontrol('style','text','position',[120 530 40 15],'string','Lumi','Horizontalalignment','left');
hGui.lumi=uicontrol('style','popupmenu','position',[120 510 75 20],'string',[{'Fix'},{'Rand'}]);
set(hGui.lumi, 'callback', @Random_luminance);

%%%%% Durtion %%%
uicontrol('style','text','position',[10 480 65 15],'string','Stim.Duration','Horizontalalignment','left');
hGui.flipNum=uicontrol('style','edit','position',[10 455 30 25],'string',sobj.flipNum,'BackGroundColor','w');
set(hGui.flipNum,'callback', @reload_params);
sobj.duration = sobj.flipNum*sobj.m_int;
hGui.stimDur = uicontrol('style','text','position',[45 455 75 15],'string',['flips = ',num2str(floor(sobj.duration*1000)),' ms'],'Horizontalalignment','left');


%%% RGB %%% sobj.stimRGB
uicontrol('style','text','position',[120,480,70,15],'string','Stim.RGB','Horizontalalignment','left');
hGui.stimRGB = uicontrol('style','popupmenu','position',[120,455,70,25], 'string',[{'BW'},{'Blu'},{'Gre'},{'Yel'},{'Red'}]);
set(hGui.stimRGB, 'callback', @check_stimRGB);


%%% DelayPTB
uicontrol('style','text','position',[10 430 75 15],'string','PTB delay flip ','Horizontalalignment','left');
hGui.delayPTBflip = uicontrol('style','edit','position',[10 405 30 25],'string',sobj.delayPTBflip,'BackGroundColor','w');
set(hGui.delayPTBflip,'callback', @reload_params);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
hGui.delayPTB = uicontrol('style','text','position',[45 405 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB*1000)),' ms'],'Horizontalalignment','left');

%%%%
uicontrol('style','text','position',[10 380 70 15],'string','Set Blank','Horizontalalignment','left');
hGui.prestimN=uicontrol('style','edit','position',[10 355 30 25],'string',recobj.prestim,'BackGroundColor','w');
set(hGui.prestimN, 'callback', @reload_params);
hGui.prestim=uicontrol('style','text','position',[45 355 85 15],'string',['loops = > ',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),' sec'],'Horizontalalignment','left');

%%% Size %%%%
uicontrol('style','text','position',[10 330 105 15],'string','Stim.Size (Diamiter)','Horizontalalignment','left');
hGui.size=uicontrol('style','edit','position',[10 305 50 25],'string','1','BackGroundColor','w');
set(hGui.size, 'callback', @reload_params);
uicontrol('style','text','position',[65 305 30 15],'string','deg','Horizontalalignment','left');
%Auto-Fill
hGui.auto_size=uicontrol('style','togglebutton','position',[105 300 70 30],'string','Auto OFF','Horizontalalignment','center');
set(hGui.auto_size, 'callback', {@autosizing, sobj.MonitorDist, hGui});

uicontrol('style','text','position',[10 280 70 15],'string','Monitor Div.','Horizontalalignment','left');
hGui.divnum=uicontrol('style','edit','position',[10 255 50 25],'string',sobj.divnum,'BackGroundColor','w');
set(hGui.divnum, 'callback', @reload_params);
hGui.divnumN = uicontrol('style','text','position',[65 255 100 15],'string',['(=> ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)'],'Horizontalalignment','left');

uicontrol('style','text','position',[10 230 70 15],'string','Fixed Pos.','Horizontalalignment','left');
hGui.fixpos=uicontrol('style','edit','position',[10 205 50 25],'string',sobj.fixpos,'BackGroundColor','w');
set(hGui.fixpos,'callback', @reload_params);
hGui.fixposN = uicontrol('style','text','position',[65 205 100 15],'string',['(<= ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)'],'Horizontalalignment','left');

%%% Rotation Direction %%
uicontrol('style','text','position',[10 180 130 15],'string','Direction (Grating, Poler)','Horizontalalignment','left');
hGui.shiftDir = uicontrol('style','popupmenu','position',[10 155 90 25],'string',[{'0'},{'45'},{'90'},{'135'},{'180'},{'225'},{'270'},{'315'},{'Order8'},{'Rand8'},{'Rand16'}]);
set(hGui.shiftDir, 'callback', @reload_params);
uicontrol('style','text','position',[100 160 25 15],'string','deg','Horizontalalignment','left');

%%%
uicontrol('style','text','position',[10 135 80 15],'string','Temporal Freq','Horizontalalignment','left');
hGui.shiftSpd=uicontrol('style','popupmenu','position',[10 110 80 25],'string',[{'0.5'},{'1'},{'2'},{'4'},{'8'}],'value',3,'BackGroundColor','w');
set(hGui.shiftSpd, 'callback', @reload_params);
uicontrol('style','text','position',[90 115 20 15],'string','Hz','Horizontalalignment','left');

uicontrol('style','text','position',[10 90 75 15],'string','Spatial Freq','Horizontalalignment','left');
hGui.gratFreq=uicontrol('style','popupmenu','position',[10 65 100 25],'string',[{'0.01'},{'0.02'},{'0.04'},{'0.08'},{'0.16'},{'0.32'}],'value',4,'BackGroundColor','w');
set(hGui.gratFreq, 'callback', @reload_params);
uicontrol('style','text','position',[110 70 50 15],'string','cycle/deg','Horizontalalignment','left');

uicontrol('style','text','position',[10 45 70 15],'string','Monior Dist.','Horizontalalignment','left');
hGui.MonitorDist=uicontrol('style','edit','position',[10 20 50 25],'string',sobj.MonitorDist,'BackGroundColor','g');
set(hGui.MonitorDist,'callback', @reload_params);
uicontrol('style','text','position',[65 20 30 15],'string','mm','Horizontalalignment','left');

%%
uicontrol('style', 'text','position',[120 430 70 15],'string','# of Imgs','HorizontalAlignment','left');
hGui.ImageNum = uicontrol('style','edit','position',[120 405 40 25],'string',sobj.ImageNum','BackGroundColor','w');
set(hGui.ImageNum, 'callback', @reload_params);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli2 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','Vis. Stim.2','FontSize',12,'Position',[0.205 0.313 0.195 0.57]);

uicontrol('style','text','position',[210 620 70 15],'string','Stim.Shape2','Horizontalalignment','left');
hGui.shape2=uicontrol('style','popupmenu','position',[210 600 85 20],'string',[{'Rect'},{'Circle'}]);
set(hGui.shape2,'callback', @reload_params);
set(hGui.shape2, 'value', 2);

uicontrol('style','text','position',[210 575 60 15],'string','Stim.Lumi2','Horizontalalignment','left');
hGui.stimlumi2=uicontrol('style','edit','position',[210 550 50 25],'string',sobj.stimlumi2,'BackGroundColor','w');
set(hGui.stimlumi2,'callback', @reload_params);

uicontrol('style','text','position',[210 525 85 15],'string','Stim.Duration2','Horizontalalignment','left');
hGui.flipNum2=uicontrol('style','edit','position',[210 500 30 25],'string',sobj.flipNum2,'BackGroundColor','w');
set(hGui.flipNum2, 'callback', @reload_params);
sobj.duration2 = sobj.flipNum2*sobj.m_int;
hGui.stimDur2 = uicontrol('style','text','position',[245 500 75 15],'string',['flips = ',num2str(floor(sobj.duration2*1000)),' ms'],'Horizontalalignment','left');

uicontrol('style','text','position',[210 475 85 15],'string','PTB delay flip2 ','Horizontalalignment','left');
hGui.delayPTBflip2 = uicontrol('style','edit','position',[210 450 30 25],'string',sobj.delayPTBflip2,'BackGroundColor','w');
set(hGui.delayPTBflip2, 'callback', @reload_params);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
hGui.delayPTB2 = uicontrol('style','text','position',[245 450 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB2*1000)),' ms'],'Horizontalalignment','left');

uicontrol('style','text','position',[210 425 130 15],'string','Stim.Size2 (Diamiter)','Horizontalalignment','left');
hGui.size2=uicontrol('style','edit','position',[210 400 50 25],'string','1','BackGroundColor','w');
set(hGui.size2, 'callback', @reload_params);
uicontrol('style','text','position',[265 400 25 15],'string','deg','Horizontalalignment','left');

hGui.matchS1S2=uicontrol('style','pushbutton','string','Match S2 & S1','position',[300,595 95, 30],'Horizontalalignment','center');
set(hGui.matchS1S2, 'callback',{@match_stim2cond, hGui})

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Electrophysiology %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title', 'Rec Setting','FontSize',12,'Position',[0.42 0.73 0.55 0.26]);
%%
uicontrol('style','text','position',[435 695 60 15],'string','Samp.Freq','Horizontalalignment','left');
hGui.sampf=uicontrol('style','edit','position',[435 670 50 25],'string',recobj.sampf/1000,'BackGroundColor','g');
set(hGui.sampf,'callback', @reload_params);
uicontrol('style','text','position',[490 670 25 15],'string','kHz','Horizontalalignment','left');

uicontrol('style','text','position',[515 695 60 15],'string','Rec.Time','Horizontalalignment','left');
hGui.rect=uicontrol('style','edit','position',[515 670 50 25],'string',recobj.rect,'BackGroundColor','g');
set(hGui.rect,'callback', @reload_params);
uicontrol('style','text','position',[570 670 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[595 695 70 15],'string','Loop Interval','Horizontalalignment','left');
hGui.interval=uicontrol('style','edit','position',[595 670 50 25],'string',recobj.interval,'BackGroundColor','g');
set(hGui.rect,'callback', @reload_params);
uicontrol('style','text','position',[650 670 25 15],'string','sec','Horizontalalignment','left');

uicontrol('style','text','position',[680 695 80 15],'string','Daq Range (V)','Horizontalalignment','left');
hGui.DAQrange=uicontrol('style','popupmenu','position',[675 670 120 25],'string',[{'x1:[-10,10]'},{'x10:[-1,1]'},{'x50:[-0.2,0.2]'},{'x100:[-0.1,0.1]'}],'value',1);
set(hGui.DAQrange,'callback',@ch_DaqRange);

%%
uicontrol('style','text','position',[610 650 80 15],'string','V range (mV)')
hGui.VYmin = uicontrol('style','edit','position',[610 625 40 25],'string',-100,'BackGroundColor','w');
hGui.VYmax = uicontrol('style','edit','position',[655 625 40 25],'string',30,'BackGroundColor','w');

uicontrol('style','text','position',[705 650 80 15],'string','C range (nA)')
hGui.CYmin = uicontrol('style','edit','position',[705 625 40 25],'string',-5,'BackGroundColor','w');
hGui.CYmax = uicontrol('style','edit','position',[750 625 40 25],'string',3,'BackGroundColor','w');

%%% pulse %%%
hGui.pulse = uicontrol('style','togglebutton','position',[435 585 70 25],'string','Pulse OFF');
set(hGui.pulse, 'Callback', {@ch_ButtonColor, 'g'});

%Duration
uicontrol('style','text','position',[510 610 60 15],'string','Duration','Horizontalalignment','left');
hGui.pulseDuration = uicontrol('style','edit','position',[510 585 50 25],'string',recobj.pulseDuration,'BackGroundColor','w');
uicontrol('style','text','position',[560 585 25 15],'string','sec','Horizontalalignment','left');

%Delay
uicontrol('style','text','position',[590 610 60 15],'string','Delay','Horizontalalignment','left');
hGui.pulseDelay = uicontrol('style','edit','position',[590 585 50 25],'string',recobj.pulseDelay,'BackGroundColor','w');
uicontrol('style','text','position',[640 585 25 15],'string','sec','Horizontalalignment','left');

%Amplitude
uicontrol('style','text','position',[670 610 90 15],'string','Amplitude','Horizontalalignment','left');
hGui.pulseAmp = uicontrol('style','edit','position',[670 585 50 25],'string',recobj.pulseAmp,'BackGroundColor','w');
set(hGui.pulseAmp,'callback',{@check_AOrange, hGui});
hGui.ampunit = uicontrol('style','text','position',[720 585 25 15],'string','nA','Horizontalalignment','left');

%%% preset_Testpulse Amplitude%%%
uicontrol('style','text','position',[740 610 90 15],'string','Preset','Horizontalalignment','left');
hGui.presetAmp = uicontrol('style','togglebutton','position',[740 585 50 25],'string','10 mV');
set(hGui.presetAmp,'Callback',@preset_pulseAmp);

%Step
uicontrol('style','text','position',[850 650 30 15],'string','start','Horizontalalignment','left');
uicontrol('style','text','position',[885 650 30 15],'string','end','Horizontalalignment','left');
uicontrol('style','text','position',[920 650 30 15],'string','step','Horizontalalignment','left');

%for Current Clamp
uicontrol('style','text','position',[810 620 40 25],'string','C (nA)','Horizontalalignment','left');
hGui.Cstart = uicontrol('style','edit','position',[850 625 30 25],'string',recobj.stepCV(1,1),'BackGroundColor','w');
hGui.Cend = uicontrol('style','edit','position',[885 625 30 25],'string',recobj.stepCV(1,2),'BackGroundColor','w');
hGui.Cstep = uicontrol('style','edit','position',[920 625 30 25],'string',recobj.stepCV(1,3),'BackGroundColor','w');

%for Voltage Clamp
uicontrol('style','text','position',[810 590 40 25],'string','V (mV)','Horizontalalignment','left');
hGui.Vstart = uicontrol('style','edit','position',[850 595 30 25],'string',recobj.stepCV(2,1),'BackGroundColor','w');
hGui.Vend = uicontrol('style','edit','position',[885 595 30 25],'string',recobj.stepCV(2,2),'BackGroundColor','w');
hGui.Vstep = uicontrol('style','edit','position',[920 595 30 25],'string',recobj.stepCV(2,3),'BackGroundColor','w');

hGui.stepf = uicontrol('style','togglebutton','position',[805 645 40 25],'string','step','Callback',{@steppulse, hGui});

%% select plot channel %%
uicontrol('style','text','position',[435 650 55 15],'string','Plot Type ','Horizontalalignment','left');
hGui.plot=uicontrol('style','togglebutton','position',[435 625 90 30],'string','V-plot','ForegroundColor','white','BackGroundColor','b');
set(hGui.plot,'callback',@ch_plot);

uicontrol('style','text','position',[530 650 55 15],'string','Y-axis','Horizontalalignment','left');
hGui.yaxis=uicontrol('style','togglebutton','position',[530 625 75 30],'value',0, 'string',[{'Auto'},{'Fix'}]);
set(hGui.yaxis,'callback',@ch_yaxis);
%% save %%
uicontrol('string','File Name','position', [435 550 90 30],'Callback',@SelectSaveFile,'Horizontalalignment','center');
hGui.savech=uicontrol('style','popupmenu','position', [530 555 120 20],'string',[{'ALL'},{'Header Only'},{'Header&Photo'}]);
hGui.save=uicontrol('style','togglebutton','position', [655 550 70 30],'string','Unsave','Callback',@ch_save);

%%
%Elech only
hGui.EOf = uicontrol('style','togglebutton','position',[890 700 60 30],'string','E only','FontSize',12,'Horizontalalignment','center');
set(hGui.EOf, 'Callback',{@ch_ButtonColor,'g'});


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   TTL out DIO3    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','TTL3','FontSize',12,'Position',[0.205 0.11 0.195 0.2]);
%% DIO3 (outer TTL);
uicontrol('style','text','position',[210 165 50 15],'string','duration','Horizontalalignment','left');
hGui.durationTTL3=uicontrol('style', 'edit', 'position', [210,140,40,25], 'string',recobj.durationTTL3,'BackGroundColor','w');
set(hGui.durationTTL3, 'callback',@reload_params);
uicontrol('style','text','position',[255 140 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[280 165 50 15],'string','delay','Horizontalalignment','left');
hGui.delayTTL3=uicontrol('style','edit','position',[280 140 40 25],'string',recobj.delayTTL3,'BackGroundColor','w');
set(hGui.delayTTL3,'callback',@reload_params);
uicontrol('style','text','position',[325 140 20 15],'string','ms','Horizontalalignment','left');

hGui.TTL3=uicontrol('style','togglebutton','position',[210 185 65 30],'string','TTL-OFF','Horizontalalignment','left');
set(hGui.TTL3, 'Callback',{@TTL3, hGui})


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   AI1, AI2 plot    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rotary Encoder ON/OFF
hGui.AI12Ctr = uicontrol('style','togglebutton','position',[210 50 85 30],...
    'string','AI1 / AI2','FontSize',12,'Horizontalalignment','center');
set(hGui.AI12Ctr,'value', 1, 'Callback',@AI12Set);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%    Photo Sensor    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Photo Sensor ON/OFF
hGui.PhotoSensorCtr = uicontrol('style','togglebutton','position',[300 50 85 30],...
    'string','Photo Sensor','FontSize',12,'Horizontalalignment','center');
set(hGui.PhotoSensorCtr, 'value', 1, 'Callback',@PhotoSencerSet);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Rotary Encoder   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rotary Encoder ON/OFF
hGui.RotCtr = uicontrol('style','togglebutton','position',[210 15 85 30],...
    'string','Rotor Plot','FontSize',12,'Horizontalalignment','center');
set(hGui.RotCtr,'Callback',@RotarySet);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Live Plot TTL   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rotary Encoder ON/OFF
hGui.LivePlotOn = uicontrol('style','togglebutton','position',[300 15 85 30],...
    'string','Live Plot','FontSize',12,'Horizontalalignment','center');
set(hGui.LivePlotOn,'Callback',@LivePlotSet);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   Loop Start Button   %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main_loopingtest
hGui.loop=uicontrol('style','togglebutton','position',[110 670 100 30],'string','Loop-OFF','callback',{@loopON, hGui},'BackGroundColor','r');



%% open plot AI1/2
%[10, 20, 1000, 750]
FigAI12.fig = figure(2);
set(FigAI12.fig, 'Units', 'Pixels', 'Position',[455,530,700,200],...
    'Name', 'AI1 / AI2', 'Menubar','none', 'Resize','off',...
    'DeleteFcn', {@FigOff, hGui.AI12Ctr});
FigAI12.axes = axes('XLimMode', 'manual','YlimMode', 'Auto');
FigAI12.plot = plot(0, NaN(1,1),'b');
xlabel('Time (s)');
ylabel('mV');
title('V-DATA');
%% open photosensor
FigPhoto.fig = figure(3);
set(FigPhoto.fig, 'Units', 'Pixels', 'Position',[455,400,700,110],...
    'Name', 'Photo Sensor', 'Menubar','none', 'Resize','off',...
    'DeleteFcn', {@FigOff, hGui.PhotoSensorCtr});
FigPhoto.axes = axes('XLimMode', 'manual','YlimMode', 'Auto');
FigPhoto.plot = plot(NaN, NaN(1,1));
xlabel('Time (s)');
ylabel('V');
title('Photo Sensor');

%%
figure(hGui.fig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables check %
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
flag.start = 1;Screen('Close', sobj.wPtr);
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
delete(s)
if isempty(dev)
else
    daq.reset;
end
if sobj.ScrNum ~= 0
    Screen('Close', sobj.wPtr);
end
%clear windows, variables
sca;
clear;
close all;
end
%%
function check_stimRGB(hObject,~)
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
function autosizing(hObject, ~, dist, hGui)
%automatically set stimulus size to one division
global sobj

if get(hObject, 'value')==1
    set(hObject,'string','Auto FILL');
    Rx = floor((sobj.ScreenSize(1)/sobj.divnum));
    Ry = floor((sobj.ScreenSize(2)/sobj.divnum));
    sobj.stimsz = [Rx,Ry];
    szdeg = round(Pix2Deg([sobj.stimsz], dist));
    set(hGui.size,'string',[num2str(szdeg(1)), ' x ', num2str(szdeg(2))]);
    
elseif get(hObject,'value')==0
    set(hObject,'string','Auto OFF');
    sobj.stimsz = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist));% default �� 1�x
    set(hGui.size,'string', 1);
end

ch_ButtonColor(hObject,[],'g')
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
function TTL3(hObject, ~, hGui)
global recobj
global dio

switch get(hObject,'value')
    case 1
        set(hObject,'string', 'TTL-ON');
        set(hGui.delayTTL3,'string','0')
        recobj.delayTTL3 = 0;
        outputSingleScan(dio.TTL3,0); %reset trigger signals at Low
    case 0
        set(hObject,'string', 'TTL-OFF');
end

ch_ButtonColor(hObject,[], 'g')
end

%%
function ch_yaxis(hObject, ~)
global figUIobj
switch get(hObject,'value')
    case 0
        set(hObject, 'string', 'Auto');
        set(figUIobj.axes1,'YlimMode','Auto');
        set(figUIobj.VYmax,'BackGroundColor','w')
        set(figUIobj.VYmin,'BackGroundColor','w')
        set(figUIobj.CYmax,'BackGroundColor','w')
        set(figUIobj.CYmin,'BackGroundColor','w')
    case 1
        set(hObject, 'string', 'Fix');
        set(figUIobj.axes1,'YlimMode','Manual');
        switch get(figUIobj.plot,'value')
            case 0 %Vplot
                set(figUIobj.axes1,'Ylim',[str2double(get(figUIobj.VYmin,'string')),str2double(get(figUIobj.VYmax,'string'))]);
                set(figUIobj.VYmax,'BackGroundColor','g')
                set(figUIobj.VYmin,'BackGroundColor','g')
                set(figUIobj.CYmax,'BackGroundColor','w')
                set(figUIobj.CYmin,'BackGroundColor','w')
            case 1 %Iplot
                set(figUIobj.axes1,'Ylim',[str2double(get(figUIobj.CYmin,'string')),str2double(get(figUIobj.CYmax,'string'))]);
                set(figUIobj.VYmax,'BackGroundColor','w')
                set(figUIobj.VYmin,'BackGroundColor','w')
                set(figUIobj.CYmax,'BackGroundColor','g')
                set(figUIobj.CYmin,'BackGroundColor','g')
        end
end
ch_ButtonColor(hObject,[],'g')
end

%%



%% Plot Windows for AI1/AI2
function AI12Set(hObject, ~)
global FigAI12

FigPlotInfo.pos = [455,530,700,200];
FigPlotInfo.name = 'AI1 / AI2';%%%%%
FigPlotInfo.fignum = 2;
FigPlotInfo.title = 'V-DATA';%%%%%
FigPlotInfo.ylabel = 'mV';%%%%%
FigPlotInfo.col = 'b';


switch get(hObject, 'value')
    case 1 % button ON: open Window
        set(hObject,'BackGroundColor','g')
        FigAI12 = OpenClosePlots(hObject, FigPlotInfo, 1);
    case 0 % button OFF: close Window
        set(hObject,'BackGroundColor',[0.9400 0.9400 0.9400]);
        close(FigPlotInfo.fignum)
end
end

%% Plot Windows for PhotoSensor(AI3)
function PhotoSencerSet(hObject, ~)
global FigPhoto

FigPlotInfo.pos = [455,400,700,110];
FigPlotInfo.name = 'Photo Sensor';
FigPlotInfo.fignum = 3;
FigPlotInfo.title = 'Live Plots';%%%
FigPlotInfo.ylabel = 'V';%%%

switch get(hObject, 'value')
    case 1 % button ON: open Window
        set(hObject,'BackGroundColor','g')
        FigPhoto = OpenClosePlots(hObject, FigPlotInfo, 1);
    case 0 % button OFF: close Window
        set(hObject,'BackGroundColor',[0.9400 0.9400 0.9400]);
        close(FigPlotInfo.fignum)
end
end

%%
function RotarySet(hObject, ~)
global FigRot

FigPlotInfo.pos = [455, 230, 700, 150];
FigPlotInfo.name = 'Rotory Encoder';
FigPlotInfo.fignum = 4;
FigPlotInfo.title = 'Rotary Encoder';
FigPlotInfo.ylabel = 'Angle pos.(deg)';

switch get(hObject, 'value')
    case 1 % button ON: open Window
        set(hObject,'BackGroundColor','g')
        FigRot = OpenClosePlots(hObject, FigPlotInfo, 1);
    case 0 % button OFF: close Window
        set(hObject,'BackGroundColor',[0.9400 0.9400 0.9400]);
        close(FigPlotInfo.fignum)
end
end
%%
function LivePlotSet(hObject, ~)
% open Live Plot window
global FigLive

FigPlotInfo.pos = [455, 10, 700, 200];
FigPlotInfo.name = 'Live Plots';
FigPlotInfo.fignum = 5;
FigPlotInfo.title = 'Live Plots';
FigPlotInfo.ylabel = 'TTLs Monitor(V)';

switch get(hObject, 'value')
    case 1 % button ON: open Window
        set(hObject,'BackGroundColor','g')
        FigLive = OpenClosePlots(hObject, FigPlotInfo, 4);
    case 0 % button OFF: close Window
        set(hObject,'BackGroundColor',[0.9400 0.9400 0.9400]);
        close(FigPlotInfo.fignum)
end
end

%%
function hGui = OpenClosePlots(handle, FigPlotInfo, num_plots)
% open new plot fig
hGui.fig = figure(FigPlotInfo.fignum);
set(hGui.fig, 'Position', FigPlotInfo.pos, 'Name', FigPlotInfo.name, 'Menubar','none', 'Resize','off');
set(hGui.fig, 'DeleteFcn', {@FigOff, handle});
hGui.axes = axes('Units', 'Pixels');%, 'Position', FigPlotInfo.pos);

if num_plots > 1
    hGui.button = cell(1, num_plots);
    for ii = 1:num_plots
        hGui.button{1, ii} = uicontrol('style','togglebutton','string',['AI:',num2str(ii)],'position',[595 150-(35*(ii-1)) 50 30],'Horizontalalignment','center');
        set(hGui.button{1, ii}, 'callback', {@ch_ButtonColor, 'g'});
        if ii == 4
            set(hGui.button{1,ii},'value',1, 'BackGroundColor','g')
        end
    end
end

if isfield(FigPlotInfo,'col') % if line color is not defined
    hGui.plot = plot(0, zeros(1, num_plots), FigPlotInfo.col);
else
    hGui.plot = plot(0, zeros(1, num_plots));
end

title(FigPlotInfo.title);
xlabel('Time (s)');
ylabel(FigPlotInfo.ylabel);

end
%%
function FigOff(~, ~, handle)
% close the fig
if ishandle(handle)
    set(handle, 'value', 0 ,'BackGroundColor',[0.9400 0.9400 0.9400]);
end
end
%%

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
function ch_save(hObject,~)
% change save mode, SAVE/UNSAVE

global recobj

switch get(hObject,'value')
    case 1
        set(hObject,'string','Saving')
        if isfield(recobj,'fname')==1 && ischar(recobj.fname)
        else
            SelectSaveFile;
        end
    case 0
        if recobj.fopenflag == 1
            fclose(recobj.fid);
            recobj.fopenflag = 0;
        end
end

ch_ButtonColor(hObject,[],'g');
end

%%
function SelectSaveFile(~, ~)
global recobj
if isfield(recobj,'dirname') == 0 % 1st time to define filename
    [recobj.fname,recobj.dirname] = uiputfile('*.*');
else %open the same folder when any foder was selected previously.
    recobj.fname = uiputfile('*.*','Select File to Write',recobj.dirname);
end

pat = regexptranslate('wildcard', '.*');%delete extention
if recobj.fname ~= 0
    recobj.fname = regexprep(recobj.fname, pat,'');
end

%assignin('base','recobj', recobj)
end
%%

