%parameter settings;
global sobj
global recobj
global dev
global s
global sTrig
%global sTrig2
%global InCh %for Analog Input Channel


%% NBA version
recobj.NBAver = 11;%Mac Test Version

%% 電気記録と記録サイクル関係
recobj.interval = 1; %loop interval(s);
recobj.sampt = 200; %samplingtime(100us)
recobj.sampf = 10^6/recobj.sampt; %samoling rate (Hz)
recobj.rect = 2*1000; %recording time (1s<-1000ms)
recobj.recp = recobj.sampf*recobj.rect/1000;
recobj.rectaxis = (0:recobj.sampt/1000:(recobj.recp-1)/recobj.sampf*1000)';%time axis (ms)

recobj.plot = 1; %V/I plot, 1: V plot, 2: I plot
recobj.yaxis = 0;%0: fix y axis, 1: auto
recobj.yrange = [-100, 30, -5, 3];%[Vmin, Vmax, Cmin, Cmax]
recobj.prestim = 2; % recobj.prestim * recobj.rect (ms) は 刺激なしの blank loop
recobj.fopenflag = 0;
%
recobj.dataall = zeros(recobj.recp,3);%AI channel ３つ分

%elec stim
recobj.EOf = 0;
recobj.OutData = zeros(recobj.recp,2); %矩形波データ
recobj.pulseAmp = 0.1; %刺激amp(nA)
recobj.pulseDelay = 0.2; %sec
recobj.pulseDuration = 0.2; %sec

%step
%recobj.stepVC = [0,100,10;0,0.5,0.1];%[Vstart,Vend,Vstep;Cstart,Cend,Cstep]; (mV) and (nA)
recobj.stepCV = [0,0.5,0.1;0,100,10];%[Cstart,Cend,Cstep;Vstart,Vend,Vstep]; (nA) and (mV)
recobj.stepAmp = 0:0.1:0.5;%Cstep

%DAQoutput gain Axoclamp2B, head stage gain (H) = *0.1
%[(current pulse gain:ME1 cmd output(10*H nA/V)), (voltage pulse gain)]:
%[1V 入れると 20 mV(=0.02V)出る
recobj.gain = [1, 0.05]; %for Axoclamp2B Command V output, [ME1 cmd output(10*H nA/V), VC cmd output(20 mV/V)]; % 

%% PTB関係
%scrsz=get(0,'ScreenSize');
MP = get(0,'MonitorPosition');%position matrix for malti monitors
screens = Screen('Screens');
sobj.ScrNum = max(screens);% 0: main, 1,2,...: sub(刺激提示用）, !!Windwos, 1:main,2....sub
if sobj.ScrNum == 0
    sNum = sobj.ScrNum+1;
else
    sNum = sobj.ScrNum;
end
%%
sobj.ScreenSize = [MP(sNum,3)-MP(sNum,1)+1, MP(sNum,4)-MP(sNum,2)+1];%monitor size of stim monitor
%sobj.ScreenSize = [MP(sNum,3),MP(sNum,4)];%for Windows8
% monitor にあわせる．DeLL 19 inch の場合
sobj.pixpitch = 0.264;%(mm) <- Mac だと？とりあえずこのまま
sobj.MonitorDist = 300;%(mm) = distance from moniter to eye, => sobj.MonitorDist*tan(1*2*pi/360)/sobj.pixpitch でpixel/degree

sobj.stimsz = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist));% default は 1度
sobj.shapelist = [{'FillRect'};{'FillOval'}];
sobj.shape = 'FillOval'; %初期設定はOvalに変更
sobj.pattern = 'Uni'; %uniform or Grating
%sobj.filter = 1;%1: None, 2: Gabor patch
sobj.div_zoom = 5;
sobj.flipNum = 75;
sobj.divnum = 2;
sobj.black = BlackIndex(sobj.ScrNum);
sobj.white = WhiteIndex(sobj.ScrNum);
sobj.gray = round((sobj.white+sobj.black)/2);
sobj.stimlumi = sobj.white;
sobj.bgcol = sobj.black;
if sobj.gray == sobj.stimlumi
    sobj.gray = sobj.white/2;
