function [varargout] = daq_ini
% initialize daq device configurations
% set daq sessions
global recobj

%%
dev = daq.getDevices;

%% Analog Input
s = daq.createSession(dev.Vendor.ID);

s.Rate = recobj.sampf;
s.DurationInSeconds = recobj.rect/1000;%sec

%when AO channel is set, s.DurationInSeconds is replaced with 's.scansqued/s.rate'.
%s.NotifyWhenDataAvailableExceeds = recobj.recp; %10 times/sec in default
s.IsContinuous = true;

%(1):AI0Vm, (2):Im, (3):photo sensor, (4):Trigger pulse
InCh = addAnalogInputChannel(s, dev.ID, 0:3, 'Voltage');

% default SingleEnded, -> DifferentialÅD
InCh(1).TerminalConfig = 'Differential';
InCh(2).TerminalConfig = 'Differential'; 
InCh(3).TerminalConfig = 'Differential';
% Channle4 is used for hardware timing.
InCh(4).TerminalConfig = 'Differential';

%% Analog Output
%{
sOut = daq.createSession(dev.Vendor.ID);
sOut.Rate = recobj.sampf;
addAnalogOutputChannel(sOut, dev.ID, 0, 'Voltage');
%(1):
%(2): Curretn Pulse (C clamp), Voltage Pulse (V clamp)
addTriggerConnection(sOut,'External',[dev.ID,'/PFI0'],'StartTrigger');
sOut.Connections(1).TriggerCondition = 'RisingEdge';
%}

%% Digital Output
%P0.1:Start FV or Digidata
dio.TrigAIFV = daq.createSession(dev.Vendor.ID);
addDigitalChannel(dio.TrigAIFV, dev.ID, 'port0/line0:1', 'OutputOnly');
outputSingleScan(dio.TrigAIFV,[0,0]);%reset trigger signals at Low

%P0.2:Visual Stimulus On Timing
dio.VSon = daq.createSession(dev.Vendor.ID);
addDigitalChannel(dio.VSon, dev.ID, 'port0/line2', 'OutputOnly');
outputSingleScan(dio.VSon,0); %reset trigger signals at Low

%P0.3:
dio.TTL3 = daq.createSession(dev.Vendor.ID);
addDigitalChannel(dio.TTL3, dev.ID, 'port0/line3', 'OutputOnly');
outputSingleScan(dio.TTL3,0); %reset trigger signals at Low

%if other digital outputs will be needed, the code is here.

%% for Rotary Encoder
sRot = addCounterInputChannel(s, dev.ID, 'ctr0', 'Position');
sRot.EncoderType='X4'; %decode mode:X1, X2, X4, 'X4' is the most fine mode.

%% DAQ capture settings
% Specify triggered capture timespan, in seconds
capture.TimeSpan = recobj.rect/1000;% sec

% Specify continuous data plot timespan
capture.plotTimeSpan = 2; %sec

% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;

% Determine required buffer timespan, seconds
capture.bufferTimeSpan = max([capture.TimeSpan * 3, callbackTimeSpan * 3]);

% Determine data buffer size
capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);

%%
varargout{1,1} = s;
varargout{1,2} = sOut;
varargout{1,3} = dio;
varargout{1,4} = capture;
varargout{1,5} = dev;
