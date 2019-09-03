function imaq = imaq_ini(varargin)

recobj = varargin{1};
position = varargin{2};


%imaq.vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
%Grasshopper3
%imaq.vid = videoinput('pointgrey', 1, 'F7_Raw8_1920x1200_Mode0');
imaq.vid = videoinput('pointgrey', 1, 'F7_Raw8_960x600_Mode1');
imaq.src = getselectedsource(imaq.vid);

% set the number of frame
imaq.frame_rate = 500;

rec_time = recobj.rect / 1000; % sec
imaq.vid.FramesPerTrigger = rec_time * imaq.frame_rate;
imaq.vid.TriggerFrameDelay = 0;

% set save mode
imaq.vid.LoggingMode = 'disk'; % 'disk' or 'memory'


%triggerconfig(imaq.vid, 'manual' ); % capture when calls trigger(vid)
% set external trigger and trigger source
triggerconfig(imaq.vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0'); 
%triggerconfig(vid, 'hardware' , 'risingEdge', 'externalTriggerMode0-Source0' );

%Important #GUI ‚Å Full size image ‚©‚ç‘I‚×‚é‚æ‚¤‚É‚Å‚«‚é‚Æ—Ç‚¢
imaq.vid.ROIPosition = position;
%imaq.vid.ROIPosition = [380 174 192 168];

%imaq.src.Brightness = 0.635;
imaq.src.Exposure = 1.358;
imaq.src.FrameRatePercentage = 100;
imaq.src.Gain = 11.398;
imaq.src.Shutter=1.924;
end
