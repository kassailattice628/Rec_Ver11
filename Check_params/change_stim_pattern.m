function change_stim_pattern(~, ~)
global figUIobj
global sobj

defcol = [0.9400 0.9400 0.9400];
pattern_list = get(figUIobj.pattern,'string');
sobj.pattern = pattern_list{get(figUIobj.pattern,'value'),1};

key ={'fixpos', 'div_zoom', 'dist_deg', 'shiftDir', 'shiftSpd',...
    'gratFreq', 'loomSpd', 'loomSize', 'ImageNum', 'dots_density',...
    'shape2','stimlumi2', 'flipNum2', 'delayPTBflip2', 'size2', 'rect'};

switch sobj.pattern
    case 'Uni'
        val = {'w', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 1); % position random
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'FineMap'
        val = {'g', 'g', 'g', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position random
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'Size_rand'
        val = {'g', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case '1P_Conc'
        val = {'g', 'g', 'g', defcol, 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case '2P_Conc'
        val = {'g', 'g', 'g', defcol, 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'w', 'w', 'w', 'w', 'w', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'B/W'
        val = {'g', 'g', 'g', defcol, 'k',...
            'k', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case 'Looming'
        val = {'g', 'k', 'k', 'k', 'k',...
            'k', 'w', 'g', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'y'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 2); % circular
        
    case {'Sin', 'Rect', 'Gabor'}
        val = {'g', 'k', 'k', defcol, defcol,...
            defcol, 'w', 'w', 'k', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        
    case 'Images'
        val = {'g', 'k', 'k', 'k', 'k',...
            'k', 'k', 'k', 'g', 'k',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        
    case 'Mosaic'
        val = {'g', 'g', 'g', 'k', 'k',...
            'k', 'k', 'k', 'k', 'g',...
            'k', 'k', 'k', 'k', 'k', 'g'};
        map_list = containers.Map(key, val);
        
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.shape, 'value', 1); % rectangle
end

set_fig_stim_color(map_list)

%%
    function set_fig_stim_color(map_list)
        
        set(figUIobj.mode, 'value', 2); % position fix
        
        set(figUIobj.fixpos, 'BackGroundColor', map_list('fixpos'));
        
        set(figUIobj.div_zoom, 'BackGroundColor', map_list('div_zoom'));
        set(figUIobj.dist, 'BackGroundColor',map_list('dist_deg'));
        
        set(figUIobj.shiftDir, 'BackGroundColor', map_list('shiftDir'));
        set(figUIobj.shiftSpd, 'BackGroundColor', map_list('shiftSpd'));
        set(figUIobj.gratFreq, 'BackGroundColor', map_list('gratFreq'));
        
        set(figUIobj.loomSpd, 'BackGroundColor', map_list('loomSpd'));
        set(figUIobj.loomSize, 'BackGroundColor', map_list('loomSize'));
        
        set(figUIobj.ImageNum, 'BackGroundColor', map_list('ImageNum'));
        set(figUIobj.dots_density, 'BackGroundColor', map_list('dots_density'));
        
        set(figUIobj.shape2, 'BackGroundColor', map_list('shape2'));
        set(figUIobj.stimlumi2, 'BackGroundColor', map_list('stimlumi2'));
        set(figUIobj.flipNum2, 'BackGroundColor', map_list('flipNum2'));
        set(figUIobj.delayPTBflip2, 'BackGroundColor', map_list('delayPTBflip2'));
        set(figUIobj.size2, 'BackGroundColor', map_list('size2'));
        
        set(figUIobj.rect, 'BackgroundColor', map_list('rect'));
    end

end