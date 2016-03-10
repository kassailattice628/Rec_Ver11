function NoneButAir11(mode)
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%%% None But Air %%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%
% visual stimlus controller and recording elechtrical data

%%
global sobj %save
global recobj %save
global figUIobj %save
global FigRot
FigRot=[];
global FigLive
FigLive=[];
global RecData %save
RecData = [];
global dev
global s
global InCh
global dio
global sRot
global capture
global lh


%% Initialize recording params
recobj = recobj_ini;
% cycle number counter set 0
recobj.cycleNum = 0 - recobj.prestim; %loop cycle number

%% Initialize Stimulus params

% monitor dependent prameter (DeLL 19-inch)
pixpitch = 0.264;%(mm)
sobj = sobj_ini(mode, pixpitch); %i=0:test, i=1:working

%% Initialize DAQ params
if mode == 1
    % Reset DAQ
    daq.reset
    % NI DAQ params
    [dev, s, InCh, dio, sRot, capture] = daq_ini;
end
%% open Window PTB %%
%PsychDefaultSetup(2);

[sobj.wPtr, sobj.RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.ScrCenterX, sobj.ScrCenterY]= RectCenter(sobj.RECT);% center positionof of stim monitor
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate',sobj.ScrNum);
if sobj.frameRate ==0
    sobj.frameRate = 75;
end
sobj.duration = sobj.flipNum*sobj.m_int;% sec

%% open GUI window
if mode == 2
    sca;
end
figUIobj = gui_window3(s, dio); %loop �� ���̒��ŎQ�Ƃ��Ă� main_looping

%% DAQ Event Listener used in AI rec
if mode == 1
    lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj,s, dio));
end
%%
% open @base workspace
assignin('base', 'sobj',sobj)
assignin('base', 'recobj',recobj)
assignin('base', 'figUIobj',figUIobj)
assignin('base', 'RecData', RecData)
assignin('base', 'capture', capture)
assignin('base', 'lh', lh)