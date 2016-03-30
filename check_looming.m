function check_looming(~, ~)
global sobj
global figUIobj
global recobj

if strcmp(sobj.pattern,'Looming')
    % change recording time according to the looming speed.
    loomSpd_list = get(figUIobj.loomSpd, 'string');
    
    sobj.loomSize_pix = stim_size(sobj.MonitorDist, figUIobj.loomSize, sobj.pixpitch);
    
    sobj.maxSize_deg = str2double(get(figUIobj.loomSize,'string'));  
    sobj.loomSpd_deg = str2double(loomSpd_list{get(figUIobj.loomSpd,'value'),1});
    sobj.loomDuration = sobj.maxSize_deg/sobj.loomSpd_deg;
    
    rect_in_sec = (sobj.loomDuration + 1) * 10; % add 1 sec 
    recobj.rect = 100 * round(rect_in_sec);
    
    set(figUIobj.rect, 'string', recobj.rect, 'BackgroundColor', 'y');
    set(figUIobj.loomSize, 'BackgroundColor', 'g');
    
else
    set(figUIobj.loomSize, 'BackgroundColor', 'w');
    set(figUIobj.rect, 'BackgroundColor', 'g');
    recobj.rect = re_write(figUIobj.rect);
end

end

%%
function size = stim_size(dist , h, pixpitch)
size = round(ones(1,2)*Deg2Pix(str2double(get(h,'string')), dist, pixpitch));
end

function y = re_write(h)
y = str2double(get(h,'string'));
end