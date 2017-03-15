%log of imaqtool, change camera configuration

% create video input object
vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
src = getselectedsource(vid);

% set the number of frame (maximum 100 Hz)
frame_rate = 100;
src.FrameRatePercentage = frame_rate;

% recording time = recobj.rect
recobj.rect = 5000;
rec_time = recojb.rect/1000;

vid.FramesPerTrigger = rec_time*frame_rate;
src.FrameRatePercentage = 10;

%vid.LoggingMode = 'disk' ;
%vid.LoggingMode = 'disk&memory' ;
vid.LoggingMode = 'memory' ;


%triggerconfig(vid, 'immediate' ); % cature when calls start(vid)
triggerconfig(vid, 'manual' ); % capture when calls trigger(vid)
% set external trigger and trigger source
%triggerconfig(vid, 'hardware' , 'fallingEdge', 'externalTriggerMode0-Source0' );

vid.ROIPosition = [80 116 480 280];

src.ShutterMode = 'Manual' ;% 'Manual', or 'Auto'
src.GainMode = 'Auto' ;% 'Manual', or 'Auto'

%%
% open preview
preview(vid);

% start camera
tic
start(vid);

wait(rec_time)
disp(toc)
trigger(vid)


stoppreview(vid);

captureimg = getdata(vid);
save( '\save_img_name.mat' , 'captureimg');
clear captureimg ;


