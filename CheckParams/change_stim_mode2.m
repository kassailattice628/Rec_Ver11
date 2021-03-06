function change_stim_mode2(~, ~)
global figUIobj
global sobj

pattern_list = get(figUIobj.pattern, 'String');
sobj.pattern = pattern_list{get(figUIobj.pattern, 'Value'),1};
mode = get(figUIobj.mode, 'Value');

%%
%rect = Recording Time

key = {'div', 'dist', 'dir', 'dir2', 'shiftSpd', 'gratFreq',...
    'loomSpd', 'loomSize', 'ImageNum', 'dots_density', 'panel2', 'getPos', 'rect'};


%%
switch sobj.pattern
    case {'Uni', 'Size_rand'}
        if mode ==  1 || mode ==  2 || mode ==  4
            %div, dist, dir: OFF
            val = {'off', 'off', 'off', 'off',   'off', 'off',...
                'off', 'off',   'off','off',   'off', 'off', 'g'};
        elseif mode == 3
            %div, dist, dir: OFF
            val = {'on', 'on', 'on', 'off',   'off', 'off',...
                'off', 'off',   'off', 'off',   'off', 'off', 'g'};
        end
        
    case {'2P'}
        if mode == 3
            set(figUIobj.mode, 'Value', 4)
        end
        %div, dist, dir: ON
        val = {'on', 'on', 'on', 'off',   'off', 'off',...
            'off', 'off',   'off', 'off',   'on', 'off', 'g'};
        
    case {'B/W'}
        if mode == 3
            set(figUIobj.mode, 'Value', 4)
        end
        %div, dist, dir: ON
        val = {'on', 'on', 'on', 'off',   'off', 'off',...
            'off', 'off',   'off', 'off',   'off', 'off', 'g'};
        
    case {'Looming'}
        if mode ==  1 || mode ==  2 || mode == 4
            %div, dist, dir: OFF
            val = {'off', 'off', 'off', 'off',   'off', 'off',...
                'on', 'on',   'off', 'off',   'off', 'off', 'y'};
        elseif mode == 3
            %div, dist, dir: OFF
            val = {'on', 'on', 'on', 'off',   'off', 'off',...
                'on', 'on',   'off', 'off',   'off', 'off', 'y'};
            
        end
        
    case {'Sin', 'Rect', 'Gabor'}
        if mode ==  1 || mode ==  2 || mode == 4
            %div, dist, dir: OFF
            val = {'off', 'off', 'on', 'off',    'on', 'on',...
                'off', 'off',   'off', 'off',   'off', 'off', 'g'};
        elseif mode == 3
            %div, dist, dir: OFF
            val = {'on', 'on', 'on', 'on',    'on', 'on',...
                'off', 'off',   'off', 'off',   'off', 'off', 'g'};
        end
        
    case 'MoveBar'
        if mode ~= 4
            set(figUIobj.mode, 'Value', 4)
        end
        %div, dist: OFF, dir:  ON
        val = {'off', 'off', 'on', 'off',   'off', 'off',...
            'on', 'off',   'off', 'off',   'off', 'off', 'y'};
        
    case 'StaticBar'
        if mode ~= 4
            %fixed center position
            set(figUIobj.mode, 'Value', 4)
        end
        
        val = {'off', 'on', 'on', 'off',   'off', 'off',...
            'off', 'off',   'off', 'off',   'off', 'off', 'g'};
        
    case 'MoveSpot'
        if mode ~= 4
            %fixed center position
            set(figUIobj.mode, 'Value', 4)
        end
        %distance, direction, speed
        val = {'off', 'on', 'on', 'off',   'off', 'off',...
            'on', 'off',   'off', 'off',   'off', 'off', 'y'};
        
    case 'Images'
        if mode ==  1 || mode ==  2 || mode == 4
            %div, dist: OFF, dir:  ON
            val = {'off', 'off', 'off', 'off',   'off', 'off',...
                'off', 'off',   'on', 'off',   'off', 'off', 'g'};
        elseif mode == 3
            %div, dist, dir:  ON
            val = {'on', 'on', 'on', 'off',   'off', 'off',...
                'off', 'off',   'on', 'off',   'off', 'off', 'g'};
        end
        
    case 'Mosaic'
        %basically fix position (only mode==4 is used)
        
        set(figUIobj.mode, 'Value', 4);
        mode = 4;
        if mode == 4
            %div, dist:ON, dir: OFF
            val = {'on', 'on', 'off', 'off',   'off', 'off',...
                'off', 'off',   'off', 'on',   'off', 'off', 'g'};
        end
        
        
    case 'FineMap'
        %basically Rand_mat & Ord_mat are used (mode==1 or 2)
        if mode ==  1 || mode ==  2
            %div, dist:ON, dir: OFF
            val = {'on', 'on', 'off', 'off',   'off', 'off',...
                'off', 'off',   'off', 'off',   'off', 'on', 'g'};
        else
            set(figUIobj.mode, 'Value', 2);
            val = {'on', 'on', 'off', 'off',   'off', 'off',...
                'off', 'off',   'off', 'off',   'off', 'on', 'g'};
        end
        
    case 'MouseCursor'
        val = {'off', 'off', 'off', 'off', 'off', 'off',...
            'off', 'off', 'off', 'off', 'off', 'off', 'g'};
        
