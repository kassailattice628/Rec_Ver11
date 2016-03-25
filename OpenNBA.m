function OpenNBA
%%% Open NBA %%%
h.fig = figure(6);
set(h.fig,'position',[20, 500, 150, 200],'Name','Open NBA','NumberTitle','off', 'Menubar','none', 'Resize', 'off');
h.SelectTest = uicontrol('style','togglebutton','position',[10 155 100 40],'string', 'TEST Mode','FontSize',12,'Horizontalalignment','center');
set(h.SelectTest, 'Callback', {@ch_ButtonColor, 'g'});
h.Start=uicontrol('style','pushbutton','string','Open NBA','position',[10 100 100 50],'FontSize',12,'Horizontalalignment','center');
set(h.Start,'Callback', {@start, h});
end

function start(hObject,~, h)
if get(hObject,'value') == 1
    NoneButAir11_03(get(h.SelectTest, 'value'));
    close(h.fig)
    clear h
end
end

function ch_ButtonColor(hObject, ~, col)
switch get(hObject, 'Value')
    case 0% reset button color defaut
        set(hObject, 'BackGroundColor',[0.9400 0.9400 0.9400]);
    case 1%
        set(hObject, 'BackgroundColor',col);
end
end


