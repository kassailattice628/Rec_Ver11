function dataCaptureNBA(src, event, c, hGui, Recmode, SetCam)
%dataCapture Process DAQ acquired data when called by DataAvailable event.
%  dataCapture (SRC, EVENT, C, HGUI) processes latest acquired data (EVENT.DATA)
%  and timestamps (EVENT.TIMESTAMPS) from session (SRC), and, based on specified
%  capture parameters (C structure) and trigger configuration parameters from
%  the user interface elements (HGUI handles structure), updates UI plots
%  and captures data.
%
%   c.TimeSpan        = triggered capture timespan (seconds)
%   c.bufferTimeSpan  = required data buffer timespan (seconds)
%   c.bufferSize      = required data buffer size (number of scans)
%
% The incoming data (event.Data and event.TimeStamps) is stored in a
% persistent buffer (dataBuffer), which is sized to allow triggered data
% capture.
% Since multiple calls to dataCapture will be needed for a triggered
% capture, a trigger condition flag (trigActive) and a corresponding
% data timestamp (trigMoment) are used as persistent variables.
% Persistent variables retain their values between calls to the function.
%%
global plotUIobj
global recobj
global sobj
global DataSave
global ParamsSave
global imaq


%% keep parameter during loop
persistent dataBuffer trigActive trigMoment trigCount
%%
% If dataCapture is running for the first time, initialize persistent vars
if event.TimeStamps(1)==0
    dataBuffer = [];          % data buffer
    trigActive = false;       % trigger condition flag
    trigMoment = [];          % data timestamp when trigger condition met
    trigCount = 0;
end

% Store continuous acquistion data in persistent FIFO buffer dataBuffer
latestData = [event.TimeStamps, event.Data]; %after 'event' is avairable
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

%% Update live data plot, Plot latest plotTimeSpan seconds of data in dataBuffer
if isfield(plotUIobj, 'button4')
    if get(plotUIobj.button4{1,1},'value') || ...
            get(plotUIobj.button4{1,2},'value') || ...
            get(plotUIobj.button4{1,3},'value') || ...
            get(plotUIobj.button4{1,4},'value')
        
        samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBuffer,1)]);
        firstPoint = size(dataBuffer, 1) - samplesToPlot + 1;
        % Update x-axis limits
        set(plotUIobj.axes4, 'XLim', [dataBuffer(firstPoint,1), dataBuffer(end,1)]);
        
        % Live plot has one line for each acquisition channel
        for ii = 1:size(plotUIobj.button4, 2)
            if get(plotUIobj.button4{1,ii},'value')
                set(plotUIobj.plot4(ii), ...
                    'XData', dataBuffer(firstPoint:end, 1),...
                    'YData', dataBuffer(firstPoint:end, ii+1)...
                    )
            end
        end
        
    end