end
%%
switch get(figUIobj.mode, 'Value')
    case {1, 2}
        set(figUIobj.fixpos, 'BackGroundColor', 'w');
    case 3
        set(figUIobj.fixpos, 'BackGroundColor', 'y');
    case 4
        if strcmp(sobj.pattern, 'MoveBar')
            set(figUIobj.fixpos, 'BackGroundColor', 'w');
        else
            set(figUIobj.fixpos, 'BackGroundColor', 'g');
        end
end

%%
Set_UI_position

map_list = containers.Map(key, val);
Set_fig_stim_color(map_list);


%% #############  subfinctuons  ############
%% Set UI position when stim mode or pattern is changed.
    function Set_UI_position
        switch sobj.pattern
            case {'Uni', 'Size_radn', '2P', 'B/W', 'Images', 'Mosaic'}
                set(figUIobj.div_zoom_txt, 'Position', [10 135 45 15]);
                set(figUIobj.div_zoom, 'Position', [10 110 40 25]);
                set(figUIobj.dist_txt, 'Position', [60 135 45 15]);
                set(figUIobj.dist, 'Position', [60 110 40 25]);
                
            case {'FineMap'}
                set(figUIobj.div_zoom_txt, 'Position', [10 180 45 15]);
                set(figUIobj.div_zoom, 'Position', [10 155 40 25]);
                set(figUIobj.dist_txt, 'Position', [60 180 45 15]);
                set(figUIobj.dist, 'Position', [60 155 40 25]);
                
            case {'Sin', 'Rect', 'Gabor'}
                set(figUIobj.div_zoom_txt, 'Position', [150 230 30 15]);
                set(figUIobj.div_zoom, 'Position', [150 205 40 25]);
                set(figUIobj.dist_txt, 'Position', [150 185 30 15]);
                set(figUIobj.dist, 'Position', [150 160 40 25]);
                
            case 'Looming'
                set(figUIobj.div_zoom_txt, 'Position', [10 90 45 15]);
                set(figUIobj.div_zoom, 'Position', [10 65 40 25]);
                set(figUIobj.dist_txt, 'Position', [60 90 45 15]);
                set(figUIobj.dist, 'Position', [60 65 40 25]);
                
            case 'StaticBar'
                set(figUIobj.dist_txt, 'Position', [10 135 150 15]);
                set(figUIobj.dist, 'Position', [10 110 40 25]);
                
            case 'MoveSpot'
                set(figUIobj.dist_txt, 'Position', [10 90 150 15]);
                set(figUIobj.dist, 'Position', [10 65 40 25]);
                
            otherwise
                
               
                
        end
    end

%% Show/Hide UI parts when stim mode or pattern is changed.
    function Set_fig_stim_color(map_list)
        set(figUIobj.div_zoom, 'Visible', map_list('div'));
        set(figUIobj.div_zoom_txt, 'Visible', map_list('div'));
        
        set(figUIobj.dist, 'Visible',map_list('dist'));
        set(figUIobj.dist_txt, 'Visible',map_list('dist'));
        
        set(figUIobj.shiftDir, 'Visible', map_list('dir'));
        set(figUIobj.shiftDir_txt, 'Visible', map_list('dir'));
        set(figUIobj.shiftDir_txt2, 'Visible', map_list('dir'));
        
        set(figUIobj.shiftDir2, 'Visible', map_list('dir2'));
        set(figUIobj.shiftDir2_txt, 'Visible', map_list('dir2'));
        
        set(figUIobj.shiftSpd, 'Visible', map_list('shiftSpd'));
        set(figUIobj.shiftSpd_txt, 'Visible', map_list('shiftSpd'));
        set(figUIobj.shiftSpd_txt2, 'Visible', map_list('shiftSpd'));
        
        set(figUIobj.gratFreq, 'Visible', map_list('gratFreq'));
        set(figUIobj.gratFreq_txt, 'Visible', map_list('gratFreq'));
        set(figUIobj.gratFreq_txt2, 'Visible', map_list('gratFreq'));
        
        set(figUIobj.loomSpd, 'Visible', map_list('loomSpd'));
        set(figUIobj.loomSpd_txt, 'Visible', map_list('loomSpd'));
        set(figUIobj.loomSpd_txt2, 'Visible', map_list('loomSpd'));
        
        set(figUIobj.loomSize, 'Visible', map_list('loomSize'));
        set(figUIobj.loomSize_txt, 'Visible', map_list('loomSize'));
        set(figUIobj.loomSize_txt2, 'Visible', map_list('loomSize'));
        
        set(figUIobj.ImageNum, 'Visible', map_list('ImageNum'));
        set(figUIobj.ImageNum_txt, 'Visible', map_list('ImageNum'));
        
        set(figUIobj.dots_density, 'Visible', map_list('dots_density'));
        set(figUIobj.dots_density_txt, 'Visible', map_list('dots_density'));
        set(figUIobj.dots_density_txt2, 'Visible', map_list('dots_density'));
        
        set(figUIobj.rect, 'BackGroundColor', map_list('rect'));
        
        set(figUIobj.get_fine_pos, 'Visible', map_list('getPos'));
        
        set(figUIobj.s2_panel, 'Visible', map_list('panel2'));
        %%%%
    end

%% EOF
end
