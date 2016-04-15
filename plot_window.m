function hGui = plot_window(figUIobj)
%plot_window creates plot window for  None But Air
% plotUIobj = plot_window

%% %---------- Create plot window ----------%
%open plot window
hGui.fig = figure('Position',[sobj.GUI_Display_x+680, 20, 600, 750], 'Name','Plot Window NBA11', 'NumberTitle', 'off', 'Menubar','none', 'Resize', 'off');
set(hGui.fig, 'DeleteFcn', {@close_Plot, figUIobj});
%% Axes, Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   AI1, AI2 plot    %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes1 = axes('Units','Pixels', 'Position',[50,530,500,200], 'XLimMode', 'manual','YlimMode', 'Auto');
hGui.plot1 = plot(0, NaN,'b');
ylabel('mV');
title('V-DATA');

hGui.button1 = uicontrol('style','togglebutton','string', 'ON', 'position',[555 700 45 30],...
    'callback', {@ch_ButtonColor, 'g'}, 'Horizontalalignment','center');
set(hGui.button1,'value',1, 'BackGroundColor','g')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Rotary Encoder   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes2 = axes('Units','Pixels', 'Position',[50,370,500,120], 'XLimMode', 'manual','YlimMode', 'Auto');
hGui.plot2 = plot(0, NaN);
ylabel('V');
title('Photo Sensor');

hGui.button2 = uicontrol('style','togglebutton','string', 'ON', 'position',[555 460 45 30],...
    'callback', {@ch_ButtonColor, 'g'}, 'Horizontalalignment','center');
set(hGui.button2,'value',1, 'BackGroundColor','g')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Rotary Encoder   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes3 = axes('Units','Pixels', 'Position',[50,210,500,120], 'XLimMode', 'manual','YlimMode', 'Auto');
hGui.plot3 = plot(0, NaN);
xlabel('Time (s)');
ylabel('Angle Pos. (deg)');
title('Rotary Encoder');

hGui.button3 = uicontrol('style','togglebutton','string', 'ON', 'position',[555 300 45 30],...
    'callback', {@ch_ButtonColor, 'g'}, 'Horizontalalignment','center');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Live Plot TTL   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hGui.axes4 = axes('Units','Pixels', 'Position',[50,50,500,100], 'XLimMode', 'manual','YlimMode', 'Auto');
num_plots = 4;

hGui.button4 = cell(1, num_plots);
for ii = 1:num_plots
    hGui.button4{1, ii} = uicontrol('style','togglebutton','string',['AI:',num2str(ii)],'position',[555 130-(30*(ii-1)) 45 30],'Horizontalalignment','center');
    set(hGui.button4{1, ii}, 'callback', {@ch_ButtonColor, 'g'});
end
hGui.plot4 = plot(0, NaN(1,num_plots));
set(hGui.button4{1,4},'value',1, 'BackGroundColor','g')
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
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor',[0.9400 0.9400 0.9400]);
    case 1%
        set(hObject, 'BackgroundColor',col)
end
end
