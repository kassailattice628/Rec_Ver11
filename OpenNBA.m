function OpenNBA
%%% Open NBA %%%
clear
close all
fig = figure(4);
set(fig,'position',[20, 500, 300, 200],'Name','Open NBA','Menubar','none', 'Resize', 'off');
Select=uicontrol('style','popupmenu','position',[10 155 100 20],'string',[{'Start'},{'Test'}],'FontSize',12,'Horizontalalignment','center');
set(Select,'Callback',@showstate);
Start=uicontrol('style','pushbutton','string','Open NBA','position',[10 100 100 50],'FontSize',12,'Horizontalalignment','center');
set(Start,'Callback', {@start, get(Select,'value')});
end

function start(hObject,~, i)
if get(hObject,'value')
    NoneButAir11(i)
end
end

function showstate(hObject,~)
disp(get(hObject,'value'))
end


