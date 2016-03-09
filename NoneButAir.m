%%%%%%%%%%%%%%%%%%%%%
%%%%%     None But Air     %%%%%%
%%%%%%%%%%%%%%%%%%%%%
% visual stimlus controller and recording elechtrical data

sca;% Screen Close ALL for PTB
clear;
close all;
%% Reset DAQ
daq.reset
%%
global sobj
global recobj
global figUIobj
global floop
global s
global dio
global lh
global capture

%% parameter setting
floop = 1;
parameter_set;

%% cycle number counter set 0
recobj.cycleNum = 0 - recobj.prestim; %loop cycle number

%% open Window PTB %%
PsychDefaultSetup(2);

[sobj.wPtr, sobj.RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.ScrCenterX, sobj.ScrCenterY]= RectCenter(sobj.RECT);% center positionof of stim monitor
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate',sobj.ScrNum);
if sobj.frameRate ==0
    sobj.frameRate = 75;
end
sobj.duration = sobj.flipNum*sobj.m_int;% sec

%%
%open GUI window
figUIobj = gui_window3(s, dio); %loop ÇÕ Ç±ÇÃíÜÇ≈éQè∆ÇµÇƒÇÈ main_looping

%% DAQ capture settings
% Specify triggered capture timespan, in seconds
capture.TimeSpan = recobj.rect/1000;% sec
% Specify continuous data plot timespan, in seconds
capture.plotTimeSpan = 0.5;
% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;

% Determine required buffer timespan, seconds
%capture.bufferTimeSpan = max([capture.TimeSpan, callbackTimeSpan*2]);
capture.bufferTimeSpan=capture.TimeSpan*2;

% Determine data buffer size
capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);

lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj,s, dio));
%%