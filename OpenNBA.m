function h = OpenNBA
%%% Open NBA %%%
clear
close all
h.fig = figure(4);
set(h.fig,'position',[20, 500, 300, 200],'Name','Open NBA','Menubar','none', 'Resize', 'off');
h.Select=uicontrol('style','popupmenu','position',[10 155 100 20],'string',[{'Start'},{'Test'}],'FontSize',12,'Horizontalalignment','center');
h.Start=uicontrol('style','pushbutton','string','Open NBA','position',[10 100 100 50],'FontSize',12,'Horizontalalignment','center');
set(h.Start,'Callback', {@start, h});
end

function start(hObject,~, h)
if get(hObject,'value') == 1
    NoneButAir11(get(h.Select, 'value'));
end
end


