function check_pulse_Amp(~, ~)
global figUIobj
global recobj

%max_i = get(figUIobj.DAQrange,'value');
max_i = 1;
Ranges = [10, 1, 0.2, 0.1];

plot = get(figUIobj.plot,'value') + 1;

switch get(figUIobj.stepf,'value')
    case 0 % step OFF
        if recobj.pulseAmp * recobj.gain(plot) > Ranges(max_i)
            errordlg('pulseAmp exceeds DAQ range!!');
            recobj.pulseAmp = 0.1;
            set(hObject, 'string', recobj.pulseAmp);
        end
    case 1%step
        if recobj.stepCV(plot, 1) * recobj.gain(plot) < -Ranges(max_i)...
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