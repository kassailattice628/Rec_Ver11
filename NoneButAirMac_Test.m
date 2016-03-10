  %%%%%%%%%%%%%%%%%%%%%
%%%%%     None But Air_ Visual Stim Test on OSX     %%%%%%
%%%%%%%%%%%%%%%%%%%%%
% visual stimlus controller and recording elechtrical data

sca;% Screen Close ALL for PTB
clear;
close all;
%% Reset DAQ
%daq.reset
%%
global sobj
global recobj
global figUIobj
global FigRot
FigRot=[];
global FigLive
FigLive=[];
global floop
global s
global dio
%Rotary

%% parameter setting
floop = 1;
parameter_setMac;

%% cycle number counter set 0
recobj.cycleNum = 0 - recobj.prestim; %loop cycle number

%% open Window PTB %%
%PsychDefaultSetup(2);

[sobj.wPtr, RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.ScrCen1terX, sobj.ScrCenterY]= RectCenter(RECT);% center positionof of stim monitor
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate',sobj.ScrNum);
if sobj.frameRate ==0
    sobj.frameRate = 75;
end
sobj.duration = sobj.flipNum*sobj.m_int;% sec

%%
Screen('CloseAll');
figUIobj = gui_window3(s, dio); %loop ÇÕ Ç±ÇÃíÜÇ≈éQè∆ÇµÇƒÇÈ main_looping

%check_duration2;