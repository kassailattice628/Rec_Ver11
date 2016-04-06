function NoneButAir11_03(Testmode)
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%%% None But Air %%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%
% visual stimlus controller and recording elechtrical data

%%
global sobj %save
global recobj %save
global figUIobj %save
global plotUIobj
global s
global sTTL
global dev
global dio
global capture
global lh

%% Initialize recording params
recobj = recobj_ini;
% cycle number counter set 0
recobj.cycleNum = 0 - recobj.prestim; %loop cycle number

%% Initialize Stimulus params

% monitor dependent prameter (DeLL 19-inch)
pixpitch = 0.264;%(mm)
sobj = sobj_ini(Testmode, pixpitch); %i=0:test, i=1:working

%% Initialize DAQ params
if Testmode == 0
    % Reset DAQ
    daq.reset
    % NI DAQ params
    [s, sTTL, dio, capture, dev] = daq_ini;
    %disp(s)
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
if Testmode == 1
    %sca;
    Screen('Close', sobj.wPtr);
end
figUIobj = gui_window4(Testmode);
plotUIobj = plot_window(figUIobj);

%% DAQ Event Listener used in AI rec
if Testmode == 0
    lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj, get(figUIobj.plot,'value')));
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables check %
% open @base workspace

%assignin('base', 'sobj',sobj)
%assignin('base', 'recobj',recobj)
%assignin('base', 'figUIobj',figUIobj)
%assignin('base', 'RecData', RecData)
%assignin('base', 'capture', capture)
%assignin('base', 'lh', lh)
%assignin('base', 's', s)
%assignin('base', 'dio', dio)