end
sobj.delayPTBflip = 20; %delay flip number
sobj.delayPTB = 0;% PTBflip * m_int だけど
sobj.stimRGB = [1,1,1];
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

%%%VS2%%%%
sobj.stimsz2 = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist));% default は 1度
sobj.shape2 = 'FillOval'; %初期設定はOvalに変更
sobj.stimlumi2 = sobj.white;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
sobj.flipNum2 = 75;
sobj.delayPTBflip2 = 20; %delay flip number
sobj.delayPTB2 = 0;% PTBflip * m_int だけど
recobj.delayTTL2 = 0;
%計測時間値（変数宣言のみ）
recobj.tTTL2=0;
recobj.tRec=0;
sobj.tPTBon=0;
sobj.tPTBoff=0;
sobj.tPTBon2=0;
sobj.tPTBoff2=0;

sobj.fixpos = 1;

sobj.shiftSpd2 = 2;%Hz
sobj.shiftSpd_list = [0.5; 1; 2; 4; 8];%Hz

sobj.gratFreq2 = 0.08;% cycle/degree
sobj.gratFreq_list = [0.01;0.02;0.04;0.08;0.16;0.32];

sobj.shiftDir = 1;%1~8:方向, 9: 8 方向random, 10: 4方向random
sobj.angle = 0;%savedata用
sobj.angle_deg = linspace(0, 315,8);
sobj.angle16_deg = linspace(0,337.5,16);

sobj.dist = 15; %distance(degree) for 2nd stimulus for lateral inhibition

sobj.position = 0;
sobj.position_cord = zeros(1,4);
sobj.position_cord2 = zeros(1,4);
sobj.stim2_center = zeros(1,2);
sobj.dist_pix = 0;

%Zoom and Fine mapping
sobj.zoom_dist = 0;
sobj.zoom_ang = 0;
%check_zoom;

%Image presentation
sobj.img_i = 0;
sobj.ImageNum = 256;
sobj.list_img = 1:sobj.ImageNum;

%%
dev = [];
%% Session Based DAQ <- not use in MAC_Test ver
%{
dev = daq.getDevices;
s = daq.createSession(dev.Vendor.ID);

s.Rate = recobj.sampf;
s.DurationInSeconds = recobj.rect/1000;%sec %outputchannel いれると自動でs.scansqued/s.rate に設定される．
s.NotifyWhenDataAvailableExceeds = recobj.recp;

InCh = addAnalogInputChannel(s, dev.ID, 0:2, 'Voltage');%(1):Vm, (2):Im, (3):photo sensor
InCh(1).TerminalConfig = 'Differential';%SingleEnded から Differential に変更した．
InCh(2).TerminalConfig = 'Differential';
InCh(3).TerminalConfig = 'Differential';

%{
OutCh = addAnalogOutputChannel(s, dev.ID, 0:1,'Voltage');
%(1):Curretn Pulse (C clamp)
%(2):Voltage Pulse (V clamp)
%}

% PFI0 can be used as AI start in NI-DAQ.
% P0.0 is Trigger source, PFI0 is Trigger Destination.
addTriggerConnection(s,'External',[dev.ID,'/PFI0'],'StartTrigger');
s.Connections(1).TriggerCondition = 'RisingEdge';
% generate event listener for Background recording
lh = addlistener(s, 'DataAvailable', @RecPlotData2);
stop(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for digital Trigger
sTrig = daq.createSession(dev.Vendor.ID);
addDigitalChannel(sTrig, dev.ID, 'port0/line0:2', 'OutputOnly');
%0:Trig NIDAQ -> connect to start digidata
%1:FV start Timing -> not used in Toku exp 
%2:Stimulus is Stim On Timing -> connect to Ch0 of digidata

outputSingleScan(sTrig,[0,0,0]); %reset trigger signals at Low

% digital Trigger for Opto driver
%line3: connect to Laser Driver
sTrig2 = daq.createSession(dev.Vendor.ID);
addDigitalChannel(sTrig2, dev.ID, 'port0/line3', 'OutputOnly');
outputSingleScan(sTrig2,0); %reset trigger signals at Low

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}