function imaq = imaq_ini(varargin)

if narargin == 1
    recobj = varargin{1};
    save_mode = 0;
elseif narargin == 2
    recobj = varargin{1};
    save_mode = varargin{2};
end
    

imaq.vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
imaq.src = getselectedsource(imaq.vid);

% set the number of frame
imaq.frame_rate = 475;

rec_time = recobj.rect / 1000; % sec
imaq.vid.FramesPerTrigger = rec_time * imaq.frame_rate;
imaq.vid.TriggerFrameDelay = 0;
imaq.src.FrameRatePercentage = 100;

% set save mode
if save_mode == 0
    imaq.vid.LoggingMode = 'disk';
elseif save_mode == 1
    imaq.vid.LoggingMode = 'disk&memory';
end


%triggerconfig(vid, 'immediate' ); % cature when calls start(vid)
triggerconfig(imaq.vid, 'manual' ); % capture when calls trigger(vid)
% set external trigger and trigger source
%triggerconfig(vid, 'hardware' , 'risingEdge', 'externalTriggerMode0-Source0' );

% image size
imaq.vid.ROIPosition = [80 116 480 280];

imaq.src.ShutterMode = 'Manual' ;% 'Manual', or 'Auto'
imaq.src.GainMode = 'Auto' ;% 'Manual', or 'Auto'



end
