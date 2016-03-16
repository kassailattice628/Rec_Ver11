function ch_plot(hObject,~)
global figUIobj
global plotUIobj

switch get(hObject,'value')
    case 0%V-plot
        set(figUIobj.plot,'string','V-plot','ForegroundColor','white','BackgroundColor','B');
        %C-pulse
        set(figUIobj.ampunit,'string','nA');
        set(figUIobj.presetAmp,'string', '1 nA', 'value', 0)
        %plot
        if isfield(plotUIobj,'fig')
            set(get(plotUIobj.axes1, 'Title'), 'string','V-DATA');
            set(get(plotUIobj.axes1, 'Ylabel'), 'string','mV');
            set(plotUIobj.plot1, 'Color','b');
        end
    case 1%C-plot
        set(figUIobj.plot,'string','I-plot','ForegroundColor','k','BackgroundColor','R');
        %V-pulse
        set(figUIobj.ampunit,'string','mV');
        set(figUIobj.presetAmp,'string', '10 mV', 'value',0)
        %plot
        if isfield(plotUIobj,'fig')
            set(get(plotUIobj.axes1, 'Title'), 'string','I-DATA');
            set(get(plotUIobj.axes1, 'Ylabel'), 'string','nA');
            set(plotUIobj.plot1, 'Color','r');
        end
end
% set figure color
set_pulse;

%axis reset
switch get(figUIobj.yaxis,'value')
    case 0 %y axis -auto
        if isfield(plotUIobj,'fig')
            set(plotUIobj.axes1,'YlimMode','Auto');
        end
        set(figUIobj.VYmax,'BackGroundColor','w')
        set(figUIobj.VYmin,'BackGroundColor','w')
        set(figUIobj.CYmax,'BackGroundColor','w')
        set(figUIobj.CYmin,'BackGroundColor','w')
    case 1 %y axis -manual
        if isfield(plotUIobj,'fig')
            set(plotUIobj.axes1,'YlimMode','Manual');
        end
        switch get(figUIobj.plot,'value')
            case 0 %Vplot
                if isfield(plotUIobj,'fig')
                    set(plotUIobj.axes1,'Ylim',[str2double(get(figUIobj.VYmin,'string')),str2double(get(figUIobj.VYmax,'string'))]);
                end
                set(figUIobj.VYmax,'BackGroundColor','g')
                set(figUIobj.VYmin,'BackGroundColor','g')
                set(figUIobj.CYmax,'BackGroundColor','w')
                set(figUIobj.CYmin,'BackGroundColor','w')
            case 1 %Iplot
                if isfield(plotUIobj,'fig')
                    set(plotUIobj.axes1,'Ylim',[str2double(get(figUIobj.CYmin,'string')),str2double(get(figUIobj.CYmax,'string'))]);
                end
                set(figUIobj.VYmax,'BackGroundColor','w')
                set(figUIobj.VYmin,'BackGroundColor','w')
                set(figUIobj.CYmax,'BackGroundColor','g')
                set(figUIobj.CYmin,'BackGroundColor','g')
        end
end

end
