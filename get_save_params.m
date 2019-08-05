function save = get_save_params(Testmode, recobj, sobj, data)
% save parameters for Ver11
% these paraemters are updated in evely loop and saved in a cell-variable.

global figUIobj

%%
pattern = sobj.pattern;
mode = sobj.mode;

%%%% Timing Data %%%%
save.cycleNum = recobj.cycleNum; % > Visual Stim ON
if Testmode == 0
save.RecStartTime = recobj.t_AIstart; % AI trigger time from the first AI Trigger.
save.AIStartTime = data(1, 1);
save.AIEndTime = data(end, 1);
save.AIstep = data(2,1) - data(1,1);
end
save.vbl_1 = sobj.vbl_1;

if get(figUIobj.stim,'value') && recobj.cycleNum > 0
    save.vbl_2 = sobj.vbl_2;
    save.vbl_3 = sobj.vbl_3;
    
    % Stimi ON %
    save.stim1.On_time = sobj.vbl_2 - sobj.vbl_1;
    save.stim1.BeamposON = sobj.BeamposON;
    % Stimi OFF %
    save.stim1.Off_time = sobj.vbl_3 - sobj.vbl_1;
    save.stim1.BeamposOFF = sobj.BeamposOFF;
    
    %%% Luminance & Color %%%
    save.stim1.lumi = sobj.stimlumi;
    save.stim1.color = sobj.stimcol;
    
    %%% Center Position %%%
    save.stim1.center_position = sobj.center_index;
    save.stim1.centerX_pix = sobj.stim_center(1);
    save.stim1.centerY_pix = sobj.stim_center(2);
    
    %concentric position
    if strcmp(mode, 'Concentric')
        % concentric_position
        save.stim1.dist_deg = sobj.concentric_mat_deg(sobj.conc_index, 1);
        save.stim1.angle_deg = sobj.concentric_mat_deg(sobj.conc_index, 2);
    end
    
    %%% Size %%%
    save.stim1.size_deg = sobj.size_deg;
    save.stim1.sizeX_pix = sobj.stim_size(1);
    save.stim1.sizeY_pix = sobj.stim_size(2);
    
    %%% Stim.Pattern Specific Parameters %%%
    switch pattern
        case {'Uni', 'Size_rand'}

            
        case {'2P','B/W'}
            % concentric_position stim1 or stim 2
            save.stim1.dist_deg = sobj.concentric_mat_deg(sobj.conc_index, 1);
            save.stim1.angle_deg = sobj.concentric_mat_deg(sobj.conc_index, 2);
            
            if strcmp(pattern, '2P')
                % params for stim2
                % timing
                if get(figUIobj.stim,'value')
                    % Stim ON %
                    save.stim2.On_time = sobj.vbl2_2 - sobj.vbl_1;
                    save.stim2.BeamposON = sobj.BeamposON_2;
                    % Stim Off %
                    save.stim2.Off_time = sobj.vbl2_3 - sobj.vbl2_2;
                    save.stim2.BeamposOFF = sobj.BeamposOFF_2;
                end
                % center position
                save.stim2.centerX_pix = sobj.stim_center2(1);
                save.stim2.centerY_pix = sobj.stim_center2(2);
                % size
                save.stim2.size_deg = sobj.size_deg2;
                save.stim2.sizeX_pix = sobj.stim_size2(1);
                save.stim2.sizeY_pix = sobj.stim_size2(2);
                % color luminace
                save.stim2.lumi = sobj.lumi2;
                save.stim2.color = sobj.stimcol2;
            end
            
        case 'Looming'
            % looming speed and maximum size
            save.stim1.LoomingSpd_deg_s = sobj.loomSpd_deg;
            save.stim1.LoomingMaxSize_deg = sobj.maxSize_deg;
            
        case 'MoveBar'
            % Mogving direction and speed.
            save.stim1.MovebarSpd_deg_s = sobj.moveSpd_deg;
            save.stim1.MovebarDir_angle_deg = sobj.angle;
            
        case 'StaticBar'
            %Orientation, Bar length
            save.stim1.BarOri_angle_deg = wrapTo360(sobj.angle*2)/2;
            %bar legnth => sobj.stim_length
            
        case 'MoveSpot'
            save.stim1.MovebarSpd_deg_s = sobj.moveSpd_deg;
            save.stim1.MovebarDir_angle_deg = sobj.angle;
            
        case {'Sin', 'Rect', 'Gabor'}
            % Sin, Rect, Gabor, Grating pramas
            save.stim1.gratingSF_cyc_deg = sobj.gratFreq;
            save.stim1.gratingSpd_Hz = sobj.shiftSpd;
            save.stim1.gratingAngle_deg = sobj.angle;
            
        case 'Images'
            % Image
            save.stim1.Image_index = sobj.img_i;
            if strcmp(mode, 'Concentric')
                save.stim1.dist_deg = sobj.concentric_mat_deg(sobj.conc_index, 1);
                save.stim1.angle_deg = sobj.concentric_mat_deg(sobj.conc_index, 2);
            end
            
        case {'Mosaic'}
            % Mosaic Dot pattern
            save.stim1.RandPosition_seed = sobj.def_seed1; % for position
            save.stim1.RandSize_seed = sobj.def_seed2; % for size
            
            % tentative
            % if the two seeds were enough to reproduce mosaic
            % dots, following prams dose'nt need to be saved.
            save.stim1.position_deg_mat = sobj.dot_position_deg;
            save.stim1.size_deg_mat = sobj.dot_sizes_deg;
            
        case {'FineMap'}
            % Fine mapping by using a small area
            save.stim1.center_position_FineMap = sobj.center_index_FineMap;
    end
end
