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

%% Create DataFolder
%make today folder for eye capture
dd = char(datetime('now', 'Format', 'yyMMdd'));
dir_name1 = ['C:/Users/lattice/Desktop/data/',dd, 'mat'];
if ~exist(dir_name1, 'dir')
    mkdir(dir_name1)
end
recobj.save_dirname = dir_name1;

%% Initialize Stimulus params
% monitor dependent prameter (DeLL 19-inch)
pixpitch = 0.264;%(mm)
[sobj, GUI_x] = sobj_ini(pixpitch);

%% Initialize DAQ params
if Testmode == 0
    % Reset DAQ
    daq.reset
    % NI DAQ params
    [s, sOut, dio, capture, dev] = daq_ini(Recmode);
end

%% Initialize IMAQ params
if UseCam
    imaqreset;
    imaq = imaq_ini(recobj, imaq.roi_position);
    
    %make today folder for eye capture
    %dd = char(datetime('now', 'Format', 'yyMMdd'));
    dir_name2 = ['F:/Users/lattice/Documents/EyeTracking/',dd, 'EyeMov'];
    %dir_name = ['H:/',dd];
    if ~exist(dir_name2, 'dir')
        mkdir(dir_name2) 
    end
    recobj.vid_dirname = dir_name2;
end

%% open Window PTB %%

%PsychDefaultSetup(2);
% usage:: [sobj.wPtr, sobj.RECT] = Screen('OpenWindow', sobj.ScrNum,sobj.bgcol);
[sobj.wPtr, sobj.RECT] = PsychImaging('OpenWindow', sobj.ScrNum, sobj.bgcol);

%For macOS mojave < 
%Screen('Preference', 'SkipSyncTests', 1);

% get center position in pix of stim monitor
[sobj.ScrCenterX, sobj.ScrCenterY] = RectCenter(sobj.RECT);
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate', sobj.ScrNum);

% set stimulus duration in sec
sobj.duration = sobj.flipNum * sobj.m_int; % sec

%% open GUI window
if sobj.Num_screens == 1
    %Single monitor condition
    Screen('Close', sobj.wPtr);
end
% open main GUI ctr window.
%figUIobj = gui_window4(Testmode, Recmode, UseCam, GUI_x);
figUIobj = gui_window5(Testmode, Recmode, UseCam, GUI_x);
change_stim_pattern2([],[]);

% open plot window.
plotUIobj = open_plot_window(figUIobj, Recmode, GUI_x);

%% DAQ Event Listener used in AI rec
if Testmode == 0
    lh = addlistener(s, 'DataAvailable', @(src,event)dataCaptureNBA(src, event, capture, figUIobj, Recmode, 0));
end
