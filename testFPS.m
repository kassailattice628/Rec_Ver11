clear

imaq.vid = videoinput( 'pointgrey' , 1, 'F7_Raw8_640x512_Mode1');
imaq.src = getselectedsource(imaq.vid);

rec_time = 5; % sec
imaq.vid.FramesPerTrigger = 2000;
imaq.vid.TriggerFrameDelay = 0;

imaq.vid.LoggingMode = 'memory';

triggerconfig(imaq.vid, 'immediate');
imaq.vid.ROIPosition = [80 116 480 280];

imaq.src.Brightness = 20;
imaq.src.Exposure = 1.6;
imaq.src.FrameRatePercentage = 100;
imaq.src.Gain = 16;
imaq.src.Shutter=1.3;

start(imaq.vid);


[img, t] = getdata(imaq.vid);
totaltime = (t(end) - t(1));
FPS = imaq.vid.FramesPerTrigger/totaltime;
disp(FPS);
disp(totaltime)
imshow(img(:,:,:,100))
flushdata(imaq.vid)