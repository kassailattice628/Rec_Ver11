function hGui = gui_window3(s, sTrig)
%gui_window3 creates a None But Air Graphical User Interface
% hGui = gui_window3(s, sTrig) returns a structure of graphics components
% handles (hGui) and create a GUI for PTB visual stimuli, data acquisition
% from a DAQ session (s), and control TTL output

global sobj
global recobj

%% %---------- Create GUI window ----------%
%open GUI window
hGui.F1 = figure('Position',[10, 20, 1000, 750], 'Name','None But Air','Menubar','none');

%set GUI components
hGui.ONSCR = uicontrol('style','pushbutton','string','OpenScreen','position',[5 705 80 30],'Horizontalalignment','center');
set(hGui.ONSCR,'Callback', {@OpenSCR, sobj});
hGui.CLSCR = uicontrol('style','pushbutton','string','CloseScreen','position', [5 670 80 30],'Horizontalalignment','center');
set(hGui.CLSCR, 'Callback',{@CloseSCR, sobj});

hGui.stim=uicontrol('style','togglebutton','position',[110 705 100 30],'string','Stim-OFF','callback',@stimON,'Horizontalalignment','center');
%main_loopingtest
hGui.loop=uicontrol('style','togglebutton','position',[110 670 100 30],'string','Loop-OFF','callback',@loopON,'BackGroundColor','r');

hGui.EXIT=uicontrol('string','EXIT','position',[350 705 50 30],'FontSize',12,'Horizontalalignment','center');
set(hGui.EXIT, 'CallBack', {@quit_NBA, s, sTrig, sobj});

%%
%stim state monitor% %%
hGui.StimMonitor1=uicontrol('style','text','position',[230 670 100 20], 'string','','FontSize',12,'BackGroundColor','w');
hGui.StimMonitor2=uicontrol('style','text','position',[230 690 100 25], 'string','OFF','FontSize',12,'BackGroundColor','w','Horizontalalignment','center');
hGui.StimMonitor3=uicontrol('style','text','position',[230 715 100 20], 'string','','FontSize',12,'BackGroundColor','w');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli1 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','Vis. Stim.1','FontSize',12,'Position',[0.005 0.013 0.195 0.87]);

uicontrol('style','text','position',[10 620 90 15],'string','Mode (Position)','Horizontalalignment','left');
hGui.mode=uicontrol('style','popupmenu','position',[10 600 90 20],'string',[{'Random'},{'Fix_Rep'},{'Ordered'}]);
set(hGui.mode, 'callback',{@ch_position, hGui});

%stim_pattern2
uicontrol('style','text','position',[105 620 70 15],'string','Stim.Pattern','Horizontalalignment','left');
hGui.pattern=uicontrol('style','popupmenu','position',[105 600 90 20],'string',[{'Uni'},{'BW'},{'Sin'},{'Rect'},{'Gabor'},{'Sz_r'},{'Zoom'},{'2Stim'},{'Images'}]);
set(hGui.pattern, 'callback', @stim_pattern);
%%%%%% New stimulus patterns will be added this list and, change stim_pattern and "visual stimulus.m".

%%% %%%
uicontrol('style','text','position',[10 575 60 15],'string','Stim.Shape','Horizontalalignment','left');
hGui.shape=uicontrol('style','popupmenu','position',[10 555 75 20],'string',[{'Rect'},{'Circle'}]);
set(hGui.shape, 'callback',@ch_shape);
set(hGui.shape, 'value', 2); % default: 'FillOval'

uicontrol('style','text','position',[90 575 45 15],'strin','Div.Zoom','Horizontalalignment','left');
hGui.div_zoom=uicontrol('style','edit','position',[90 550 40 25],'string',sobj.div_zoom,'BackGroundColor','w');
set(hGui,'callback',@ch_zoom);

%distance from the center point
uicontrol('style','text','position',[140 575 50 15],'string','Dist(deg)','Horizontalalignment','left');
hGui.dist=uicontrol('style','edit','position',[140 550 40 25],'string',sobj.dist,'BackGroundColor','w');
set(hGui.dist, 'callback',@ch_zoom);

%%% Luminance %%%
uicontrol('style','text','position',[10 530 55 15],'string','Stim.Lumi','Horizontalalignment','left');
hGui.stimlumi=uicontrol('style','edit','position',[10 505 45 25],'string',sobj.stimlumi,'BackGroundColor','w');
set(hGui.stimlumi, 'callback',@ch_lumi);

