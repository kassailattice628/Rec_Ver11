function h = open_prev_window(hObject)
global imaq
h.fig = figure('Name', 'Preview', 'Position', [250, 300, 300, 300],...
    'NumberTitle', 'off', 'Menubar', 'none',...
    'DeleteFcn', {@close_preview, hObject});
%{
vidRes = imaq.vid.VideoResolution;
nBands = imaq.vid.NumberOfBands;
hImage = image(zeros(vidRes(1), vidRes(2), nBands));
%}
    
if isfield(imaq, 'roi_position')
    imaq.vid.ROIPosition = imaq.roi_position;
    hImage = image(zeros(imaq.roi_position(3), imaq.roi_position(4), 1));
else
    hImage = image(zeros(192, 168, 1));
end

preview(imaq.vid, hImage)

end
%%
function close_preview(~, ~, hObject)
global prevobj
prevobj = rmfield(prevobj, 'fig');
set(hObject, 'value', 0, 'BackGroundColor', [0.9400 0.9400 0.9400]);
end