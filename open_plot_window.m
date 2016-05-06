function hGui = open_plot_window(figUIobj, Recmode, GUI_x)
%plot_window creates plot window for  None But Air
% plotUIobj = plot_window


%% %---------- Create plot window ----------%
%open plot window
hGui.fig = figure('Position', [GUI_x + 650, 20, 630, 750],...
    'DeleteFcn', {@close_Plot, figUIobj}, 'Name', 'Plot Window NBA11',...
    'NumberTitle', 'off', 'Menubar', 'none', 'Resize', 'off');

%% Axes, Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   AI0(+AI4), AI1(+AI5) plot    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Xpos_axes = 70;
Xpos_button = 575;

if Recmode == 1
    % Vertical position
    hGui.axes1_1 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 600, 500, 130], 'XLimMode', 'manual', 'YlimMode', 'Auto');
    hGui.plot1_1 = plot(0, NaN);
    set(gca, 'xticklabel', [])
    ylabel('Vertical (V)');
    hGui.button1_1 = uicontrol('style', 'togglebutton', 'string', 'ON', 'position', [Xpos_button 700 45 30],...
        'value', 1, 'callback', {@ch_ButtonColor, 'g'}, 'BackGroundColor', 'g', 'Horizontalalignment', 'center');
    
    % Horizontal position
    hGui.axes1_2 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 450, 500, 130], 'XLimMode', 'manual', 'YlimMode', 'Auto');
    hGui.plot1_2 = plot(0, NaN);
    set(gca, 'xticklabel', [])
    ylabel('Horizontal (V)');
    hGui.button1_2 = uicontrol('style', 'togglebutton', 'string', 'ON', 'position', [Xpos_button 550 45 30],...
        'value', 1, 'callback', {@ch_ButtonColor, 'g'}, 'BackGroundColor', 'g', 'Horizontalalignment', 'center');

    
elseif Recmode == 2
    hGui.axes1 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 530, 500, 200], 'XLimMode', 'manual', 'YlimMode', 'Auto');
    hGui.plot1 = plot(0, NaN, 'b');
    ylabel('mV');
    title('V-DATA');
    
    hGui.button1 = uicontrol('style', 'togglebutton', 'string', 'ON', 'position', [Xpos_button 700 45 30],...
        'value', 1, 'callback', {@ch_ButtonColor, 'g'}, 'BackGroundColor', 'g', 'Horizontalalignment', 'center');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     Photosensor    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes2 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 330, 500, 100], 'XLimMode', 'manual', 'YlimMode', 'Auto');
hGui.plot2 = plot(0, NaN);
set(gca, 'xticklabel', [])
ylabel('Photo Sensor (V)');

hGui.button2 = uicontrol('style', 'togglebutton', 'string', 'ON', 'position', [Xpos_button 400 45 30],...
    'value', 1,'callback', {@ch_ButtonColor, 'g'}, 'BackGroundColor', 'g', 'Horizontalalignment', 'center');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Rotary Encoder   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes3 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 210, 500, 100], 'XLimMode', 'manual', 'YlimMode', 'Auto');
hGui.plot3 = plot(0, NaN);
xlabel('Time (s)');
ylabel('Rotary Angle (deg)');

hGui.button3 = uicontrol('style', 'togglebutton', 'string', 'ON', 'position', [Xpos_button 280 45 30],...
    'callback', {@ch_ButtonColor, 'g'}, 'Horizontalalignment', 'center');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Live Plot TTL   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes4 = axes('Units', 'Pixels', 'Position', [Xpos_axes, 50, 500, 100], 'XLimMode', 'manual', 'YlimMode', 'Auto');
num_plots = 4;

hGui.button4 = cell(1, num_plots);
for ii = 1:num_plots
    hGui.button4{1, ii} = uicontrol('style', 'togglebutton', 'string', ['AI:',num2str(ii)], 'position', [Xpos_button 130-(30*(ii-1)) 45 30], 'Horizontalalignment', 'center');
    set(hGui.button4{1, ii}, 'callback', {@ch_ButtonColor, 'g'});
end
hGui.plot4 = plot(0, NaN(1,num_plots));
set(hGui.button4{1,4}, 'value',1, 'BackGroundColor', 'g')
xlabel('Time (s)');
ylabel('Liveplot (V)');

end

%%
function close_Plot(~, ~, figUIobj)
global plotUIobj
plotUIobj = rmfield(plotUIobj, 'fig');
if isstruct(figUIobj)
    set(figUIobj.PlotWindowON, 'value', 0, 'BackGroundColor', [0.9400 0.9400 0.9400]);
end
end

%%
function ch_ButtonColor(hObject, ~, col)
switch get(hObject, 'Value')
    case 0 % reset button color defaut
        set(hObject, 'BackGroundColor', [0.9400 0.9400 0.9400]);
    case 1 %
        set(hObject, 'BackgroundColor', col)
end
end
