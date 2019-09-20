function recobj = recobj_ini(Recmode)
% initialize recobj

%% version
recobj.NBAver = '11-100920a';

%% Recording Parameters: HEADER Information

recobj.interval = 1; %loop interval(s);
if Recmode == 1
    recobj.Recmode = 1;
    recobj.sampf = 2000;
    
elseif Recmode == 2
    recobj.Recmode = 2;
    recobj.sampf = 5000; %samoling rate (Hz)
    
    % AO output
    % AO pulse out is under developping
    %recobj.OutData = zeros(recobj.recp,2); %矩形波データ
    recobj.pulseAmp = 0.1; %stim amp(nA)
    recobj.pulseDelay = 0.2; %sec
    recobj.pulseDuration = 0.2; %sec
    
    %step
    recobj.stepCV = [0, 0.5, 0.1; 0, 100, 10];%[Cstart, Cend, Cstep; Vstart, Vend, Vstep]; (nA) and (mV)
    recobj.stepAmp = 0:0.1:0.5;%Cstep
    
    %DAQoutput gain Axoclamp2B, head stage gain (H) = *0.1
    %[(current pulse gain:ME1 cmd output(10*H nA/V)), (voltage pulse gain)]:
    % 1V in ->  20 mV(=0.02V) out
    recobj.gain = [1, 0.05]; %for Axoclamp2B Command V output, [ME1 cmd output(10*H nA/V), VC cmd output(20 mV/V)]; %
end

recobj.rect = 2*1000; %recording time (1s<-1000ms)
recobj.recp = recobj.sampf*recobj.rect/1000;
recobj.prestim = 2; % recobj.prestim * recobj.rect (ms) blank loop



%% TTL3
recobj.TTL3.delay = 0.1; % sec
recobj.TTL3.duration = 0.1; % sec
recobj.TTL3.Freq = 100; % Hz
recobj.TTL3.PulseNum = 10;
recobj.TTL3.DutyCycle = 0.5; %

%%

%%Savefile_conter
recobj.savecount = 1;
end