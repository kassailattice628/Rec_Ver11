function change_plot(~, ~)
global figUIobj
global plotUIobj

% 2-ch Electrophysiology
switch get(figUIobj.plot, 'value')
    % Change plot button
    case 0 % V-plot
        set(figUIobj.plot, 'string', 'V-plot', 'ForegroundColor', 'w', 'BackgroundColor', 'b');
        % C-pulse
        set(figUIobj.ampunit, 'string', 'nA');
        set(figUIobj.presetAmp, 'string', '1 nA', 'value', 0)
        % plot
        if isfield(plotUIobj, 'fig')
            set(get(plotUIobj.axes1, 'Title'), 'string', 'V-DATA');
            set(get(plotUIobj.axes1, 'Ylabel'), 'string', 'mV');
            set(plotUIobj.plot1, 'Color', 'b');
        end
    case 1 % C-plot
        set(figUIobj.plot, 'string', 'I-plot', 'ForegroundColor', 'k', 'BackgroundColor', 'r');
        % V-pulse
        set(figUIobj.ampunit, 'string', 'mV');
        set(figUIobj.presetAmp, 'string', '10 mV', 'value',0)
        % plot
        if isfield(plotUIobj, 'fig')
            set(get(plotUIobj.axes1, 'Title'), 'string', 'I-DATA');
            set(get(plotUIobj.axes1, 'Ylabel'), 'string', 'nA');
            set(plotUIobj.plot1, 'Color', 'r');
        end
end

%
set_pulse;

% reset axis
switch get(figUIobj.yaxis, 'value')
    case 0 %y axis -auto
        if isfield(plotUIobj, 'fig')
            set(plotUIobj.axes1, 'YlimMode', 'Auto');
        end
        set(figUIobj.VYmax, 'BackGroundColor', 'w')
        set(figUIobj.VYmin, 'BackGroundColor', 'w')
        set(figUIobj.CYmax, 'BackGroundColor', 'w')
        set(figUIobj.CYmin, 'BackGroundColor', 'w')
        
    case 1 %y axis -manual
        switch get(figUIobj.plot, 'value')
            case 0 %Vplot
                if isfield(plotUIobj, 'fig')
                    set(plotUIobj.axes1, 'YlimMode', 'Manual',...
                        'Ylim',[str2double(get(figUIobj.VYmin, 'string')),...
                        str2double(get(figUIobj.VYmax, 'string'))]);
                end
                set(figUIobj.VYmax, 'BackGroundColor', 'g')
                set(figUIobj.VYmin, 'BackGroundColor', 'g')
                set(figUIobj.CYmax, 'BackGroundColor', 'w')
                set(figUIobj.CYmin, 'BackGroundColor', 'w')
            case 1 %Iplot
                if isfield(plotUIobj, 'fig')
                    set(plotUIobj.axes1, 'YlimMode', 'Manual'...
                        , 'Ylim',[str2double(get(figUIobj.CYmin, 'string')),...
                        str2double(get(figUIobj.CYmax, 'string'))]);
                end
                set(figUIobj.VYmax, 'BackGroundColor', 'w')
                set(figUIobj.VYmin, 'BackGroundColor', 'w')
                set(figUIobj.CYmax, 'BackGroundColor', 'g')
                set(figUIobj.CYmin, 'BackGroundColor', 'g')
        end
end


%%
    function set_pulse
        % set GUI color
        
        pulse = figUIobj.pulse;
        stepf = figUIobj.stepf;
        plot = figUIobj.plot;
        
        key ={'duration', 'delay', 'amp', 'Vstart', 'Vend', 'Vstep',...
            'Cstart', 'Cend', 'Cstep'};
        
        % pulse ON && step OFF
        if get(pulse, 'value') == 1 && get(stepf, 'value') == 0
            val = {'g', 'g', 'g', 'w', 'w', 'w', 'w', 'w',' w'};
        % pulse ON && step ON
        elseif get(pulse, 'value') == 1 && get(stepf, 'value') == 1
            
            switch get(plot, 'value')
                case 0 %Vplot
                    val = {'w', 'w', 'w', 'w', 'w',' w', 'g', 'g', 'g'};
                case 1 %Cplot
                    val = {'w', 'w', 'w', 'g', 'g', 'g', 'w', 'w',' w'};
            end
            
        % pulse OFF && (step ON or OFF)
        elseif get(pulse, 'value') == 0
            if get(stepf, 'value') == 1
                set(stepf, 'value', 0);
            end
            set(stepf, 'BackGroundColor', [0.9400 0.9400 0.9400]);
            val = {'w', 'w', 'w', 'w', 'w',' w', 'w', 'w', 'w'};
        end
        
        map_list = containers.Map(key, val);
        set_fig_pulse_color(map_list)
    end

%%
    function set_fig_pulse_color(map_list)
        
        set(figUIobj.pulseDuration, 'BackGroundColor', map_list('duration'));
        set(figUIobj.pulseDelay, 'BackGroundColor', map_list('delay'));
        set(figUIobj.pulseAmp, 'BackGroundColor', map_list('amp'));
        set(figUIobj.Vstart, 'BackGroundColor', map_list('Vstart'));
        set(figUIobj.Vend, 'BackGroundColor', map_list('Vend'));
        set(figUIobj.Vstep, 'BackGroundColor', map_list('Vstep'));
        set(figUIobj.Cstart, 'BackGroundColor', map_list('Cstart'));
        set(figUIobj.Cend, 'BackGroundColor', map_list('Cend'));
        set(figUIobj.Cstep, 'BackGroundColor', map_list('Cstep'));
    end

end
