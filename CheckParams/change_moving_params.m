function change_moving_params(~,~)
global figUIobj
global sobj
global recobj


switch sobj.pattern
    case 'Looming'
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
        
    case 'MoveBar'
        Spd_list = get(figUIobj.loomSpd, 'string');
        
        sobj.moveSpd_deg = str2double(Spd_list{get(figUIobj.loomSpd, 'Value'), 1});
        moveSpd_pix = Deg2Pix(sobj.moveSpd_deg, sobj.MonitorDist, sobj.pixpitch);
        
        %duration = monitor witdh(pix) / Spd
        switch get(figUIobj.shiftDir, 'value')
            case {1, 5} %horizontal
                dist = sobj.RECT(3) + sobj.stimsz(1);
                spd = moveSpd_pix;
                
            case {3, 7} %vertical
                dist = sobj.RECT(4) + sobj.stimsz(1);
                spd = moveSpd_pix;
                
            case {2, 4, 6, 8, 9, 10} % diagonal
                dist = sobj.RECT(3) + sobj.RECT(4) + sobj.stimsz(1);
                spd = moveSpd_pix * cos(pi/4);
                
            case 11
                dist = sobj.RECT(3) + sobj.RECT(4)*2 + sobj.stimsz(1);
                spd = moveSpd_pix * cos(pi/8);
        end
        sobj.moveDuration = round(dist/spd);
        
        %change recording duration
        rect_in_sec = (sobj.moveDuration+1)*10; %add 1sec
        recobj.rect =  100*round(rect_in_sec);
        set(figUIobj.rect, 'String', recobj.rect);
        disp(['Recording Time:: ', num2str(recobj.rect), ' ms'])
end
end