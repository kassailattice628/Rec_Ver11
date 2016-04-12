function h = open_get_fine_pos(figUIobj)
%open window to get fin position in 1P_Conc
global sobj
%% %---------- Create plot window ----------%

grid_size = 200;
str = [num2str(grid_size),' x ',num2str(grid_size),' mat<='];

%open window
h.fig = figure('Position',[50, 770, 250, 100], 'Name','Get Fine Pos', 'NumberTitle', 'off', 'Menubar','none', 'Resize', 'off');
set(h.fig, 'DeleteFcn', {@close_Plot, figUIobj});

uicontrol('style', 'text', 'string', 'Division', 'position', [5 80 60 20], 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);
uicontrol('style', 'text', 'string', sobj.div_zoom, 'position', [5 65 60 15], 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);
uicontrol('style','text','string','Dist','position',[70 80 70 20], 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);
uicontrol('style','text','string', [num2str(sobj.dist), ' deg'],'position',[70 65 70 15], 'FontSize', 13,'BackGroundColor', [0.9400 0.9400 0.9400]);


%set fine position
uicontrol('style', 'text', 'string','Select Pos','position',[150 85 80 15], 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);
h.select_pos = uicontrol('style', 'edit', 'string', 1, 'position', [150 65 80 20], ...
    'callback', {@check_select_pos, sobj.pattern}, 'FontSize', 13, 'BackGroundColor', 'w');

%
uicontrol('style', 'text', 'string', str, 'position', [5 40 130 15], 'FontSize', 13, 'BackGroundColor', [0.9 0.9 0.9]);
h.trans_pos = uicontrol('style','text','string', 'unset', 'position', [150 40 80 15], 'FontSize', 13,'BackGroundColor', [0.9400 0.9400 0.9400]);



h.get_gelect_pos = uicontrol('style', 'togglebutton', 'string', 'Get', 'position', [150 5 80 30], ...
    'callback', {@get_select_pos, grid_size, h}, 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);


h.set_select_pos = uicontrol('style', 'pushbutton', 'string', 'Set', 'position', [20 5 80 30], ...
    'callback', {@set_select_pos, grid_size, h, figUIobj}, 'FontSize', 13, 'BackGroundColor', [0.9400 0.9400 0.9400]);


end

%%
function close_Plot(~, ~, figUIobj)
global getfineUIobj
getfineUIobj = rmfield(getfineUIobj,'fig');
if isstruct(figUIobj)
    set(figUIobj.get_fine_pos, 'value', 0, 'BackGroundColor', [0.9400 0.9400 0.9400]);
    set(figUIobj.divnum,'BackGroundColor', 'w');
    set(figUIobj.mode, 'value', 1);
    set(figUIobj.fixpos,'BackGroundColor', 'g');
end
end

%%
function check_select_pos(hObject, ~, pattern)
global sobj
switch pattern
    case '1P_Conc'
        if str2double(get(hObject,'string')) > sobj.div_zoom * sobj.dist * 8 + 1
            errordlg('Invalid position is selected');
            set(hObject, 'string', 1);
        end
    case 'FineMap'
        if str2double(get(hObject,'string')) > sobj.div_zoom^2
            errordlg('Invalid position is selected');
            set(hObject, 'string', 1);
        end
end
end

%%
function get_select_pos(hObject, ~, grid_size, h)

if get(hObject, 'value') == 0
    set(hObject, 'BackGroundColor', [0.9400 0.9400 0.9400]);
else
    set(hObject, 'BackGroundColor', 'y');

    % get position in 100x100 matrix
    index = find_gird_mat(grid_size, h);
    
    set(h.trans_pos, 'string', num2str(index), 'BackGroundColor','y');
end
end

%%
function index = find_gird_mat(grid_size, h)
global sobj

stepX = sobj.RECT(3)/grid_size;
stepY = sobj.RECT(4)/grid_size;

center_div = floor([stepX/2:stepX:(sobj.RECT(3)-stepX/2);...
    stepY/2:stepY:(sobj.RECT(4)-stepY/2)]);

centerXY_list = zeros(grid_size^2,2);
for m = 1:grid_size
    centerXY_list(grid_size*(m-1)+1:grid_size*m,1) = center_div(1,m);
    centerXY_list((1:grid_size:grid_size^2)+(m-1),2) = center_div(2,m);
end

select_pos = str2double(get(h.select_pos, 'string'));

switch sobj.pattern
    case '1P_Conc'
        %%find nearest positin in grid_position
        %center of 1P_Conc: sobj.
        %sobj.concentric_mat:::distance(pixel), anlge(radian), luminace
        %sobj.concentric_mat_deg:::distaince(deg), angle(deg), luminace
        select_pos_pol = sobj.concentric_mat(select_pos, 1:2);
        [select_pos_xy(1), select_pos_xy(2)] = pol2cart(select_pos_pol(2), select_pos_pol(1));
        
        %get_stim_position in Concentric grid (offset center)
        center = sobj.center_pos_list(sobj.fixpos,:);
        conc_X = center(1) + select_pos_xy(1);
        conc_Y = center(2) - select_pos_xy(2); % minus for upward direction
        [~, index_x] = min(abs(centerXY_list(:,1) - conc_X));
        [~, index_y] = min(abs(centerXY_list(:,2) - conc_Y));
        
    case 'FineMap'
        center = sobj.center_pos_list_FineMap(select_pos,:);
        disp(sobj.center_pos_list_FineMap)
        disp(center)
        [~, index_x] = min(abs(centerXY_list(:,1) - center(1)));
        [~, index_y] = min(abs(centerXY_list(:,2) - center(2)));
end

% get the grid number in 100 * 100 matrix
index = intersect(find(centerXY_list(:,1)==centerXY_list(index_x,1)),...
    find(centerXY_list(:,2)==centerXY_list(index_y,2)));

end
%%
function set_select_pos(~, ~, grid_size, h, fh)
if get(h.get_gelect_pos,'value') == 1
    set(fh.divnum,'string', num2str(grid_size));
    set(fh.fixpos,'string', get(h.trans_pos,'string'));
     disp('BBB');
else
    disp('AAA');
end
end