uicontrol('style','text','position',[65 530 45 15],'string','BG.Lumi','Horizontalalignment','left');
hGui.bgcol=uicontrol('style','edit','position',[65 505 45 25],'string',sobj.bgcol,'callback','sobj.bgcol = re_write(hGui.bgcol);check_lumi2','BackGroundColor','w');

uicontrol('style','text','position',[120 530 40 15],'string','Lumi','Horizontalalignment','left');
hGui.lumi=uicontrol('style','popupmenu','position',[120 510 75 20],'string',[{'Fix'},{'Rand'}],'callback','Random_luminance');

%%%%% Durtion %%%
uicontrol('style','text','position',[10 480 65 15],'string','Stim.Duration','Horizontalalignment','left');
hGui.flipNum=uicontrol('style','edit','position',[10 455 30 25],'string',sobj.flipNum,'callback','sobj.flipNum = re_write(hGui.flipNum);check_duration2;','BackGroundColor','w');
sobj.duration = sobj.flipNum*sobj.m_int;
hGui.stimDur = uicontrol('style','text','position',[45 455 75 15],'string',['flips = ',num2str(floor(sobj.duration*1000)),' ms'],'Horizontalalignment','left');


%%% RGB %%% sobj.stimRGB
uicontrol('style','text','position',[120,480,70,15],'string','Stim.RGB','Horizontalalignment','left');
hGui.stimRGB = uicontrol('style','popupmenu','position',[120,455,70,25], 'string',[{'BW'},{'Blu'},{'Gre'},{'Yel'},{'Red'}],'callback','check_stimRGB;');


%%% DelayPTB
uicontrol('style','text','position',[10 430 75 15],'string','PTB delay flip ','Horizontalalignment','left');
hGui.delayPTBflip = uicontrol('style','edit','position',[10 405 30 25],'string',sobj.delayPTBflip,'callback','sobj.delayPTBflip = re_write(hGui.delayPTBflip); check_duration2','BackGroundColor','w');
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
hGui.delayPTB = uicontrol('style','text','position',[45 405 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB*1000)),' ms'],'Horizontalalignment','left');

%%%%
uicontrol('style','text','position',[10 380 70 15],'string','Set Blank','Horizontalalignment','left');
hGui.prestimN=uicontrol('style','edit','position',[10 355 30 25],'string',recobj.prestim,'callback','blank_set;','BackGroundColor','w');
hGui.prestim=uicontrol('style','text','position',[45 355 85 15],'string',['loops = > ',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),' sec'],'Horizontalalignment','left');

%%% Size %%%%
uicontrol('style','text','position',[10 330 105 15],'string','Stim.Size (Diamiter)','Horizontalalignment','left');
hGui.size=uicontrol('style','edit','position',[10 305 50 25],'string','1','callback','sobj.stimsz = stim_size(sobj.MonitorDist,hGui.size); if(get(hGui.auto_size,''value'')==1), set(hGui.auto_size,''value'',0,''string'',''Auto OFF'');end','BackGroundColor','w');
uicontrol('style','text','position',[65 305 30 15],'string','deg','Horizontalalignment','left');
%Auto-Fill のときは，stimsz は画面を分割した場所を埋める
hGui.auto_size=uicontrol('style','togglebutton','position',[105 300 70 30],'string','Auto OFF','callback','autosizing(sobj.MonitorDist);','Horizontalalignment','center');

uicontrol('style','text','position',[10 280 70 15],'string','Monitor Div.','Horizontalalignment','left');
hGui.divnum=uicontrol('style','edit','position',[10 255 50 25],'string',sobj.divnum,'callback','sobj.divnum = re_write(hGui.divnum);autosizing(sobj.MonitorDist);ch_position;ch_Matnum(hGui.divnumN,hGui.fixposN);','BackGroundColor','w');
hGui.divnumN = uicontrol('style','text','position',[65 255 100 15],'string',['(=> ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)'],'Horizontalalignment','left');

uicontrol('style','text','position',[10 230 70 15],'string','Fixed Pos.','Horizontalalignment','left');
hGui.fixpos=uicontrol('style','edit','position',[10 205 50 25],'string',sobj.fixpos,'callback','sobj.fixpos = re_write(hGui.fixpos);ch_position;','BackGroundColor','w');
hGui.fixposN = uicontrol('style','text','position',[65 205 100 15],'string',['(<= ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)'],'Horizontalalignment','left');

