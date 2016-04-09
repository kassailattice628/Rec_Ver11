function save = get_save_params(recobj, sobj)
% save parameters for Ver11.03
% these paraemters are updated in evely loop and saved in a cell.

pattern = sobj.pattern;

%%%% Timing Data %%%%
save.cycleNum = recobj.cycleNum; % > Visual Stim ON
save.RecStartTime = recobj.tRec; % AI trigger time from the first AI Trigger.

if recobj.cycleNum > 0
    save.stim1.On_time = sobj.vbl_2-sobj.vbl_1;
    save.stim1.Off_time = sobj.vbl_3 - sobj.vbl_2;
    
    save.stim1.lumi = sobj.lumi;
    save.stim1.color = sobj.stimcol;
    
    %%%% Visual Stimuli %%%%
    
    %center position
    save.stim1.center_position = sobj.center_index;
    save.stim1.centerX_pix = sobj.stim_center(1);
    save.stim1.centerY_pix = sobj.stim_center(2);
    %size
    save.stim1.size_deg = sobj.size_deg;
    save.stim1.sizeX_pix = sobj.stim_size(1);
    save.stim1.sizeY_pix = sobj.stim_size(2);
    
    switch pattern
        case 'Looming'
            %looming speed and maximum size
            save.stim1.LoomingSpd_deg_s = sobj.loomSpd_deg;
            save.stim1.LoomingMaxSize_deg =sobj.maxSize_deg;
            
        case {'1P_Conc','2P_Conc','B/W'}
            %concentric_position stim1 or stim 2
            save.stim1.dist_deg = sobj.concentric_mat_deg(sobj.conc_index, 1);
            save.stim1.angle_deg = sobj.concentric_mat_deg(sobj.conc_index, 2);
            
            if strcmp(pattern, '2P_Conc')
                %params for stim2
                % timing
                save.stim2.On_time = sobj.vbl2_2-sobj.vbl_1;
                save.stim2.Off_time = sobj.vbl2_3 - sobj.vbl2_2;
                %center position
                save.stim2.centerX_pix = sobj.stim_center2(1);
                save.stim2.centerY_pix = sobj.stim_center2(2);
                save.stim2.size_deg = sobj.size_deg2;
                %size
                save.stim2.sizeX_pix = sobj.stim_size2(1);
                save.stim2.sizeY_pix = sobj.stim_size2(2);
                %
                save.stim2.lumi = sobj.lumi2;
                save.stim2.color = sobj.stimcol2;
            end
            
        case 'Images'
            %Image
            save.stim1.Image_index = sobj.img_i;
            
        case {'Sin', 'Rect', 'Gabor'}
            %Sin, Rect, Gabor
            % Grating pramas
            save.stim1.gratingSF_cyc_deg = sobj.gratFreq;
            save.stim1.gratingSpd_Hz = sobj.shiftSpd;
            save.stim1.gratingAngle_deg = sobj.angle;
    end
end

end