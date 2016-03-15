function reload_params(~, ~, Testmode)
% reload all paraemter and settings if changes from GUI
global figUIobj
global plotUIobj
global sobj
global recobj
global s
global capture
global lh
global dio

global DataSave
global ParamsSave

%% visual stimulus settings %%
% general %
sobj.MonitorDist = re_write(figUIobj.MonitorDist);
sobj.div_zoom = re_write(figUIobj.div_zoom);
sobj.dist = re_write(figUIobj.dist);
sobj.bgcol = re_write(figUIobj.bgcol);

sobj.divnum = re_write(figUIobj.divnum);
set(figUIobj.divnumN, 'string', ['(=> ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)']);

sobj.fixpos = re_write(figUIobj.fixpos);
set(figUIobj.fixposN,'string',['(<= ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)']);

recobj.prestim = re_write(figUIobj.prestimN);
recobj.cycleNum = 0- recobj.prestim;
set(figUIobj.prestim,'string',['loops = > ',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),' sec'],'Horizontalalignment','left');

%%%%% stim 1 %%%%%
sobj.shape = sobj.shapelist{get(figUIobj.shape, 'value'), 1};
sobj.stimlumi = re_write(figUIobj.stimlumi);
sobj.flipNum = re_write(figUIobj.flipNum);
sobj.duration = sobj.flipNum*sobj.m_int;
set(figUIobj.stimDur,'string',['flips = ',num2str(floor(sobj.duration*1000)),' ms']);
sobj.delayPTBflip = re_write(figUIobj.delayPTBflip);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;
set(figUIobj.delayPTB,'string',['flips = ',num2str(floor(sobj.delayPTB*1000)),' ms']);
sobj.stimsz = stim_size(sobj.MonitorDist,figUIobj.size, sobj.pixpitch);
if get(figUIobj.auto_size,'value')==1
    set(figUIobj.auto_size,'value',0,'string','Auto OFF')
end

sobj.shiftDir = get(figUIobj.shiftDir,'value');
sobj.shiftSpd = sobj.shiftSpd_list(get(figUIobj.shiftSpd,'value'));
sobj.gratFreq = sobj.gratFreq_list(get(figUIobj.gratFreq, 'value'));
sobj.ImageNum = re_write(figUIobj.ImageNum);

%%%%% stim 2 %%%%%
sobj.shape2 = sobj.shapelist{get(figUIobj.shape2, 'value'), 1};
sobj.stimlumi2 = re_write(figUIobj.stimlumi2);
sobj.flipNum2 = re_write(figUIobj.flipNum2);
sobj.duration2 = sobj.flipNum2*sobj.m_int;
set(figUIobj.stimDur2,'string',['flips = ',num2str(floor(sobj.duration2*1000)),' ms']);

sobj.delayPTBflip2 = re_write(figUIobj.delayPTBflip2);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;
set(figUIobj.delayPTB2, 'string',['flips = ',num2str(floor(sobj.delayPTB2*1000)),' ms']);

sobj.stimsz2 = stim_size(sobj.MonitorDist,figUIobj.size2, sobj.pixpitch);

%% Recording %%
recobj.interval = re_write(figUIobj.interval);
recobj.sampf = str2double(get(figUIobj.sampf,'string'))*1000;
%recobj.sampt = recobj.sampf/10^6;
recobj.rect = re_write(figUIobj.rect);
recobj.recp = recobj.sampf*recobj.rect/1000;

recobj.pulseDuration = re_write(figUIobj.pulseDuration);
recobj.pulseDelay = re_write(figUIobj.pulseDelay);
recobj.pulseAmp = re_write(figUIobj.pulseAmp);

recobj.stepCV(1,1) = re_write(figUIobj.Cstart);
recobj.stepCV(1,2) = re_write(figUIobj.Cend);
recobj.stepCV(1,3) = re_write(figUIobj.Cstep);
recobj.stepCV(2,1) = re_write(figUIobj.Vstart);
recobj.stepCV(2,2) = re_write(figUIobj.Vend);
recobj.stepCV(2,3) = re_write(figUIobj.Vstep);

plotnum = get(figUIobj.plot, 'value')+1;
recobj.stepAmp = recobj.stepCV(plotnum,1):recobj.stepCV(plotnum,3):recobj.stepCV(plotnum,2);

% TTL
recobj.durationTTL3 = re_write(figUIobj.durationTTL3);
recobj.delayTTL3 = re_write(figUIobj.delayTTL3);

%% DAQ
if Testmode == 0
    % DAQ sessions are not defined in the TEST-mode
    if s.IsRunning
        s.stop;
        disp('stop s')
    end
    
    s.Rate = recobj.sampf;
    %s.DurationInSeconds = recobj.rect/1000;%sec, when AO channel is set, s.DurationInSeconds is replaced with 's.scansqued/s.rate'.
    
    % data capture settings
    % Specify triggered capture timespan, in seconds
    capture.TimeSpan = recobj.rect/1000;% sec
    
    % Specify continuous data plot timespan
    capture.plotTimeSpan = 2; %sec
    
    % Determine the timespan corresponding to the block of samples supplied
    % to the DataAvailable event callback function.
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    
    % Determine required buffer timespan, seconds
    capture.bufferTimeSpan = max([capture.TimeSpan * 3, callbackTimeSpan * 3]);
    
    % Determine data buffer size
    capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);
    
    delete(lh)% <-- important!!!
    DataSave =[];
    ParamsSave =[];
    lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj, get(figUIobj.plot,'value')));
    
    
    %% reset Triggers
    %% dio reset
    outputSingleScan(dio.TrigAIFV,[0,0])
    outputSingleScan(dio.VSon,0)
    outputSingleScan(dio.TTL3,0)
    disp('reload s, dio')
end
%% plot
if isfield(plotUIobj, 'plot')
switch get(figUIobj.plot, 'value') %V-plot or I-plot
    case 0
        col = 'b';
    case 1
        col = 'r';
end
set(plotUIobj.plot1, 'Color', col);
end
disp(isfield(plotUIobj,'fig'))
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sub functions %%
%%
function y = re_write(h)
y = str2double(get(h,'string'));
end
%%
function size = stim_size(dist,h,pixpitch)
size = round(ones(1,2)*Deg2Pix(str2double(get(h,'string')), dist,pixpitch));
end
