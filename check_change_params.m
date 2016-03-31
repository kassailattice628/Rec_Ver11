function check_change_params(~, ~)
global figUIobj
global plotUIobj
global sobj
global recobj

change_stim_pattern;
check_stim_lumi;
check_stim_duration;
change_plot;
check_AOrange;


%%%%% define functions (nested) %%%%%
    function change_stim_pattern
        defcol = [0.9400 0.9400 0.9400];
        pattern_list = get(figUIobj.pattern,'string');
        sobj.pattern = pattern_list{get(figUIobj.pattern,'value'),1};
        
        switch sobj.pattern
            case 'Uni'
                set(figUIobj.mode, 'value', 1); % position random
                set(figUIobj.fixpos,'BackGroundColor','w');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','k');
                set(figUIobj.dist,'BackGroundColor','k');
                
                set(figUIobj.shiftDir,'BackGroundColor','k');
                set(figUIobj.shiftSpd,'BackGroundColor','k');
                set(figUIobj.gratFreq,'BackGroundColor','k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case 'Size_rand'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','k');
                set(figUIobj.dist,'BackGroundColor','k');
                
                set(figUIobj.shiftDir,'BackGroundColor','k');
                set(figUIobj.shiftSpd,'BackGroundColor','k');
                set(figUIobj.gratFreq,'BackGroundColor','k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case '1P_Conc'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','g');
                set(figUIobj.dist,'BackGroundColor','g');
                
                set(figUIobj.shiftDir,'BackGroundColor', defcol);
                set(figUIobj.shiftSpd,'BackGroundColor', 'k');
                set(figUIobj.gratFreq,'BackGroundColor', 'k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case '2P_Conc'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','g');
                set(figUIobj.dist,'BackGroundColor','g');
                
                set(figUIobj.shiftDir,'BackGroundColor', defcol);
                set(figUIobj.shiftSpd,'BackGroundColor', 'k');
                set(figUIobj.gratFreq,'BackGroundColor', 'k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','w');
                set(figUIobj.stimlumi2,'BackGroundColor','w');
                set(figUIobj.flipNum2,'BackGroundColor','w');
                set(figUIobj.delayPTBflip2,'BackGroundColor','w');
                set(figUIobj.size2,'BackGroundColor','w');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case 'B/W'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','g');
                set(figUIobj.dist,'BackGroundColor','g');
                
                set(figUIobj.shiftDir,'BackGroundColor', defcol);
                set(figUIobj.shiftSpd,'BackGroundColor', 'k');
                set(figUIobj.gratFreq,'BackGroundColor', 'k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case 'Looming'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                set(figUIobj.shape, 'value', 2); % circular
                
                set(figUIobj.div_zoom,'BackGroundColor','k');
                set(figUIobj.dist,'BackGroundColor','k');
                
                set(figUIobj.shiftDir,'BackGroundColor', 'k');
                set(figUIobj.shiftSpd,'BackGroundColor', 'k');
                set(figUIobj.gratFreq,'BackGroundColor', 'k');
                
                set(figUIobj.loomSpd,'BackGroundColor','w');
                set(figUIobj.loomSize,'BackGroundColor','w');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'y');
                
            case {'Sin', 'Rect', 'Gabor'}
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                
                set(figUIobj.div_zoom,'BackGroundColor','k');
                set(figUIobj.dist,'BackGroundColor','k');
                
                set(figUIobj.shiftDir,'BackGroundColor', defcol);
                set(figUIobj.shiftSpd,'BackGroundColor', defcol);
                set(figUIobj.gratFreq,'BackGroundColor', defcol);
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','k');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
                
            case 'Images'
                set(figUIobj.mode, 'value', 2); % position fix
                set(figUIobj.fixpos,'BackGroundColor','g');
                
                set(figUIobj.div_zoom,'BackGroundColor','k');
                set(figUIobj.dist,'BackGroundColor','k');
                
                set(figUIobj.shiftDir,'BackGroundColor', 'k');
                set(figUIobj.shiftSpd,'BackGroundColor', 'k');
                set(figUIobj.gratFreq,'BackGroundColor', 'k');
                
                set(figUIobj.loomSpd,'BackGroundColor','k');
                set(figUIobj.loomSize,'BackGroundColor','k');
                
                set(figUIobj.ImageNum,'BackGroundColor','w');
                
                set(figUIobj.shape2,'BackGroundColor','k');
                set(figUIobj.stimlumi2,'BackGroundColor','k');
                set(figUIobj.flipNum2,'BackGroundColor','k');
                set(figUIobj.delayPTBflip2,'BackGroundColor','k');
                set(figUIobj.size2,'BackGroundColor','k');
                
                set(figUIobj.rect, 'BackgroundColor', 'g');
        end
    end

