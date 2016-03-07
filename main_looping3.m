%function main_looping3
%%%%%%%%%%%%%%%%
% recording is start by softaware-analog trigger
% 3 or 4 AI channels are used.
% AI0, AI1, AI2 is, electrical 1, 2, and photosensor, respectively
% AI3 is used for soft-analog trigger
%%%%%%%%%%%%%%%
% modified from softwareAnalogTriggerCaputre.m
% -> softwareAnalogTriggerCapture DAQ data capture using software-analog triggering
%   softwareAnalogTriggerCapture launches a user interface for live DAQ data
%   visualization and interactive data capture based on a software analog
%   trigger condition.
%%%%%%%%%%%%%%%

%% initialize parameters
recobj.NBAver = 'Ver_11_dev';

% Analog Rec parameters
recobj.interval = 1; %loop interval(s);
recobj.sampt = 200; %samplingtime(us);
recobj.sampf = 10^6/recobj.sampt; %samoling rate (Hz)
recobj.rect = 2*1000; %recording time (s)
recobj.recp = recobj.sampf*recobj.rect/1000; %number of scans
%I want to use event.time
recobj.rectaxis = (0:recobj.sampt/1000:(recobj.recp-1)/recobj.sampf*1000)';%time axis (ms)

% select data shown
recobj.plot = 1; %V/I plot, 1: V plot, 2: I plot
recobj.yaxis = 0;%0: fix y axis, 1: auto
recobj.yrange = [-100, 30, -5, 3];%[Vmin, Vmax, Cmin, Cmax]

%
recobj.prestim = 2; % # of no-stim loops.
recobj.fopenflag = 0;

% [time; AI0(Vm); AI1(Im); AI2(Photosensor); AI3(Trig monitor + Vis timing)]
recobj.dataall = zeros(recobj.recp,4);%

% Analog output
recobj.EOf = 0;
recobj.OutData = zeros(recobj.recp,2); %initialize output data
recobj.pulseAmp = 0.1; %刺激amp(nA)
recobj.pulseDelay = 0.2; %sec
recobj.pulseDuration = 0.2; %sec
% for step
recobj.stepCV = [0,0.5,0.1; 0,100,10];%[Cstart,Cend,Cstep;Vstart,Vend,Vstep]; (nA) and (mV)
recobj.stepAmp = 0:0.1:0.5;%Cstep
% DAQoutput gain Axoclamp2B, head stage gain (H) = *0.1
% [(current pulse gain:ME1 cmd output(10*H nA/V)), (voltage pulse gain)]:
% 1V -> 20 mV(=0.02V)
recobj.gain = [1, 0.05]; %for Axoclamp2B Command V output, [ME1 cmd output(10*H nA/V), VC cmd output(20 mV/V)]; %


 %% PTB and visual stimuli parameters
 MP = get(0,'MonitorPosition');%position matrix for malti monitors
 screens = Screen('Screens');
 sobj.ScrNum = max(screens);% 0:
 if sobj.ScrNum == 0
     sNum = sobj.ScrNum+1;
 else
     sNum = sobj.ScrNum;
 end
 sobj.ScreenSize = [MP(sNum,3),MP(sNum,4)];%for Windows8

 sobj.pixpitch = 0.264;%(mm)
 sobj.MonitorDist = 300;%(mm) = distance from moniter to eye, => sobj.MonitorDist*tan(1*2*pi/360)/sobj.pixpitch :pixel/degree

 sobj.stimsz = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist));% default is 1 deg
 sobj.shapelist = [{'FillRect'};{'FillOval'}];
 sobj.shape = 'FillOval';
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
 sobj.delayPTB = 0;% PTBflip * m_int
 sobj.stimRGB = [1,1,1];
 sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

 %%%VS2%%%%
 sobj.stimsz2 = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist));% default is 1 deg
 sobj.shape2 = 'FillOval';
 sobj.stimlumi2 = sobj.white;
 sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
 sobj.flipNum2 = 75;
 sobj.delayPTBflip2 = 20; %delay flip number
 sobj.delayPTB2 = 0;% PTBflip2 * m_int

 %%%TTL timing%%
 recobj.delayTTL2 = 0;
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
 sobj.gratFreq_list = [0.01; 0.02; 0.04; 0.08; 0.16; 0.32];

 sobj.shiftDir = 1;%1~8:����, 9: 8 ����random, 10: 4����random
 sobj.angle = 0;%savedata�p
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
 check_zoom;

 %Image presentation
 sobj.img_i = 0;
 sobj.ImageNum = 256;
 sobj.list_img = 1:sobj.ImageNum;



%% initialize DAQ settings
daq.reset

% Configure data acquisition session and add analog input channels
dev = daq.getDevices;
s = daq.createSession(dev.Vendor.ID);%s = daq.createSession('ni');
InCh = addAnalogInputChannel(s, dev.ID, 0:3, 'Voltage');%(1):Vm, (2):Im, (3):photo sensor

% Set acquisition configuration for each channel
InCh(1).TerminalConfig = 'Differential'; %default:'SingleEnded', used for Vm
InCh(2).TerminalConfig = 'Differential'; %used for Im
InCh(3).TerminalConfig = 'Differential'; %used for photo sensor
InCh(4).TerminalConfig = 'Differential'; %used as software-analog trigger and visual stimulus timing


% add analog output channels for electrical stimulation
%(1):Curretn Pulse (C clamp)
%(2):Voltage Pulse (V clamp)
%OutCh = addAnalogOutputChannel(s, dev.ID, 0:1,'Voltage');

% Set acquisition rate, in scans/second
s.Rate = recobj.sampf;
s.DurationInSeconds = recobj.rect/1000;%sec, %After "outputchannel" is set, s.scansqued/s.rate is same to this parameter.

s.NotifyWhenDataAvailableExceeds = recobj.recp;%This is important in capturing (saving) data

% Specify the desired parameters for data capture and live plotting.
% The data capture parameters are grouped in a structure data type,
% as this makes it simpler to pass them as a function argument.

% Specify triggered capture timespan, in seconds
capture.TimeSpan = recobj.rect/1000;

% Specify continuous data plot timespan, in seconds
capture.plotTimeSpan = recobj.rect/1000;

% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;

% Determine required buffer timespan, seconds ３倍しているのはなぜ？
% capture.plotTimeSpan は continuous で表示する時間
% capture.TimeSpan は trigger 後に capture する時間
% callbackTimeSpan は AI に取り込んだデータが available になったあと
capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan * 3, callbackTimeSpan * 3]);
% Determine data buffer size
capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);

% GUI の表示と  data の取得開始
% Display graphical user interface
hGui = createDataCaptureUI(s);

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
dataListener = addlistener(s, 'DataAvailable', @(src,event) dataCapture(src, event, capture, hGui));
dataListener2 = addlistener(s, 'ErrorOccurred', @(src,event), disp(getReport(event.Error)));

% Add a listener for acquisition error events which might occur during background acquisition
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

% Start continuous background data acquisition
s.IsContinuous = true;
startBackground(s);

% Wait until session s is stopped from the UI
while s.IsRunning
    pause(0.5);
end

delete(dataListener);
delete(errorListener);
delete(s);
end
