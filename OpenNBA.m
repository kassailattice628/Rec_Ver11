function OpenNBA
%%% Open NBA %%%
% Select Open mode.
% if 'TEST mode' is ON, DAQ parameters are not read. Visual stimuli can be
 % tested in single display environment.

% Select recording 
% 'iRecHS2': AI0:1 <= center of pupil
% 'Electrophys': AI0:1 <= Vm and Im from patch amp

% USB3 Cam is available when IMAQ toolbox is installed.
% clikc 'Use Cam '

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adding path for sub functions.
addpath('CheckParams')
addpath('ComFunc')

% open GUI
h.fig = figure(6);
set(h.fig, 'position',[20, 400, 150, 200], 'Name', 'Open NBA', 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

h.SelectTest = uicontrol('style', 'togglebutton', 'position',[10 155 100 40],...
    'string', 'TEST Mode', 'Callback', {@UseTestmode},...
    'FontSize', 12, 'Horizontalalignment', 'center');

name_toolbox = ver;

if isempty(find(strcmp({name_toolbox.Name}, 'Data Acquisition Toolbox'), 1))
    set(h.SelectTest, 'value', 1, 'BackGroundColor', 'g')
end

h.SelectRecmode = uicontrol('style', 'popupmenu', 'position',[10 120 100 20],...
    'string', {'iRecHS', 'Electrophsy'}, 'Callback', {@ch_ButtonColor, 'g'},...
    'FontSize', 12, 'Horizontalalignment', 'center');

h.SelectUseImaq = uicontrol('style', 'togglebutton', 'position',[10 80 100 30],...
    'string', 'Use Cam', 'Callback', {@UseImaqCam},...
    'FontSize', 12, 'Horizontalalignment', 'center');

% Open None But Air
h.Start=uicontrol('style', 'pushbutton', 'position',[10 25 100 50],...
    'string', 'Open NBA', 'Callback', {@start, h},...
    'FontSize', 12, 'Horizontalalignment', 'center');
end

%% subfunctions

function start(hObject, ~, h)
% onece, main program are called, figure hundle of OpenNBA is deleted.
if get(hObject, 'value') == 1
    NoneButAir11(get(h.SelectTest, 'value'), get(h.SelectRecmode, 'value'), get(h.SelectUseImaq, 'value'));
    close(h.fig)
    clear h
end
end

%%
function UseTestmode(hObject, ~)
if get(hObject, 'value') == 0
    % check avairable DAQ devices
    name_toolbox = ver;
    if isempty(find(strcmp({name_toolbox.Name}, 'Data Acquisition Toolbox'), 1))
        errordlg('DAQ toolbox is not available!')
        set(hObject, 'value', 1)
    else % DAQ toolbox is installed
        hwinf = daq.getDevices;
        if isempty(hwinf.ID)
            % No device availbae
            errordlg('DAQ Device is not available!')
            set(hObject, 'value', 1)
        end
    end
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function UseImaqCam(hObject, ~)
if get(hObject, 'value')
    name_toolbox = ver;
    if isempty(find(strcmp({name_toolbox.Name}, 'Image Acquisition Toolbox'), 1))
        errordlg('IMAQ toolbox is not available!')
        set(hObject, 'value', 0)
    else % IMAQ toolbox is installed
        hwinf = imaqhwinfo;
         if isempty(hwinf.InstalledAdaptors)
                errordlg('No Image Acquisition adaptors found!')
                set(hObject, 'value', 0)
         end
    end
end
ch_ButtonColor(hObject, [], 'g')
end

%%
function ch_ButtonColor(hObject, ~, col)
% button push event: change button color
switch get(hObject, 'Value')
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor', [0.9400 0.9400 0.9400]);
    case 1%
        set(hObject, 'BackgroundColor', col);
end
end


