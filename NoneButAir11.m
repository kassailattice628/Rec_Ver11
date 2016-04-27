function NoneButAir11(Testmode, Recmode, UseCam)
% Initialize parameters and setup PTB.
%
% Initialize PTB and open 'Screens'.
% Open main GUI controler.
% Testmode: 0 or 1, when '1': DAQ is not used.
% Recmode: 1 or 2, when '1': iRecHS2, '2':Electrophysilogy

%% set global vars
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

global imaq % Camera setting

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
    [s, sOut, dio, capture, dev] = daq_ini(Recmode);
end

%% Initialize IMAQ params
imaq = imaq_ini(recobj, UseCam);

%% open Window PTB %%

%PsychDefaultSetup(2);
% usage:: [sobj.wPtr, sobj.RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.wPtr, sobj.RECT] = PsychImaging('OpenWindow', sobj.ScrNum, sobj.bgcol);

% get center position in pix of stim monitor
[sobj.ScrCenterX, sobj.ScrCenterY] = RectCenter(sobj.RECT);
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate', sobj.ScrNum);
if sobj.frameRate == 0
    sobj.frameRate = 60;
end
% set stimulus duration in sec
sobj.duration = sobj.flipNum * sobj.m_int; % sec

%% open GUI window
if sobj.Num_screens == 1
    %Single monitor condition
    Screen('Close', sobj.wPtr);
end
% open main GUI ctr window.
figUIobj = gui_window4(Testmode, Recmode, UseCam);

% open plot window.
plotUIobj = open_plot_window(figUIobj, Recmode);

%% DAQ Event Listener used in AI rec
if Testmode == 0
    lh = addlistener(s, 'DataAvailable', @(src,event)dataCaptureNBA(src, event, capture, figUIobj, get(figUIobj.plot, 'value')));
end