%%% Rotation Direction %%
uicontrol('style','text','position',[10 180 130 15],'string','Direction (Grating, Poler)','Horizontalalignment','left');
hGui.shiftDir = uicontrol('style','popupmenu','position',[10 155 90 25],'string',[{'0'},{'45'},{'90'},{'135'},{'180'},{'225'},{'270'},{'315'},{'Order8'},{'Rand8'},{'Rand16'}],'callback','sobj.shiftDir = get(hGui.shiftDir,''value'');');
uicontrol('style','text','position',[100 160 25 15],'string','deg','Horizontalalignment','left');

%%%
uicontrol('style','text','position',[10 135 80 15],'string','Temporal Freq','Horizontalalignment','left');
hGui.shiftSpd=uicontrol('style','popupmenu','position',[10 110 80 25],'string',[{'0.5'},{'1'},{'2'},{'4'},{'8'}],'value',3,'callback','sobj.shiftSpd2 = sobj.shiftSpd_list(get(hGui.shiftSpd,''value''));','BackGroundColor','w');
uicontrol('style','text','position',[90 115 20 15],'string','Hz','Horizontalalignment','left');

uicontrol('style','text','position',[10 90 75 15],'string','Spatial Freq','Horizontalalignment','left');
hGui.gratFreq=uicontrol('style','popupmenu','position',[10 65 100 25],'string',[{'0.01'},{'0.02'},{'0.04'},{'0.08'},{'0.16'},{'0.32'}],'value',4,'callback','sobj.gratFreq2 = sobj.gratFreq_list(get(hGui.gratFreq, ''value''));','BackGroundColor','w');
uicontrol('style','text','position',[110 70 50 15],'string','cycle/deg','Horizontalalignment','left');

uicontrol('style','text','position',[10 45 70 15],'string','Monior Dist.','Horizontalalignment','left');
hGui.MonitorDist=uicontrol('style','edit','position',[10 20 50 25],'string',sobj.MonitorDist,'callback','sobj.MonitorDist = re_write(hGui.MonitorDist);sobj.stimsz = stim_size(sobj.MonitorDist,(hGui.size));','BackGroundColor','g');
uicontrol('style','text','position',[65 20 30 15],'string','mm','Horizontalalignment','left');

%%
uicontrol('style', 'text','position',[120 430 70 15],'string','# of Imgs','HorizontalAlignment','left');
hGui.ImageNum = uicontrol('style','edit','position',[120 405 40 25],'string',sobj.ImageNum,'callback','sobj.ImageNum = re_write(hGui.ImageNum);','BackGroundColor','w');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Visual stimuli2 %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%uipanel('Title','Vis. Stim.2','FontSize',12,'Position',[0.205 0.013 0.195 0.87]);
uipanel('Title','Vis. Stim.2','FontSize',12,'Position',[0.205 0.313 0.195 0.57]);

uicontrol('style','text','position',[210 620 70 15],'string','Stim.Shape2','Horizontalalignment','left');
hGui.shape2=uicontrol('style','popupmenu','position',[210 600 85 20],'string',[{'Rect'},{'Circle'}],'callback','sobj.shape2 = sobj.shapelist{get(hGui.shape2,''value''),1};');
set(hGui.shape2, 'value', 2);

%個別にパラメタを合わせるよりも，一括であわせるスクリプト呼ぶようにした
uicontrol('string','Match S2 & S1','position',[300,595 95, 30],'callback','match_stim2cond','Horizontalalignment','center');

uicontrol('style','text','position',[210 575 60 15],'string','Stim.Lumi2','Horizontalalignment','left');
hGui.stimlumi2=uicontrol('style','edit','position',[210 550 50 25],'string',sobj.stimlumi2,'callback','sobj.stimlumi2 = re_write(hGui.stimlumi2);check_lumi2','BackGroundColor','w');

uicontrol('style','text','position',[210 525 85 15],'string','Stim.Duration2','Horizontalalignment','left');
hGui.flipNum2=uicontrol('style','edit','position',[210 500 30 25],'string',sobj.flipNum2,'callback','sobj.flipNum2 = re_write(hGui.flipNum2);check_duration2;','BackGroundColor','w');
sobj.duration2 = sobj.flipNum2*sobj.m_int;
hGui.stimDur2 = uicontrol('style','text','position',[245 500 75 15],'string',['flips = ',num2str(floor(sobj.duration2*1000)),' ms'],'Horizontalalignment','left');