%%
    function change_plot
        switch get(figUIobj.plot,'value')
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
                switch get(figUIobj.plot,'value')
                    case 0 %Vplot
                        if isfield(plotUIobj,'fig')
                            set(plotUIobj.axes1,'YlimMode','Manual',...
                                'Ylim',[str2double(get(figUIobj.VYmin,'string')),str2double(get(figUIobj.VYmax,'string'))]);
                        end
                        set(figUIobj.VYmax,'BackGroundColor','g')
                        set(figUIobj.VYmin,'BackGroundColor','g')
                        set(figUIobj.CYmax,'BackGroundColor','w')
                        set(figUIobj.CYmin,'BackGroundColor','w')
                    case 1 %Iplot
                        if isfield(plotUIobj,'fig')
                            set(plotUIobj.axes1,'YlimMode','Manual'...
                                ,'Ylim',[str2double(get(figUIobj.CYmin,'string')),str2double(get(figUIobj.CYmax,'string'))]);
                        end
                        set(figUIobj.VYmax,'BackGroundColor','w')
                        set(figUIobj.VYmin,'BackGroundColor','w')
                        set(figUIobj.CYmax,'BackGroundColor','g')
                        set(figUIobj.CYmin,'BackGroundColor','g')
                end
        end
    end

%%
    function set_pulse
        pulse = figUIobj.pulse;
        stepf = figUIobj.stepf;
        duration = figUIobj.pulseDuration;
        delay = figUIobj.pulseDelay;
        amp = figUIobj.pulseAmp;
        Vstart = figUIobj.Vstart;
        Vend = figUIobj.Vend;
        Vstep = figUIobj.Vstep;
        Cstart = figUIobj.Cstart;
        Cend = figUIobj.Cend;
        Cstep = figUIobj.Cstep;
        plot = figUIobj.plot;
        
        %pulse ON && step OFF
        if get(pulse, 'value') == 1 && get(stepf,'value') == 0
            set(duration, 'BackGroundColor', 'g');
            set(delay, 'BackGroundColor', 'g');
            set(amp, 'BackGroundColor', 'g');
            set(Vstart, 'BackGroundColor', 'w');
            set(Vend, 'BackGroundColor', 'w');
            set(Vstep, 'BackGroundColor', 'w');
            set(Cstart, 'BackGroundColor', 'w');
            set(Cend, 'BackGroundColor', 'w');
            set(Cstep, 'BackGroundColor', 'w');
            %pulse ON && step ON
            
        elseif get(pulse, 'value') == 1 && get(stepf,'value') == 1
            switch get(plot, 'value')
                case 0 %Vplot
                    set(duration, 'BackGroundColor', 'w');
                    set(delay, 'BackGroundColor', 'w');
                    set(amp, 'BackGroundColor', 'w');
                    set(Vstart, 'BackGroundColor', 'w');
                    set(Vend, 'BackGroundColor', 'w');
                    set(Vstep, 'BackGroundColor', 'w');
                    set(Cstart, 'BackGroundColor', 'g');
                    set(Cend, 'BackGroundColor', 'g');
                    set(Cstep, 'BackGroundColor', 'g');
                case 1 %Cplot
                    set(duration, 'BackGroundColor', 'w');
                    set(delay, 'BackGroundColor', 'w');
                    set(amp, 'BackGroundColor', 'w');
                    set(Vstart, 'BackGroundColor', 'g');
                    set(Vend, 'BackGroundColor', 'g');
                    set(Vstep, 'BackGroundColor', 'g');
                    set(Cstart, 'BackGroundColor', 'w');
                    set(Cend, 'BackGroundColor', 'w');
                    set(Cstep, 'BackGroundColor', 'w');
            end
            
            %pulse OFF && (step ON or OFF)
        elseif get(pulse,'value') == 0 && get(stepf, 'value') == 0
            set(stepf, 'BackGroundColor', [0.9400 0.9400 0.9400])
            set(duration, 'BackGroundColor', 'w');
            set(delay, 'BackGroundColor', 'w');
            set(amp, 'BackGroundColor', 'w');
            set(Vstart, 'BackGroundColor', 'w');
            set(Vend, 'BackGroundColor', 'w');
            set(Vstep, 'BackGroundColor', 'w');
            set(Cstart, 'BackGroundColor', 'w');
            set(Cend, 'BackGroundColor', 'w');
            set(Cstep, 'BackGroundColor', 'w');
            
            %pulse OFF && step ON
        elseif get(pulse, 'value') == 0 && get(stepf, 'value') == 1
            disp('hey')
            set(stepf, 'value', 0, 'BackGroundColor', [0.9400 0.9400 0.9400])
            set(duration, 'BackGroundColor', 'w');
            set(delay, 'BackGroundColor', 'w');
            set(amp, 'BackGroundColor', 'w');
            set(Vstart, 'BackGroundColor', 'w');
            set(Vend, 'BackGroundColor', 'w');
            set(Vstep, 'BackGroundColor', 'w');
            set(Cstart, 'BackGroundColor', 'w');
            set(Cend, 'BackGroundColor', 'w');
            set(Cstep, 'BackGroundColor', 'w');
        end
    end

