function change_stim_mode(hObject, ~)
global figUIobj
global sobj

pattern_list = get(figUIobj.pattern,'string');
sobj.pattern = pattern_list{get(figUIobj.pattern,'Value'),1};

key = {'div', 'dist', 'dir',...
    'shiftSpd', 'gratFreq',...
    'loomSpd', 'loomSize', 'ImageNum', 'dots_density',...
    'panel2', 'getPos', ...
    'rect'};

%%
switch get(hObject, 'Value')
    case {1, 2}
        %RandMat, OrdMat
        switch sobj.pattern
            case {'Uni', 'Size_rand'}
                %div, dist, dir: OFF
                val = {'off', 'off', 'off', 'off', 'off',...
                    'off', 'off','off','off', 'off', 'off', 'g'};
            case {'Looming'}
                 val = {'off', 'off', 'off', 'off', 'off',...
                    'on', 'on', 'off', 'off', 'off', 'off', 'g'};
            case {'Images'}
                 val = {'off', 'off', 'off', 'off', 'off',...
                    'off', 'off', 'on', 'off', 'off', 'off', 'g'};
            case {'2P'}
                %div, dist, dir: ON
                val = {'on', 'on', 'on', 'off', 'off',...
                    'off', 'off', 'off', 'off', 'on', 'off', 'g'};
            case {'B/W'}
                val = {'on', 'on', 'on', 'off', 'off',...
                    'off', 'off', 'off', 'off', 'off', 'off', 'g'};
            case {'Sin', 'Rect', 'Gabor'}
                %div, dist: OFF, dir: ON
                val = {'off', 'off', 'on', 'on', 'on',...
                    'off', 'off', 'off', 'off', 'off', 'off', 'g'};
            %case {'Movebar'}
                %don't use
            case 'Mosaic'
                %div, dist: ON, dir: OFF
                val = {'on', 'on', 'off', 'off', 'off',...
                    'off', 'off','off','on', 'off', 'off', 'g'};
            case 'FineMap'
                %div, dist: ON, dir: OFF
                val = {'on', 'on', 'off', 'off', 'off',...
                    'off', 'off','off','off', 'off', 'on', 'g'};
        end
        %%
    case 3
        %Concentric position
        switch sobj.pattern
            case {'Uni', 'Size_rand'}
                %div, dist, dir ON
                val = {'on', 'on', 'on', 'off', 'off',...
                    'off', 'off','off','off', 'off', 'off', 'g'};
            case {'Looming'}
                 val = {'on', 'on', 'on', 'off', 'off',...
                    'on', 'on', 'off', 'off', 'off', 'off', 'g'};
            case {'Images'}
                 val = {'on', 'on', 'on', 'off', 'off',...
                    'off', 'off', 'on', 'off', 'off', 'off', 'g'};
        end
        
        
    case 4
        %Fixed position
        switch sobj.pattern
            case {'2P', 'B/W', 'Mosaic', 'FineMap'}
            case {}
        end
end

%%
map_list = containers.Map(key, val);
set_fig_stim_color(map_list);

%%
if get(hObject, 'Value') == 4
    set(figUIobj.fixpos, 'BackGroundColor', 'g');
    
    switch sobj.pattern
        case {'2P', 'B/W', 'Mosaic', 'FineMap'}
            set(figUIobj.div_zoom_txt, 'Visible', 'on');
            set(figUIobj.div_zoom, 'Visible', 'on');
            set(figUIobj.dist_txt, 'Visible', 'on');
            set(figUIobj.dist, 'Visible', 'on');
        otherwise
            set(figUIobj.div_zoom_txt, 'Visible', 'off');
            set(figUIobj.div_zoom, 'Visible', 'off');
            set(figUIobj.dist_txt, 'Visible', 'off');
            set(figUIobj.dist, 'Visible', 'off');
    end
    
elseif get(hObject, 'Value') == 3
    set(figUIobj.fixpos, 'BackGroundColor', 'y');
    
    set(figUIobj.div_zoom_txt, 'Visible', 'on');
    set(figUIobj.div_zoom, 'Visible', 'on');
    set(figUIobj.dist_txt, 'Visible', 'on');
    set(figUIobj.dist, 'Visible', 'on');
    
    switch sobj.pattern
        case {'Uni', 'Size_rand', 'Images', 'Mosaic'}
            set(figUIobj.div_zoom_txt, 'Position', [10 135 45 15]);
            set(figUIobj.div_zoom, 'Position', [10 110 40 25]);
            set(figUIobj.dist_txt, 'Position', [60 135 45 15]);
            set(figUIobj.dist, 'Position', [60 110 40 25]);
            
        case {'Looming'}
            set(figUIobj.div_zoom_txt, 'Position', [10 180 45 15]);
            set(figUIobj.div_zoom, 'Position', [10 155 40 25]);
            set(figUIobj.dist_txt, 'Position', [60 180 45 15]);
            set(figUIobj.dist, 'Position', [60 155 40 25]);
            
        case {'Sin', 'Rect', 'Gabor'}
            set(figUIobj.div_zoom_txt, 'Position', [150 230 45 15]);
            set(figUIobj.div_zoom, 'Position', [150 205 40 25]);
            set(figUIobj.dist_txt, 'Position', [150 185 45 15]);
            set(figUIobj.dist, 'Position', [150 160 40 25]);
            
        otherwise
            % When 'Moovebar' is selected
            set(figUIobj.div_zoom_txt, 'Visible', 'off');
            set(figUIobj.div_zoom, 'Visible', 'off');
            set(figUIobj.dist_txt, 'Visible', 'off');
            set(figUIobj.dist, 'Visible', 'off');
            
    end
    
else % mode == 1, 2
    switch sobj.pattern
        case {'FineMap'}
            set(figUIobj.fixpos, 'BackGroundColor', 'g');
        otherwise
            set(figUIobj.fixpos, 'BackGroundColor', 'w');
    end
    
    set(figUIobj.div_zoom_txt, 'Visible', 'off');
    set(figUIobj.div_zoom, 'Visible', 'off');
    set(figUIobj.dist_txt, 'Visible', 'off');
    set(figUIobj.dist, 'Visible', 'off');
end




%%
    function set_fig_stim_color(map_list)
        set(figUIobj.div_zoom, 'Visible', map_list('div_zoom'));
        set(figUIobj.div_zoom_txt, 'Visible', map_list('div_zoom'));
        
        set(figUIobj.dist, 'Visible',map_list('dist_deg'));
        set(figUIobj.dist_txt, 'Visible',map_list('dist_deg'));

        set(figUIobj.shiftDir, 'Visible', map_list('shiftDir'));
        set(figUIobj.shiftDir_txt, 'Visible', map_list('shiftDir'));
        set(figUIobj.shiftDir_txt2, 'Visible', map_list('shiftDir'));
        
        %%%%
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

%% % eof %%%
end