%%% DelayPTB2
uicontrol('style','text','position',[210 475 85 15],'string','PTB delay flip2 ','Horizontalalignment','left');
hGui.delayPTBflip2 = uicontrol('style','edit','position',[210 450 30 25],'string',sobj.delayPTBflip2,'callback','sobj.delayPTBflip2 = re_write(hGui.delayPTBflip2); check_duration2','BackGroundColor','w');
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
hGui.delayPTB2 = uicontrol('style','text','position',[245 450 75 15],'string',['flips = ',num2str(floor(sobj.delayPTB2*1000)),' ms'],'Horizontalalignment','left');


uicontrol('style','text','position',[210 425 130 15],'string','Stim.Size2 (Diamiter)','Horizontalalignment','left');
hGui.size2=uicontrol('style','edit','position',[210 400 50 25],'string','1','callback','sobj.stimsz2 = stim_size(sobj.MonitorDist,hGui.size2 );','BackGroundColor','w');
uicontrol('style','text','position',[265 400 25 15],'string','deg','Horizontalalignment','left');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%              Electrophysiology             %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','NI DAQ Setting','FontSize',12,'Position',[0.42 0.73 0.55 0.26]);
%%%
uicontrol('style','text','position',[435 695 60 15],'string','Samp.Freq','Horizontalalignment','left');
hGui.sampf=uicontrol('style','edit','position',[435 670 50 25],'string',recobj.sampf/1000,'callback','recobj.sampf = str2double(get(hGui.sampf,''string''))*1000; daqsetting;ch_plot','BackGroundColor','w');
uicontrol('style','text','position',[490 670 25 15],'string','kHz','Horizontalalignment','left');

uicontrol('style','text','position',[515 695 60 15],'string','Rec.Time','Horizontalalignment','left');
hGui.rect=uicontrol('style','edit','position',[515 670 50 25],'string',recobj.rect,'callback','recobj.rect = re_write(hGui.rect);blank_set; daqsetting;check_duration2;ch_plot','BackGroundColor','w');
uicontrol('style','text','position',[570 670 20 15],'string','ms','Horizontalalignment','left');

uicontrol('style','text','position',[595 695 70 15],'string','Loop Interval','Horizontalalignment','left');
hGui.interval=uicontrol('style','edit','position',[595 670 50 25],'string',recobj.interval,'callback','recobj.interval = re_write(hGui.interval);blank_set','BackGroundColor','w');
uicontrol('style','text','position',[650 670 25 15],'string','sec','Horizontalalignment','left');

uicontrol('style','text','position',[680 695 80 15],'string','Daq Range (V)','Horizontalalignment','left');
hGui.DAQrange=uicontrol('style','popupmenu','position',[675 670 120 25],'string',[{'x1:[-10,10]'},{'x10:[-1,1]'},{'x50:[-0.2,0.2]'},{'x100:[-0.1,0.1]'}],'value',1,'callback','ch_DaqRange');

%% % Trigger Delay or TTL Delay
uicontrol('style','text','position',[795 695 90 15],'string','Trig/TTL Delay','Horizontalalignment','left');
hGui.TTL2=uicontrol('style','togglebutton','position',[800 670 95 25],'string','FV trig','value',1,'Callback','ch_TTL2;','Horizontalalignment','left');

hGui.delayTTL2=uicontrol('style','edit','position',[900 670 40 25],'string',recobj.delayTTL2,'callback','recobj.delayTTL2 = re_write(hGui.delayTTL2);','BackGroundColor','w');
uicontrol('style','text','position',[945 670 20 15],'string','ms','Horizontalalignment','left');

%%
uicontrol('style','text','position',[435 650 55 15],'string','Plot Type ','Horizontalalignment','left');
hGui.plot=uicontrol('style','togglebutton','position',[435 625 90 30],'string','V-plot','callback','recobj.plot = get(hGui.plot, ''value'')+1;ch_plot;daqsetting');

uicontrol('style','text','position',[530 650 55 15],'string','Y-axis','Horizontalalignment','left');
hGui.yaxis=uicontrol('style','togglebutton','position',[530 625 75 30],'string',[{'Auto'},{'Fix'}],'callback','recobj.yaxis = get(hGui.yaxis,''value'');ch_plot');