%%
    function check_stim_lumi
        % check stim luminace: range (0-255)
        
        stimlumi = str2double(get(figUIobj.stimlumi,'string'));
        stimlumi2 = str2double(get(figUIobj.stimlumi2,'string'));
        bgcol = str2double(get(figUIobj.bgcol,'string'));
        
        if stimlumi > 255 || stimlumi < 0
            errordlg('Stim. Lumience is out of range!!');
            set(figUIobj.stimlumi,'string', 255);
        end
        
        if stimlumi2 > 255 || stimlumi2 < 0
            errordlg('Stim. Lumience is out of range!!');
            set(figUIobj.stimlumi2,'string', 255);
        end
        
        if bgcol > 255 || bgcol <0 || bgcol > stimlumi || bgcol > stimlumi2
            errordlg(' BackGround Lumience is out of range!!');
            set(figUIobj.bgcol,'string',0);
        end
        
    end

%%
    function check_stim_duration
        
        rectime = re_write(figUIobj.rect)/1000; %ms -> s
        
        flipNum1 = re_write(figUIobj.flipNum);
        dur1 = flipNum1*sobj.m_int;
        
        delayNum1 = re_write(figUIobj.delayPTBflip);
        delay1 = delayNum1*sobj.m_int;
        
        flipNum2 = re_write(figUIobj.flipNum2);
        dur2 = flipNum2*sobj.m_int;
        
        delayNum2 = re_write(figUIobj.delayPTBflip2);
        delay2 = delayNum2*sobj.m_int;
        
        % check duration
        
        
        if strcmp(sobj.pattern, 'Looming')
            % change recording time according to the looming speed.
            loomSpd_list = get(figUIobj.loomSpd, 'string');
            
            sobj.loomSize_pix = stim_size(sobj.MonitorDist, figUIobj.loomSize, sobj.pixpitch);
            
            sobj.maxSize_deg = str2double(get(figUIobj.loomSize,'string'));
            
            sobj.loomSpd_deg = str2double(loomSpd_list{get(figUIobj.loomSpd,'value'),1});
            
            sobj.loomDuration = sobj.maxSize_deg/sobj.loomSpd_deg;
            
            rect_in_sec = (sobj.loomDuration + 1) * 10; % add 1 sec
            recobj.rect = 100 * round(rect_in_sec);
            
            set(figUIobj.rect, 'string', recobj.rect, 'BackgroundColor', 'y');
            set(figUIobj.loomSize, 'BackgroundColor', 'g');
            
        else
            
            set(figUIobj.loomSize, 'BackgroundColor', 'w');
            set(figUIobj.rect, 'BackgroundColor', 'g');
            recobj.rect = re_write(figUIobj.rect);
            if rectime < dur1+delay1 || rectime < dur2+delay2
                errordlg('Stim. Duration is longer than Recording Time!!');
                
                set(figUIobj.flipNum, 'string',75);
                set(figUIobj.delayPTBflip, 'string',20);
                
                set(figUIobj.flipNum2, 'string', 75);
                set(figUIobj.delayPTBflip2, 'string',20);
                
                set(figUIobj.rect, 'string', 2000);
                
                dur1 = 75*sobj.m_int;
                delay1 = 20*sobj.m_int;
                dur2 = 75*sobj.m_int;
                delay2 = 20*sobj.m_int;
            end
        end
        
        % update GUI
        set(figUIobj.stimDur,'string',['flips = ',num2str(floor(dur1*1000)),' ms']);
        set(figUIobj.delayPTB,'string',['flips = ',num2str(floor(delay1*1000)),' ms']);
        set(figUIobj.stimDur2,'string',['flips = ',num2str(floor(dur2*1000)),' ms']);
        set(figUIobj.delayPTB2, 'string',['flips = ',num2str(floor(delay2*1000)),' ms']);
        
    end

