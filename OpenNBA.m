function OpenNBA
%%% Open NBA %%%
% Select Open mode.
% if 'TEST mode' is ON, DAQ parameters are not read. Visual stimuli can be
% tested in single display environment.

% Select recording 
% 'iRecHS2': AI0:1 <= center of pupil
% 'Electrophys': AI0:1 <= Vm and Im from patch amp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adding path for sub functions.
addpath('CheckParams')
addpath('ComFunc')

% open GUI
h.fig = figure(6);
set(h.fig, 'position',[20, 500, 150, 200], 'Name', 'Open NBA', 'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

h.SelectTest = uicontrol('style', 'togglebutton', 'position',[10 155 100 40],...
    'string', 'TEST Mode', 'Callback', {@ch_ButtonColor, 'g'},...
    'FontSize', 12, 'Horizontalalignment', 'center');

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
function UseImaqCam(hObject, ~)
if get(hObject, 'value')
    % check avairable camera
    if exist('imaqhwinfo', 'builtin')
        hwinf = imaqhwinfo;
        if exist('hwinf', 'var')
        else
            errordlg('Imaq Cam is not available!')
            set(hObject, 'value', 0)
        end
    else
        errordlg('IMAQ toolbox is not available!')
        set(hObject, 'value', 0)
    end 
    ch_ButtonColor(hObject, [], 'g')
end
% 

end

function ch_ButtonColor(hObject, ~, col)
% button push event: change button color
switch get(hObject, 'Value')
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor', [0.9400 0.9400 0.9400]);
    case 1%
        set(hObject, 'BackgroundColor', col);
end
end


