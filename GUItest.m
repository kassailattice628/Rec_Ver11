function hGui = GUItest
hGui.f1 = figure('Position',[10, 20, 1000, 750], 'Name','None But Air (Ver.11_pre)','Menubar','none', 'Resize', 'Off', 'NumberTitle', 'Off');

global x
x = '';
hGui.b1 = uicontrol('style', 'togglebutton','string','OpenScreen','position',[5 705 80 30],'Callback', @OpenSCR, 'Horizontalalignment','center');
hGui.t2 = uicontrol('style', 'edit', 'string', x,...
    'units', 'pixels', 'position', [87 159 57 26]);

    function OpenSCR(hObject,~,~)
        switch get(hObject,'Value')
            case 1
                x = 1;
            case 0
                x = 0;
        end
        set(hGui.t2, 'string', x)
    end
end