%%
    function check_AOrange
        % NI DAQ ranges is upto +/-10 V.
        % When DAQ range is changed, the maximum value is set to +/- Ranges(max_i).
        
        max_i = get(figUIobj.DAQrange,'value');
        Ranges = [10, 1, 0.2, 0.1];
        
        plot = get(figUIobj.plot,'value')+1;
        
        switch get(figUIobj.stepf,'value')
            case 0%
                if recobj.pulseAmp * recobj.gain(plot) > Ranges(max_i)
                    errordlg('pulseAmp exceeds DAQ range!!');
                    recobj.pulseAmp = 0.1;
                    set(hObject, 'string','0.1');
                end
                
            case 1%step
                if recobj.stepCV(plot,1) * recobj.gain(plot) < -Ranges(max_i)...
                        || recobj.stepCV(plot,2) * recobj.gain(plot) > Range(max_i)
                    
                    errordlg('pulseAmp exxeds DAQ range!!');
                    recobj.stepCV = [0,0.5,0.1;0,100,10];
                    recobj.stepAmp = recobj.stepCV(plot,1):recobj.stepCV(plot,3):recobj.stepCV(plot,2);
                    
                    set(hGui.Cstart,'string',recobj.stepCV(1,1));
                    set(hGui.Cend,'string',recobj.stepCV(1,2));
                    set(hGui.Cstep,'string',recobj.stepCV(1,3));
                    
                    set(hGui.Vstart,'string',recobj.stepCV(2,1));
                    set(hGui.Vend,'string',recobj.stepCV(2,2));
                    set(hGui.Vstep,'string',recobj.stepCV(2,3));
                end
        end
        
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = re_write(h)
y = str2double(get(h,'string'));
end

function size = stim_size(dist , h, pixpitch)
size = round(ones(1,2)*Deg2Pix(str2double(get(h,'string')), dist, pixpitch));
end
