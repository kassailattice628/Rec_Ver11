function change_stim_pattern2(~, ~)
global figUIobj
global sobj

%defcol = [0.9400 0.9400 0.9400];
pattern_list = get(figUIobj.pattern,'string');
sobj.pattern = pattern_list{get(figUIobj.pattern,'value'),1};


key ={'div_zoom', 'dist_deg', 'shiftDir', 'shiftSpd', 'gratFreq',...
    'loomSpd', 'loomSize', 'ImageNum', 'dots_density',...
    'panel2',...
    'rect'};

switch sobj.pattern
    case 'Uni'
        val = {'on', 'on', 'on', 'off', 'off'...
            'off', 'off', 'off', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 1); % position rand_mat
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom_txt, 'Position', [10 135 45 15]);
        set(figUIobj.div_zoom, 'Position', [10 110 40 25]);
        
        set(figUIobj.dist_txt, 'Position', [60 135 45 15]);
        set(figUIobj.dist, 'Position', [60 110 40 25]);
        
    case 'Size_rand'
        val = {'on', 'on', 'on', 'off', 'off'...
            'off', 'off', 'off', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case '2P'
        val = {'on', 'on', 'on', 'off', 'off'...
            'off', 'off', 'off', 'off',...
            'on',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'B/W'
        val = {'on', 'on', 'on', 'off', 'off'...
            'off', 'off', 'off', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'Looming'
        change_looming_params([],[]);
        val = {'off', 'off', 'off', 'off', 'off',...
            'on', 'on', 'off', 'off',...
            'off',...
            'y'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case {'Sin', 'Rect', 'Gabor', 'MoveBar'}
        val = {'off', 'off', 'on', 'on', 'on',...
            'off', 'off', 'off', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'Images'
        val = {'off', 'off', 'off', 'off', 'off',...
            'off', 'off', 'on', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        
    case 'Mosaic'
        val = {'on', 'on', 'off', 'off', 'off',...
            'off', 'off', 'off', 'on',...
            'off',... 
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 4); % position fix
        set(figUIobj.shape, 'value', 1); % rectangle
        
    case 'FineMap'
        val = {'on', 'on', 'off', 'off', 'off',...
            'off', 'off', 'off', 'off',...
            'off',...
            'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 1); % position rand_mat
        set(figUIobj.shape, 'value', 2); % circular
end

set_fig_stim_color(map_list)

%%
    function set_fig_stim_color(map_list)
        set(figUIobj.div_zoom, 'Visible', map_list('div_zoom'));
        set(figUIobj.div_zoom_txt, 'Visible', map_list('div_zoom'));
        
        set(figUIobj.dist, 'Visible',map_list('dist_deg'));
        set(figUIobj.dist_txt, 'Visible',map_list('dist_deg'));
        
        set(figUIobj.shiftDir, 'Visible', map_list('shiftDir'));
        set(figUIobj.shiftDir_txt, 'Visible', map_list('shiftDir'));
        set(figUIobj.shiftDir_txt2, 'Visible', map_list('shiftDir'));
        
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
        
        set(figUIobj.s2_panel, 'Visible', map_list('panel2'));
    end

end