function change_looming_params(~, ~)
global figUIobj
global sobj
global recobj

if strcmp(sobj.pattern, 'Looming')
    % set looming speed.
    loomSpd_list = get(figUIobj.loomSpd, 'string');
    
    sobj.loomSize_pix = getStimSize(sobj.MonitorDist, figUIobj.loomSize, sobj.pixpitch);
    
    sobj.maxSize_deg = str2double(get(figUIobj.loomSize, 'string'));
    
    sobj.loomSpd_deg = str2double(loomSpd_list{get(figUIobj.loomSpd, 'value'), 1});
    
    sobj.loomDuration = sobj.maxSize_deg/sobj.loomSpd_deg;
    
    % change recording duration
    rect_in_sec = (sobj.loomDuration+1)*10; % add 1 sec
    recobj.rect = 100*round(rect_in_sec);
    set(figUIobj.rect, 'string', recobj.rect)
end

end
