function set_pulse(~, ~)

global figUIobj

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
%check PulseON/OFF
%hObject = figUIobj.pulse

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