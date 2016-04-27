function imaq = imaq_ini(recobj)

imaq.vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
imaq.src = getselectedsource(imaq.vid);

% set the number of frame (maximum 100 Hz)
frame_rate = 100;
imaq.src.FrameRatePercentage = frame_rate;

rec_time = recobj.rect / 1000;
imaq.vid.FramesPerTrigger = rec_time * frame_rate;
imaq.src.FrameRatePercentage = 10;

% set save mode
imaq.vid.LoggingMode = 'disk';% 'memory' ;


%triggerconfig(vid, 'immediate' ); % cature when calls start(vid)
triggerconfig(imaq.vid, 'manual' ); % capture when calls trigger(vid)
% set external trigger and trigger source
%triggerconfig(vid, 'hardware' , 'fallingEdge', 'externalTriggerMode0-Source0' );

% image size
imaq.vid.ROIPosition = [80 116 480 280];

imaq.src.ShutterMode = 'Manual' ;% 'Manual', or 'Auto'
imaq.src.GainMode = 'Auto' ;% 'Manual', or 'Auto'



end
