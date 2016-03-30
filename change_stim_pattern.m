function change_stim_pattern(hObject, ~)

global sobj
global figUIobj
defcol = [0.9400 0.9400 0.9400];

pattern_list = get(hObject,'string');
sobj.pattern = pattern_list{get(hObject,'value'),1};

switch sobj.pattern
    case 'Uni'
        set(figUIobj.mode, 'value', 1); % position random
        set(figUIobj.fixpos,'BackGroundColor','w');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','k');
        set(figUIobj.dist,'BackGroundColor','k');
        
        set(figUIobj.shiftDir,'BackGroundColor','k');
        set(figUIobj.shiftSpd,'BackGroundColor','k');
        set(figUIobj.gratFreq,'BackGroundColor','k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
        
    case 'Size_rand'
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','k');
        set(figUIobj.dist,'BackGroundColor','k');
        
        set(figUIobj.shiftDir,'BackGroundColor','k');
        set(figUIobj.shiftSpd,'BackGroundColor','k');
        set(figUIobj.gratFreq,'BackGroundColor','k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
             
    case '1P_Conc'
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','g');
        set(figUIobj.dist,'BackGroundColor','g');
        
        set(figUIobj.shiftDir,'BackGroundColor', defcol);
        set(figUIobj.shiftSpd,'BackGroundColor', 'k');
        set(figUIobj.gratFreq,'BackGroundColor', 'k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
        
    case '2P_Conc'
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','g');
        set(figUIobj.dist,'BackGroundColor','g');
        
        set(figUIobj.shiftDir,'BackGroundColor', defcol);
        set(figUIobj.shiftSpd,'BackGroundColor', 'k');
        set(figUIobj.gratFreq,'BackGroundColor', 'k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','w');
        set(figUIobj.stimlumi2,'BackGroundColor','w');
        set(figUIobj.flipNum2,'BackGroundColor','w');
        set(figUIobj.delayPTBflip2,'BackGroundColor','w');
        set(figUIobj.size2,'BackGroundColor','w');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
        
    case 'B/W'
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','g');
        set(figUIobj.dist,'BackGroundColor','g');
        
        set(figUIobj.shiftDir,'BackGroundColor', defcol);
        set(figUIobj.shiftSpd,'BackGroundColor', 'k');
        set(figUIobj.gratFreq,'BackGroundColor', 'k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
        
    case 'Looming'
        check_looming;
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        set(figUIobj.shape, 'value', 2); % circular
        
        set(figUIobj.div_zoom,'BackGroundColor','k');
        set(figUIobj.dist,'BackGroundColor','k');
        
        set(figUIobj.shiftDir,'BackGroundColor', 'k');
        set(figUIobj.shiftSpd,'BackGroundColor', 'k');
        set(figUIobj.gratFreq,'BackGroundColor', 'k');
        
        set(figUIobj.loomSpd,'BackGroundColor','w');
        set(figUIobj.loomSize,'BackGroundColor','w');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'y');
        
    case {'Sin', 'Rect', 'Gabor'}
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        
        set(figUIobj.div_zoom,'BackGroundColor','k');
        set(figUIobj.dist,'BackGroundColor','k');
        
        set(figUIobj.shiftDir,'BackGroundColor', defcol);
        set(figUIobj.shiftSpd,'BackGroundColor', defcol);
        set(figUIobj.gratFreq,'BackGroundColor', defcol);
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','k');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
        
    case 'Images'
        set(figUIobj.mode, 'value', 2); % position fix
        set(figUIobj.fixpos,'BackGroundColor','g');
        
        set(figUIobj.div_zoom,'BackGroundColor','k');
        set(figUIobj.dist,'BackGroundColor','k');
        
        set(figUIobj.shiftDir,'BackGroundColor', 'k');
        set(figUIobj.shiftSpd,'BackGroundColor', 'k');
        set(figUIobj.gratFreq,'BackGroundColor', 'k');
        
        set(figUIobj.loomSpd,'BackGroundColor','k');
        set(figUIobj.loomSize,'BackGroundColor','k');
        
        set(figUIobj.ImageNum,'BackGroundColor','w');
        
        set(figUIobj.shape2,'BackGroundColor','k');
        set(figUIobj.stimlumi2,'BackGroundColor','k');
        set(figUIobj.flipNum2,'BackGroundColor','k');
        set(figUIobj.delayPTBflip2,'BackGroundColor','k');
        set(figUIobj.size2,'BackGroundColor','k');
        
        set(figUIobj.rect, 'BackgroundColor', 'g');
end