uicontrol('style','text','position',[610 650 80 15],'string','V range (mV)')
hGui.VYmin = uicontrol('style','edit','position',[610 625 40 25],'string',recobj.yrange(1)','callback','recobj.yrange(1) = re_write(hGui.VYmin);ch_plot;','BackGroundColor','w');
%uicontrol('style','text','position',[],'string','VMin')
hGui.VYmax = uicontrol('style','edit','position',[655 625 40 25],'string',recobj.yrange(2)','callback','recobj.yrange(2) = re_write(hGui.VYmax);ch_plot;','BackGroundColor','w');
uicontrol('style','text','position',[705 650 80 15],'string','C range (nA)')
hGui.CYmin = uicontrol('style','edit','position',[705 625 40 25],'string',recobj.yrange(3)','callback','recobj.yrange(3) = re_write(hGui.CYmin);ch_plot;','BackGroundColor','w');
%uicontrol('style','text','position',[],'string','CMin')
hGui.CYmax = uicontrol('style','edit','position',[750 625 40 25],'string',recobj.yrange(4)','callback','recobj.yrange(4) = re_write(hGui.CYmax);ch_plot;','BackGroundColor','w');

%%% pulse %%%
hGui.pulse = uicontrol('style','togglebutton','position',[435 585 70 25],'string','Pulse OFF','Callback','pulseset;');
%Duration
uicontrol('style','text','position',[510 610 60 15],'string','Duration','Horizontalalignment','left');
hGui.pulseDuration = uicontrol('style','edit','position',[510 585 50 25],'string',recobj.pulseDuration,'callback','recobj.pulseDuration = re_write(hGui.pulseDuration); daqsetting;check_duration2;ch_plot','BackGroundColor','w');
uicontrol('style','text','position',[560 585 25 15],'string','sec','Horizontalalignment','left');

%Delay
uicontrol('style','text','position',[590 610 60 15],'string','Delay','Horizontalalignment','left');
hGui.pulseDelay = uicontrol('style','edit','position',[590 585 50 25],'string',recobj.pulseDelay,'callback','recobj.pulseDelay = re_write(hGui.pulseDelay); daqsetting;ch_plot;','BackGroundColor','w');
uicontrol('style','text','position',[640 585 25 15],'string','sec','Horizontalalignment','left');

%Amplitude
uicontrol('style','text','position',[670 610 90 15],'string','Amplitude','Horizontalalignment','left');
hGui.pulseAmp = uicontrol('style','edit','position',[670 585 50 25],'string',recobj.pulseAmp,'callback','recobj.pulseAmp = re_write(hGui.pulseAmp);check_AOrange;daqsetting;','BackGroundColor','w');
hGui.ampunit = uicontrol('style','text','position',[720 585 25 15],'string','nA','Horizontalalignment','left');
%%% preset_Testpulse Amplitude%%%
uicontrol('style','text','position',[740 610 90 15],'string','Preset(V)','Horizontalalignment','left');
hGui.presetAmp = uicontrol('style','togglebutton','position',[740 585 40 25],'string','1 mV','Callback','switch get(hGui.plot,''value''), case 1, preset_pulseAmp; end');

%Elech only
hGui.EOf = uicontrol('style','togglebutton','position',[890 700 60 30],'string','E only','Callback','SwitchETrig','FontSize',12,'Horizontalalignment','center');

%Step
%これの 0/1 を切り替えのフラグに使う
hGui.stepf = uicontrol('style','togglebutton','position',[805 645 40 25],'string','step','Callback','steppulse');
uicontrol('style','text','position',[850 650 30 15],'string','start','Horizontalalignment','left');
uicontrol('style','text','position',[885 650 30 15],'string','end','Horizontalalignment','left');
uicontrol('style','text','position',[920 650 30 15],'string','step','Horizontalalignment','left');
%

%for Current Clamp
uicontrol('style','text','position',[810 620 40 25],'string','C (nA)','Horizontalalignment','left');
hGui.Cstart = uicontrol('style','edit','position',[850 625 30 25],'string',recobj.stepCV(1,1),'callback','ch_Estep;','BackGroundColor','w');
hGui.Cend = uicontrol('style','edit','position',[885 625 30 25],'string',recobj.stepCV(1,2),'callback','ch_Estep;','BackGroundColor','w');
hGui.Cstep = uicontrol('style','edit','position',[920 625 30 25],'string',recobj.stepCV(1,3),'callback','ch_Estep;','BackGroundColor','w');

%for Voltage Clamp
uicontrol('style','text','position',[810 590 40 25],'string','V (mV)','Horizontalalignment','left');
hGui.Vstart = uicontrol('style','edit','position',[850 595 30 25],'string',recobj.stepCV(2,1),'callback','ch_Estep;','BackGroundColor','w');
hGui.Vend = uicontrol('style','edit','position',[885 595 30 25],'string',recobj.stepCV(2,2),'callback','ch_Estep;','BackGroundColor','w');
hGui.Vstep = uicontrol('style','edit','position',[920 595 30 25],'string',recobj.stepCV(2,3),'callback','ch_Estep;','BackGroundColor','w');


%%%
uicontrol('string','File Name','position', [435 550 90 30],'Callback','SelectSaveFile;','Horizontalalignment','center');
hGui.savech=uicontrol('style','popupmenu','position', [530 555 120 20],'string',[{'ALL'},{'Header Only'},{'Header&Photo'}]);
hGui.save=uicontrol('style','togglebutton','position', [655 550 70 30],'string','Unsave','Callback','ch_save');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%              Rotary Encoder            %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uipanel('Title','Rotary.Encoder','FontSize',12,'Position',[0.205 0.013 0.195 0.295]);

%Rotary Encoder ON/OFF
hGui.RotCtr = uicontrol('style','togglebutton','position',[210 185 85 30],'string','Rotary OFF','Callback','RotarySet','FontSize',12,'Horizontalalignment','center');

%%
%ch_DaqRange;
%daqsetting;
%%
%%%%%%%%%%%%%%%%%%%   Plot Window   %%%%%%%%%%%%%%%%%%%%
%場所の指定は subplot の position で指定(0-1.0 の相対値）
%uicontrol('style','frame','position',[390 30 600 610],'BackGroundColor','w');

%plot の時間軸
hGui.t = recobj.rectaxis/1000;

hGui.s2 = subplot('position', [0.46 0.35 0.52 0.35]);
set(hGui.s2,'YlimMode','Auto');
hGui.y2 = recobj.dataall(:,1);
hGui.p2 = plot(hGui.t,hGui.y2, 'XdataSource','hGui.t','YDataSource', 'hGui.y2');
title('V-DATA');
xlabel('Time (sec)');
ylabel('mV');
hGui.flash2 = line('xdata',[0 0],'ydata',[0 0],'Color','r','LineWidth',1);
hGui.flash3 = line('xdata',[0 0],'ydata',[0 0],'Color','r','LineWidth',1);


hGui.s3 = subplot('position', [0.46 0.1 0.52 0.15]);
set(hGui.s3,'YlimMode','Auto');
hGui.y3 = recobj.dataall(:,3);
hGui.p3 = plot(hGui.t,hGui.y3,'XdataSource','hGui.t','YDataSource', 'hGui.y3');
title('Photo Sensor');
xlabel('Time (sec)');
ylabel('mV');
%{
%set(hGui.s1, 'Drawmode','fast');
set(hGui.s2, 'Drawmode','fast');
set(hGui.s3, 'Drawmode','fast');
%}
%%
%ch_position;
end

%% sub functions for callback
% callback fucntions need at lest 2 parameters
% function ***(hObject, callbackdata, usr1, usr2, ...)
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
function stimON(hObject, ~)
switch get(hObject,'value');
    case 0
        set(hObject,'string','Stim-OFF','BackGroundColor',[0.701961 0.701961 0.701961]);
    case 1
        set(hObject,'string','Stim-ON','BackGroundColor','y')
end
end
%%
function loopON

end
%%
function quit_NBA(~,~, s, sTrig, sobj)
global dev
delete(s)
delete(sTrig)
if isempty(dev)
else
    daq.reset;
end
if sobj.ScrNum ~= 0
    Screen('Close', sobj.wPtr);
end
%clear windows, variables
sca;
clear all;
close all;
end
%%
function ch_shape(hObject, ~)
global sobj
switch(get(hObject, 'value'));
    case 1
        shape = 'FillRect';
    case 2
        shape = 'FillOval';
end
disp(shape);
sobj.shape = shape;
disp(sobj.shape);
end
%%
function y = re_write(handles)
y = str2double(get(handles,'string'));
end
%%
function ch_zoom(hObject, ~)
global sobj
sobj.div_zoom = re_write(hObject);
check_zoom;
end
%%
function ch_lumi(hObject, ~)
global sobj
sobj.stimlumi = re_write(hObject);
check_lumi2
end
%%


