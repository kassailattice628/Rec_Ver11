function change_stim_pattern2(~, ~)
global figUIobj
global sobj

%defcol = [0.9400 0.9400 0.9400];
pattern_list = get(figUIobj.pattern,'string');
sobj.pattern = pattern_list{get(figUIobj.pattern,'Value'),1};

%%
switch sobj.pattern
    case 'Uni'
        set(figUIobj.mode, 'Value', 1); % position rand_mat
        set(figUIobj.shape, 'Value', 2); % circular
    
    case 'Size_rand'
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular

    case '2P'  
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular
        
    case 'B/W'
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular
        
    case 'Looming'
        change_moving_params([],[]);
        
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular
        set(figUIobj.loomSpd_txt, 'String', 'Loom Spd/Size')
        
    case {'Sin', 'Rect', 'Gabor'}
        
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular
        
    case 'MoveBar'
        change_moving_params([],[]);
        
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 2); % circular
        set(figUIobj.loomSpd_txt, 'String', 'Move Spd');
        
    case 'Images'        
        set(figUIobj.mode, 'Value', 4); % position fix
        
    case 'Mosaic'
        set(figUIobj.mode, 'Value', 4); % position fix
        set(figUIobj.shape, 'Value', 1); % rectangle
        
    case 'FineMap'
        set(figUIobj.mode, 'Value', 1); % position rand_mat
        set(figUIobj.shape, 'Value', 2); % circular
end
%%

change_stim_mode2([],[]);


%% EOF
end