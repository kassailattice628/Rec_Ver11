function ch_plot(hObject,~, hGui)
global recobj

recobj.plot = get(hObject,'value')+1;
switch recobj.plot
    case 1%V-plot
        set(hGui.plot,'string','V-plot','ForegroundColor','white','BackgroundColor','B');
        %plot
        set(get(hGui.s2, 'Title'), 'string','V-DATA');
        set(get(hGui.s2, 'Ylabel'), 'string','mV');
        set(hGui.p2, 'Color','b');
        %C-pulse
        set(hGui.ampunit,'string','nA');
        set(hGui.presetAmp,'string', '1 nA', 'value',0)
        %preset
    case 2%C-plot
        set(hGui.plot,'string','I-plot','BackgroundColor','R');
        %plot
        set(get(hGui.s2, 'Title'), 'string','I-DATA');
        set(get(hGui.s2, 'Ylabel'), 'string','nA');
        set(hGui.p2, 'Color','r');
        %V-pulse
        set(hGui.ampunit,'string','mV');
        set(hGui.presetAmp,'string', '10 mV', 'value',0)
        
end

%軸の更新も必要か
switch recobj.yaxis
    case 0
        set(hGui.s2,'YlimMode','Auto');
        set(hGui.VYmax,'BackGroundColor','w')
        set(hGui.VYmin,'BackGroundColor','w')
        set(hGui.CYmax,'BackGroundColor','w')
        set(hGui.CYmin,'BackGroundColor','w')
    case 1
        set(hGui.s2,'YlimMode','Manual');
        set(hGui.s2,'Ylim',[recobj.yrange(recobj.plot*2-1),recobj.yrange(recobj.plot*2)]);
        switch recobj.plot
            case 1
                set(hGui.VYmax,'BackGroundColor','g')
                set(hGui.VYmin,'BackGroundColor','g')
                set(hGui.CYmax,'BackGroundColor','w')
                set(hGui.CYmin,'BackGroundColor','w')
            case 2
                set(hGui.VYmax,'BackGroundColor','w')
                set(hGui.VYmin,'BackGroundColor','w')
                set(hGui.CYmax,'BackGroundColor','g')
                set(hGui.CYmin,'BackGroundColor','g')
        end
end

%%
recobj.rectaxis = (0:recobj.recp-1)';
hGui.t = recobj.rectaxis/recobj.rect;

recobj.dataall = zeros(recobj.recp,3);%AI channel ３つ分
hGui.y2 = recobj.dataall(:,recobj.plot);

hGui.y3 = recobj.dataall(:,3);
end
