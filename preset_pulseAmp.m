function preset_pulseAmp(hObject, ~)
global recobj
global figUIobj

switch get(figUIobj.plot, 'value')
    case 0 %Vplot::preset 1 nA
        switch get(hObject,'value')
            case 1
                set(figUIobj.pulseAmp, 'string', '1')
                recobj.pulseAmp = 1;
            case 0
        end
    case 1%Iplot
        switch get(hObject,'value')
            case 1
                set(figUIobj.pulseAmp, 'string', '10')
                recobj.pulseAmp = 10;
        end
        
end
end