function NoneButAir11(Testmode, Recmode)
% %%%%%%%%%%%%%%%%%%%%%%%%
% %%%% None But Air %%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%
% visual stimlus controller and recording elechtrical data

%%
global sobj % keep stimulus parameters
global recobj % keep recording parameters

global figUIobj % keep figure parameters
global plotUIobj % kepp plot window parameters

global s % Analog recording session object, DAQ toolbox
global sOut % Analog output session object, DAQ toolbox

global dio % Digital session object, DAQ toolbox

global dev % NI device object

global capture % Continuous plot params
global lh % Event listener handle of AI recording

%% Initialize recording params
recobj = recobj_ini(Recmode);

% cycle number counter set 0
recobj.cycleNum = 0 - recobj.prestim; %loop cycle number

%% Initialize Stimulus params

% monitor dependent prameter (DeLL 19-inch)
pixpitch = 0.264;%(mm)
sobj = sobj_ini(pixpitch);

%% Initialize DAQ params
if Testmode == 0
    % Reset DAQ
    daq.reset
    % NI DAQ params
    [s, sOut, dio, capture, dev] = daq_ini;
end
%% open Window PTB %%
%PsychDefaultSetup(2);

%[sobj.wPtr, sobj.RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.wPtr, sobj.RECT] = PsychImaging('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.ScrCenterX, sobj.ScrCenterY] = RectCenter(sobj.RECT);% center positionof of stim monitor
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate',sobj.ScrNum);
if sobj.frameRate == 0
    sobj.frameRate = 75;
end
sobj.duration = sobj.flipNum * sobj.m_int;% sec

%% open GUI window
if sobj.Num_screens == 1
    %Single monitor condition
    Screen('Close', sobj.wPtr);
end
figUIobj = gui_window4(Testmode, Recmode);
plotUIobj = plot_window(figUIobj, Recmode);

%% DAQ Event Listener used in AI rec
if Testmode == 0
    lh = addlistener(s, 'DataAvailable', @(src,event)dataCaptureNBA(src, event, capture, figUIobj, get(figUIobj.plot,'value')));
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
