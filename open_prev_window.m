function h = open_prev_window(hObject)
global imaq
h.fig = figure('Name', 'Preview', 'Position', [20, 500, 300, 200],...
    'NumberTitle', 'off', 'Menubar', 'none',...
    'DeleteFcn', {@close_preview, hObject});
%{
vidRes = imaq.vid.VideoResolution;
nBands = imaq.vid.NumberOfBands;
hImage = image(zeros(vidRes(2), vidRes(1), nBands));
%}
hImage = image(zeros(280, 480, 1));
preview(imaq.vid, hImage)

end
%%
function close_preview(~, ~, hObject)
global prevobj
prevobj = rmfield(prevobj, 'fig');
set(hObject, 'value', 0, 'BackGroundColor', [0.9400 0.9400 0.9400]);
end