end
%%
% If capture is requested, analyze latest acquired data until a trigger
% condition is met. After enough data is acquired for a complete capture,
% as specified by the capture timespan, extract the capture data from the
% data buffer and save it to a base workspace variable.
captureRequested = get(hGui.loop, 'value'); % Loop-ON
if captureRequested && (~trigActive)
    % State: "Looking for trigger event"
    % Trigger Configuration
    trigConfig.Channel = 4; %Trigger monitor
    trigConfig.Level = 2; %(V) Trigger threshold
    % Determine whether trigger condition is met in the latest acquired data
    [trigActive, trigMoment] = trigDetectNBA(latestData, trigConfig);
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) > c.TimeSpan)
    % State: "Acquired enough data for a complete capture"
    % If triggered and if there is enough data in dataBuffer for triggered
    % capture, then captureData can be obtained from dataBuffer.
    
    % Find index of sample in dataBuffer with timestamp value trigMoment
    trigSampleIndex = find(dataBuffer(:,1) == trigMoment, 1, 'first');
    
    % Find index of sample in dataBuffer to complete the capture
    lastSampleIndex = round(trigSampleIndex + c.TimeSpan * src.Rate());
    captureData = dataBuffer(trigSampleIndex:lastSampleIndex, :);
    trigCount = trigCount + 1;
    
    % Update captured data plot (one line for each acquisition channel)
    % captureData(:,1) is timstamp
    % 2:AI0, 3:AI1, 4:AI2 = photosensor, 5:AI3 = Triggermonitor
    % Recmode==1
    % 6:AI4, 7:AI5, 8:RotaryEnconder
    % Recmode==2
    % 6:RotaryEncoder
    % plotVI = get(figUIobj.plot, 'value'): AI0='V plot, AI1='I plot'
    
    if isfield(plotUIobj,'button4')
        if Recmode == 1
            if get(plotUIobj.button1_1, 'value') % Eye Position from iRecHS2
                set(plotUIobj.plot1_1(1), 'XData', captureData(:, 1), 'YData', captureData(:,2))
                set(plotUIobj.axes1_1, 'XLim', [-inf,inf]);
            end
            
            if get(plotUIobj.button1_2, 'value')
                set(plotUIobj.plot1_2(1), 'Xdata', captureData(:, 1), 'YData', captureData(:, 3))
                set(plotUIobj.axes1_2, 'XLim', [-inf, inf]);
            end
        elseif Recmode == 2
            plotVI = get(hGui.plot,'value');
            if get(plotUIobj.button1, 'value') % V or I plot
                set(plotUIobj.plot1, 'XData', captureData(:, 1), 'YData', captureData(:,plotVI+2))
                set(plotUIobj.axes1, 'XLim',[-inf,inf]);
            end
        end
        
        % photo sencer
        if get(plotUIobj.button2, 'value')
            set(plotUIobj.plot2, 'XData', captureData(:, 1), 'YData', captureData(:, 4))
            set(plotUIobj.axes2, 'XLim',[-inf,inf]);
        end
        
        %when Rotary ON, plot Angular Position
        if get(plotUIobj.button3,'value')
            %decode rotary
            if Recmode == 1
                rot_ch = 8;
            else
                rot_ch = 6;
            end
            positionDataDeg = DecodeRot(captureData(:, rot_ch));
            set(plotUIobj.axes3, 'XLim',[-inf,inf]);
            set(plotUIobj.plot3, 'XData', captureData(:, 1), 'YData', positionDataDeg)%Decoded Angular position data
        end
        %update plot
        drawnow update;
    end
    trigActive = false;
    
    %%%%%% save setting %%%%%%
    if get(hGui.save, 'value') == 1 % Saving
        DataSave(:, :, trigCount) = captureData;
        ParamsSave{1, trigCount} = get_save_params(recobj, sobj);
    end
    
    %%%%%% wait save imaq %%%%%
    if SetCam

    end
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) < c.TimeSpan)
    %disp('data short ')
elseif ~captureRequested
    % State: "Loop Out"
    trigActive = false;
end
end

%%
function [trigDetected, trigMoment] = trigDetectNBA(latestData, trigConfig)
%TRIGDETECT Detect if trigger condition is met in acquired data
%   trigConfig.Channel = index of trigger channel in session channels
%   trigConfig.Level   = signal trigger level (V)

% Condition for signal trigger level
trigCondition = latestData(:, 1+trigConfig.Channel) > trigConfig.Level;

trigDetected = any(trigCondition);
trigMoment = [];

if trigDetected
    % Find time moment when trigger condition has been met
    trigTimeStamps = latestData(trigCondition, 1);
    trigMoment = trigTimeStamps(1);
end
end

%%
function positionDataDeg = DecodeRot(CTRin)
% Transform counter data from rotary encoder into angular position (deg).
signedThreshold = 2^(32-1); %resolution 32 bit
signedData = CTRin; % data from DAQ
signedData(signedData > signedThreshold) = signedData(signedData > signedThreshold) - 2^32;
positionDataDeg = signedData * 360/1000/4;

end