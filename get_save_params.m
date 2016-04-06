function save = get_save_params(recobj, sobj)
% save parameters for Ver11.03
% these paraemters are updated in evely loop and saved in a cell.

%%%% Timing Data %%%%
save.cycleNum = recobj.cycleNum; % > Visual Stim ON
save.RecStartTime = recobj.tRec; % AI trigger time from the first AI Trigger.

save.PTBOn_time = sobj.vbl_2-sobj.vbl_1;
save.PTBOff_time = sobj.vbl_3 - sobj.vbl_2;

save.stim1.lumi = sobj.lumi;
sobj.stim1.color = sobj.stimcol1;

%%%% Visual Stimuli %%%%
%save.divnum = sobj.divnum; % Monitor division
pattern = sobj.pattern;


%center position
save.stim1.center_position = sobj.center_index;
save.stim1.centerX_pix = sobj.stim_center(1);
save.stim1.centerY_pix = sobj.stim_center(2);
%size
save.stim1.size_deg = sobj.size_deg;
save.stim1.sizeX_pix = sobj.stim_size(1);
save.stim1.sizeY_pix = sobj.stim_size(2);

if strcmp(pattern,'Looming')
    %looming speed and maximum size
    save.stim1.LoomingSpd_deg_s = sobj.loomSpd_deg;
    save.stim1.LoomingMaxSize_deg =sobj.maxSize_deg;
    
elseif strcmp(pattern,'1P_Conc') || strcmp(pattern,'2P_Conc') || strcmp(pattern,'B/W')
    %concentric_position stim1 or stim 2
    save.dist_deg = sobj.concentric_mat_deg(sobj.conc_index, 1);
    save.angle_deg = sobj.concentric_mat_deg(sobj.conc_index, 2);
    
    if strcmp(pattern, '2P_Conc')
        %params for stim2
        % timing
        save.PTBOn_time2 = sobj.vbl2_2-sobj.vbl_1;
        save.PTBOff_time2 = sobj.vbl2_3 - sobj.vbl2_2;
        %center position
        save.stim2.centerX_pix = sobj.stim_center2(1);
        save.stim2.centerY_pix = sobj.stim_center2(2);
        save.stim2.size_deg = sobj.size_deg2;
        %size
        save.stim2.sizeX_pix = sobj.stim_size2(1);
        save.stim2.sizeY_pix = sobj.stim_size2(2);
        
    end
    
elseif strcmp(pattern,'Images')
    %Image
    save.stim1.Image_index = sobj.Img_i;
    
else
    %Sin, Rect, Gabor
    % Grating pramas
    save.stim1.gratingSF_cyc_deg = sobj.gratFreq;
    save.stim1.gratingSpd_Hz = sobj.shiftSpd;
    save.stim1.gratingAngle_deg = sobj.angle;
end
























%}