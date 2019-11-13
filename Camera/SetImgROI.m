function SetImgROI
%Camera画像を全解像度で１枚取得して、眼球が収まるように ROI の位置を設定
%
global imaq
imaqreset;

if isfield(imaq, 'vid')
    delete(imaq.vid)
end

imaq.vid = videoinput('pointgrey', 1, 'F7_Raw8_960x600_Mode1');
imaq.vid.ROIPosition = [0 0 960, 600];

imaq.vid.FramesPerTrigger = 1;
imaq.src = getselectedsource(imaq.vid);
imaq.frame_rate = 500;
imaq.src.Exposure = 1.358;
imaq.src.FrameRatePercentage = 100;
imaq.src.Gain = 11.398;
imaq.src.Shutter=1.924;

imaq.vid.LoggingMode = 'memory';
triggerconfig(imaq.vid, 'immediate'); 
imaq.vid.triggerRepeat = 0;

start(imaq.vid)
img = getdata(imaq.vid);
fh = figure;
set(fh, 'WindowButtonUpFcn', @GetPos)
imshow(img);

if ~isfield(imaq, 'roi_position')
    imaq.roi_position = [380 174 192 168];
end

roi = imrect(gca, imaq.roi_position);

    function GetPos(~, ~)
        imaq.roi_position = getPosition(roi);
        disp(imaq.roi_position);
    end

end

