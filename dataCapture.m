function dataCapture(src, event, c, hGui)
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
%   c.plotTimeSpan    = continuous acquired data timespan (seconds)
%

% The incoming data (event.Data and event.TimeStamps) is stored in a
% persistent buffer (dataBuffer), which is sized to allow triggered data
% capture.

% Since multiple calls to dataCapture will be needed for a triggered
% capture, a trigger condition flag (trigActive) and a corresponding
% data timestamp (trigMoment) are used as persistent variables.
% Persistent variables retain their values between calls to the function.

persistent dataBuffer trigActive trigMoment
disp('dataCapture called')

% If dataCapture is running for the first time, initialize persistent vars
if event.TimeStamps(1)==0
    dataBuffer = [];          % data buffer
    trigActive = false;       % trigger condition flag
    trigMoment = [];          % data timestamp when trigger condition met
end

% Store continuous acquistion data in persistent FIFO buffer dataBuffer
latestData = [event.TimeStamps, event.Data];
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% If capture is requested, analyze latest acquired data until a trigger
% condition is met. After enough data is acquired for a complete capture,
% as specified by the capture timespan, extract the capture data from the
% data buffer and save it to a base workspace variable.

% Get capture push button (loop) value (1 or 0) from UI
captureRequested = get(hGui.loop, 'value'); % Loop-ON
%trigConfig.Channel = 4;%Trigger input ‚Í AI3
if captureRequested && (~trigActive)
    % State: "Looking for trigger event"
    disp('Waiting for trigger');

    % Get the trigger configuration parameters from UI text inputs and
    %   place them in a structure.
    % For simplicity, validation of user input is not addressed in this example.
    trigConfig.Channel = 4;
    trigConfig.Level = 1;
    
    % Determine whether trigger condition is met in the latest acquired data
    % A custom trigger condition is defined in trigDetect user function
    [trigActive, trigMoment] = trigDetect(latestData, trigConfig);
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) > c.TimeSpan)
    % State: "Acquired enough data for a complete capture"
    disp('Acquired enough data');
    % If triggered and if there is enough data in dataBuffer for triggered
    % capture, then captureData can be obtained from dataBuffer.
    
    % Find index of sample in dataBuffer with timestamp value trigMoment
    trigSampleIndex = find(dataBuffer(:,1) == trigMoment, 1, 'first');
    % Find index of sample in dataBuffer to complete the capture
    lastSampleIndex = round(trigSampleIndex + c.TimeSpan * src.Rate());
    captureData = dataBuffer(trigSampleIndex:lastSampleIndex, :);
    
    % Reset trigger flag, to allow for a new triggered data capture
    trigActive = false;

    % Update captured data plot (one line for each acquisition channel)
    % captureData(:,1) is timstamp
    % captureData(:,2:n) is data from AI channel(1:n)
    % plot AI0
    %hGui.p2 = plot(hGui.t,hGui.y2, 'XdataSource','hGui.t','YDataSource', 'hGui.y2');
    %hGui.t = captureData(:,1);
    %hGui.y2 = captureData(:,2);
    set(hGui.p2, 'XData', captureData(:, 1), 'YData', captureData(:, 2))
    
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) < c.TimeSpan)
    disp('Capturing data')
elseif ~captureRequested
    % State: "Capture not requested"
    % Capture toggle button is not pressed, set trigger flag and update UI
    trigActive = false;
    disp('Capture not requested')
end

drawnow;

end