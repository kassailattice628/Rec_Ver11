function imaq = imaq_ini(varargin)

if nargin == 1
    recobj = varargin{1};
    save_mode = 0;
elseif nargin == 2
    recobj = varargin{1};
    save_mode = varargin{2};
end
    

imaq.vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
imaq.src = getselectedsource(imaq.vid);

% set the number of frame
imaq.frame_rate = 460;

rec_time = recobj.rect / 1000; % sec
imaq.vid.FramesPerTrigger = rec_time * imaq.frame_rate;
imaq.vid.TriggerFrameDelay = 0;

% set save mode
if save_mode == 0
    imaq.vid.LoggingMode = 'disk';
elseif save_mode == 1
    imaq.vid.LoggingMode = 'disk&memory';
end

triggerconfig(imaq.vid, 'manual' ); % capture when calls trigger(vid)
% set external trigger and trigger source
%triggerconfig(vid, 'hardware' , 'risingEdge', 'externalTriggerMode0-Source0' );

% image size
imaq.vid.ROIPosition = [80 116 480 280];

imaq.src.Brightness = 20;
imaq.src.Exposure = 1.6;
imaq.src.FrameRatePercentage = 100;
imaq.src.Gain = 16;
imaq.src.Shutter=1.3;



end
