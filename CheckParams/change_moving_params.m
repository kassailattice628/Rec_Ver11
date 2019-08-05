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
        
        %deg/sec
        sobj.moveSpd_deg = str2double(Spd_list{get(figUIobj.loomSpd, 'Value'), 1});
        
        %pix/sec
        moveSpd_pix = Deg2Pix(sobj.moveSpd_deg, sobj.MonitorDist, sobj.pixpitch);
        
        %duration = move Distance / Spd
        sobj.stimsz = getStimSize(sobj.MonitorDist, figUIobj.size, sobj.pixpitch);
        
        switch get(figUIobj.shiftDir, 'value')
            case {1, 5} %horizontal
                dist = sobj.RECT(3) + sobj.stimsz(1);
                spd = moveSpd_pix;
                
            case {3, 7} %vertical
                dist = sobj.RECT(4) + sobj.stimsz(1);
                spd = moveSpd_pix;
                
            case {2, 4, 6, 8} %diagonal
                dist = sobj.RECT(3) + sobj.RECT(4)/tan(pi/4);
                spd = moveSpd_pix / cos(pi/4);
            
            case {9, 10} %rand8
                dist = [sobj.RECT(3),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(pi/4),...
                    sobj.RECT(4)];
                
                spd = [moveSpd_pix, moveSpd_pix/sin(pi/4), moveSpd_pix];
                
            case 11 %rand16
                dist = [sobj.RECT(3),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(pi/4),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(3*pi/8),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(pi/8),...
                    sobj.RECT(4)];
                
                spd = [moveSpd_pix,...
                    moveSpd_pix/sin(pi/4),...
                    moveSpd_pix/sin(3*pi/8),...
                    moveSpd_pix/sin(pi/8),...
                    moveSpd_pix];
            
            case 12 %rand12
                dist = [sobj.RECT(3),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(pi/3),...
                    sobj.RECT(3) + sobj.RECT(4)/tan(pi/6),...
                    sobj.RECT(4)];
                
                spd = [moveSpd_pix,...
                    moveSpd_pix/sin(pi/3),...
                    moveSpd_pix/sin(pi/6),...
                    moveSpd_pix];
        end
        sobj.moveDuration = round(dist./spd);
        max_moveDuration =  max(round(dist./spd));

        disp(['Move Dist:' , num2str(dist)])
        disp(['Move Spd:' , num2str(spd)])
        disp(['FlipNum:', num2str(round(sobj.moveDuration/sobj.m_int))]);
        
        %change recording duration
        rect_in_sec = (max_moveDuration + 1) * 10; %add 1sec
        recobj.rect = 100 * round(rect_in_sec);
        set(figUIobj.rect, 'String', recobj.rect);
        disp(['Recording Time:: ', num2str(recobj.rect), ' ms'])
        
    case 'MoveSpot'
        
        Spd_list = get(figUIobj.loomSpd, 'string');
        %deg/sec
        sobj.moveSpd_deg = str2double(Spd_list{get(figUIobj.loomSpd, 'Value'), 1});
        %Speed, pix/sec
        moveSpd_pix = Deg2Pix(sobj.moveSpd_deg, sobj.MonitorDist, sobj.pixpitch);
        
        %Travel Distance(pix)
        dist = Deg2Pix(str2double(get(figUIobj.dist, 'String')), sobj.MonitorDist, sobj.pixpitch);
        
        %Duration (sec)
        sobj.moveDuration = round(dist./moveSpd_pix);
        
        
        sobj.stimsz = getStimSize(sobj.MonitorDist, figUIobj.size, sobj.pixpitch);
        
        %change recording duration
        rect_in_sec = (sobj.moveDuration + 1) * 10; %add 1 sec
        recobj.rect = 100 * round(rect_in_sec);
        set(figUIobj.rect, 'String', recobj.rect);
        disp(['Recordign Time:: ', num2str(recobj.rect), ' ms']);
end
end