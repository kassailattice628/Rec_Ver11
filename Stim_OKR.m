function  Stim_OKR
% Simple drifting sin grating
addpath('ComFunc')

global sobj
global fig

%% initilization params %%
% monitor dependent prameter (DeLL 19-inch)
pixpitch = 0.264;%(mm)
[sobj, GUI_x, GUI_y] = sobj_ini(pixpitch);

%% open PTB window %%
[sobj.wPtr, sobj.RECT] = PsychImaging('OpenWindow', sobj.ScrNum, sobj.gray);

[sobj.ScrCenterX, sobj.ScrCenterY] = RectCenter(sobj.RECT);
sobj.m_int = Screen('GetFlipInterval', sobj.wPtr);
sobj.frameRate = Screen('FrameRate', sobj.ScrNum);

% duration params, in second
sobj.duration = sobj.flipNum * sobj.m_int;
sobj.delay = sobj.flipNum_delay * sobj.m_int;
sobj.iti = sobj.flipNum_iti * sobj.m_int;


%% GUI controlar %%
if sobj.Num_screens == 1
    Screen('Close', sobj.wPtr);
end

fig =  gui_window(GUI_x, GUI_y, sobj);

Reload_sobj
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sobj, GUI_Disp_x, GUI_Disp_y] = sobj_ini(pixpitch)
sobj.cycleNum = 0;

sobj.pixpitch = pixpitch;
MP = get(0, 'MonitorPosition');
sobj.screens = Screen('Screens');

sobj.Num_screens = size(MP, 1);
%stim-presentation monitor
sobj.ScrNum = max(sobj.screens);
%sobj.ScrNum = size(MP,1);

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
%for macOSX
% sobj.screens return [0,1], when 2 displays are used.

%for Windows7
% sobj.screens return [0,1,2], when 2 displays are used.
% 0 is used as double window stimulus
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%

%set horizontal coordination GUI Controler
if sobj.Num_screens == 2 && sobj.ScrNum == sobj.screens(end-1)
    % stim in the 1st monitor
    % ctr in the 2nd monitor
    GUI_Disp_x = MP(2,1);
    GUI_Disp_y = MP(2,2);
elseif sobj.Num_screens == 2 && sobj.ScrNum == sobj.screens(end)
    % stim in the 2nd monitor
    % ctr in the 1st monitor
    GUI_Disp_x = MP(1,1);
    GUI_Disp_y = MP(1,2);
    
end 

%%
sobj.MonitorDist = 500;

sobj.flipNum = 225;
sobj.flipNum_delay = 30;
sobj.flipNum_iti = 150;


sobj.black = BlackIndex(sobj.ScrNum);
sobj.white = WhiteIndex(sobj.ScrNum);
sobj.gray =round((sobj.white + sobj.black)/2);

sobj.stimlumi = sobj.white;
sobj.bgcol = sobj.black;

if sobj.gray == sobj.stimlumi
    sobj.gray = sobj.white/2;
end

sobj.stimRGB = [1,1,1];
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

% grating params
sobj.shiftSpd = 2; %[Hz]
sobj.shiftSpd_list = [0.5; 1; 2; 4; 8];

sobj.gratFreq = 0.16; %cycle/deg
sobj.gratFreq_list = [0.01; 0.02; 0.04; 0.08; 0.16; 0.32];

sobj.shiftDir = 1;

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = gui_window(GUI_x, GUI_y, sobj)

fig.fig = figure('Position', [GUI_x + 30, GUI_y + 200, 410, 400],...
    'Name', 'Stim_OKR', 'DeleteFcn', @close_fig);

% start
fig.start = uicontrol('Style', 'togglebutton', 'Position' , [5, 355, 100 40],...
    'String', 'Start', 'Callback', @Start_stim, 'BackGroundColor', 'g');

%%%
fig.panel1 = uipanel('Fontsize', 12, 'Units', 'Pixels', 'Position', [5, 5, 200, 340]);

%%% Duration
fig.flipNum_txt = uicontrol('Parent', fig.panel1, 'Style', 'text', 'String', 'Druation',...
    'Position', [5 320 90 15], 'Horizontalalignment', 'left');
fig.flipNum = uicontrol('Parent', fig.panel1, 'Style', 'edit', 'Position', [5 300 90 20],...
    'String', sobj.flipNum, 'Callback', @Reload_sobj);
fig.duration = uicontrol('Parent', fig.panel1, 'Style', 'text', 'Position', [95 300 90 15],...
    'String', ['flips = ' num2str(floor(sobj.duration*1000)),' ms'], 'Horizontalalignment', 'left');

%%% Dealy
uicontrol('Parent', fig.panel1, 'Style', 'text', 'String', 'Delay',...
    'Position', [5 275 90 15], 'Horizontalalignment', 'left');
fig.flipNum_delay = uicontrol('Parent', fig.panel1, 'Style', 'edit',...
    'Position', [5 255 90 20], 'String', sobj.flipNum_delay, 'Callback', @Reload_sobj);
fig.duration_delay = uicontrol('Parent', fig.panel1, 'Style', 'text', 'Position', [95 255 90 15],...
    'String', ['flips = ', num2str(floor(sobj.delay*1000)),' ms'], 'Horizontalalignment', 'left');

%%% Interval
uicontrol('Parent', fig.panel1, 'Style', 'text', 'String', 'Inter-trial-Interval',...
    'Position', [5 230 120 15], 'Horizontalalignment', 'left');
fig.flipNum_iti = uicontrol('Parent', fig.panel1, 'Style', 'edit',...
    'Position', [5 210 90 20], 'String', sobj.flipNum_iti, 'Callback', @Reload_sobj);
fig.duration_iti = uicontrol('Parent', fig.panel1, 'Style', 'text', 'Position', [95 210 90 15],...
    'String', ['flips = ', num2str(floor(sobj.iti*1000)),' ms'], 'Horizontalalignment', 'left');

%%% Monitor Dist
uicontrol('Parent', fig.panel1, 'Style', 'text', 'String', 'Monitor Distance',...
    'Position', [5 35 100 15], 'Horizontalalignment', 'left');
fig.MonitorDist = uicontrol('Parent', fig.panel1, 'Style', 'edit',...
    'Position', [5 15 90 20], 'String', sobj.MonitorDist, 'Callback', @Reload_sobj);
uicontrol('Parent', fig.panel1, 'Style', 'text', 'String', 'mm',...
    'Position', [95 10 90 15], 'Horizontalalignment', 'left');


%%%
fig.panel2 = uipanel('Fontsize', 12, 'Units', 'Pixels', 'Position', [205, 5, 200, 340]);

%%% Direction for grating stimulis or concentirc positions
fig.shiftDir_txt = uicontrol('Parent', fig.panel2, 'Style', 'text', 'Position',...
    [5 320 140 15], 'String', 'Direction (0 => right)', 'Horizontalalignment', 'left');
fig.shiftDir = uicontrol('Parent', fig.panel2, 'Style', 'popupmenu', 'Position', [5 295 90 25],...
    'String', [{'0'}, {'45'}, {'90'}, {'135'}, {'180'}, {'225'}, {'270'}, {'315'}, {'Ord8'}, {'Rand8'}, {'Rand16'}],...
    'Callback', @Reload_sobj);
fig.shiftDir_txt2 = uicontrol('Parent', fig.panel2, 'Style', 'text', 'String', 'deg',...
    'Position', [100 300 25 15], 'Horizontalalignment', 'left');

%%% Temporal Frequecy for grating stimuli
fig.shiftSpd_txt = uicontrol('Parent', fig.panel2, 'Style', 'text', 'String', 'Temporal Freq',...
    'Position', [5 275 100 15], 'Horizontalalignment', 'left');
fig.shiftSpd = uicontrol('Parent', fig.panel2, 'Style', 'popupmenu', 'Position', [5 250 70 25],...
    'String', [{'0.5'}, {'1'}, {'2'}, {'4'}, {'8'}], 'value',3, 'BackGroundColor', 'w',...
    'callback', @Reload_sobj);
fig.shiftSpd_txt2 = uicontrol('Parent', fig.panel2, 'Style', 'text', 'String', 'Hz',...
    'Position', [80 255 20 15], 'Horizontalalignment', 'left');

%%% Spatial Frequency for grating stimuli
fig.gratFreq_txt = uicontrol('Parent', fig.panel2, 'Style', 'text', 'String', 'Spatial Freq',...
    'Position', [5 230 100 15], 'Horizontalalignment', 'left');
fig.gratFreq = uicontrol('Parent', fig.panel2, 'Style', 'popupmenu', 'Position', [5 205 100 25],...
    'String', [{'0.01'}, {'0.02'}, {'0.04'}, {'0.08'}, {'0.16'}, {'0.32'}], 'value',5,...
    'Callback', @ Reload_sobj, 'BackGroundColor', 'w');
fig.gratFreq_txt2 = uicontrol('Parent', fig.panel2, 'Style', 'text', 'String',...
    'cycle/deg', 'Position', [105 210 60 15], 'Horizontalalignment', 'left');

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Reload_sobj(~, ~)
%update sobj params, and renew GUI infos
global fig
global sobj

sobj.flipNum = str2double(get(fig.flipNum, 'String'));
sobj.duration = sobj.flipNum * sobj.m_int;
set(fig.duration, 'String', ['flips = ' num2str(floor(sobj.duration*1000)),' ms']);

sobj.flipNum_delay = str2double(get(fig.flipNum_delay, 'String'));
sobj.delay = sobj.flipNum_delay * sobj.m_int;
set(fig.duration_delay, 'String', ['flips = ' num2str(floor(sobj.delay*1000)),' ms']);

sobj.flipNum_iti = str2double(get(fig.flipNum_iti, 'String'));
sobj.iti = sobj.flipNum_iti * sobj.m_int;
set(fig.duration_iti, 'String', ['flips = ' num2str(floor(sobj.iti*1000)),' ms']);

sobj.MonitorDist = str2double(get(fig.MonitorDist, 'String'));

%gratings
sobj.shiftDir = get(fig.shiftDir, 'Value');

i = get(fig.shiftSpd, 'Value');
sobj.shiftSpd = sobj.shiftSpd_list(i);

i = get(fig.gratFreq, 'Value');
sobj.gratFreq = sobj.gratFreq_list(i);

switch sobj.shiftDir
    case {1, 2, 3, 4, 5, 6, 7, 8}
        sobj.grating_angle_deg_list = linspace(0, 315, 8);
    case {9, 10}
        sobj.grating_angle_deg_list = 0: 360/8: 360-360/8;
    case 11
        sobj.grating_angle_deg_list = 0: 360/16: 360-360/16;
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, index] = get_condition(n, list_mat, cycleNum, list_size, flag_random, fix)
persistent list_order

if flag_random == 3
    %fixed condition
    index = [];
    out = fix;
else
    if isempty(list_order) && cycleNum ==  1 && n == 1
        list_order = cell(6,1);
    end
    i_in_cycle = mod(cycleNum, list_size);
    
    if i_in_cycle == 0
        i_in_cycle = list_size;
    elseif i_in_cycle == 1
        switch flag_random
            case 1
                list_order{n,1} = randperm(list_size);
            case 2
                list_order{n,1} = 1:list_size;
        end
    end
    index = list_order{n,1}(i_in_cycle);
    out = list_mat(index,:);
end


end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_stim(hObj, ~)
global sobj

switch get(hObj, 'Value')
    case 0
        set(hObj, 'String', 'Start', 'Backgroundcolor', 'g')
        sobj.cycleNum = 0;
    case 1
        set(hObj, 'String', 'Stop', 'Backgroundcolor', 'r')
end

while get(hObj, 'Value')
    sobj.cycleNum = sobj.cycleNum + 1;
    disp(sobj.cycleNum);
    
    GratingGLSL(2);
    
    pause(sobj.iti)
end

%% subfunctions
    function GratingGLSL(ver)
        
        angle_list = sobj.grating_angle_deg_list';
        if sobj.shiftDir < 9
            flag_rand_dir = 3;
            angle_list = sobj.grating_angle_deg_list(sobj.shiftDir);
        elseif sobj.shiftDir == 9
            flag_rand_dir = 2;
        else
            flag_rand_dir = 1;
        end
        
        [sobj.angle, sobj.angle_index] = get_condition(1, angle_list, sobj.cycleNum,...
            length(angle_list), flag_rand_dir, angle_list);
        
        % spatial freq
        deg_per_cycle = 1/sobj.gratFreq;
        pix_per_cycle = Deg2Pix(deg_per_cycle, sobj.MonitorDist, sobj.pixpitch);
        cycles_per_pix = 1/pix_per_cycle;
        phase = 0;
        contrast = 100;
        
        % Generate grating texture
        angle = 180 - sobj.angle;
        
        if ver == 1
            %contrastPreMultiplicator = 2.55/sobj.white;
            %CreateProceduralSineGrating(windowPtr, width, height [, backgroundColorOffset =(0,0,0,0)] [, radius=inf] [, contrastPreMultiplicator=1])
            %gratingtex = CreateProceduralSineGrating(sobj.wPtr, sobj.RECT(3), sobj.RECT(4), [0,0,0,0.0], [], contrastPreMultiplicator);
            gratingtex = CreateProceduralSineGrating(sobj.wPtr, sobj.RECT(3), sobj.RECT(4), [0,0,0,0.0], [], 0.01);
            
            RECT = [-sobj.RECT(3)/2, -sobj.RECT(4)/2, sobj.RECT(3)*1.5, sobj.RECT(4)*1.5];
            Screen('DrawTexture', sobj.wPtr, gratingtex, [], RECT, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
            
            % prep 1st frame
            [sobj.vbl_1] = Screen('Flip', sobj.wPtr);
            
            for count = 1:sobj.flipNum - 1
                phase = count * 360/sobj.frameRate * sobj.shiftSpd;
                Screen('DrawTexture', sobj.wPtr, gratingtex, [], RECT, angle, [], [], [], [], [], [phase, cycles_per_pix, contrast, 0]);
                if count==1
                    [sobj.vbl_2] = ...
                        Screen('Flip', sobj.wPtr, sobj.vbl_1 + sobj.delay);
                else
                    Screen('Flip', sobj.wPtr);
                end
            end
            
            Screen('FillRect', sobj.wPtr, sobj.gray, [0 0 sobj.RECT(3),sobj.RECT(4)]);
            [sobj.vbl_3] = ...
                Screen('Flip', sobj.wPtr, sobj.vbl_2 + sobj.duration);
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        elseif ver == 2;
            %cyclepersecond : sobj.shiftSpd
            %p [pix/cycle]
            
            %spatial freq
            f = 1/sobj.gratFreq;  %[deg/cycle]
            p = Deg2Pix(f, sobj.MonitorDist, sobj.pixpitch); %[pix/cycle]
            f = 1/p; %cycle/pix
            fr = f*2*pi; % freq in radians???
            %change from sobj.gratFreq[cpd]
            
            fullpix = 2000;
            visiblesize = ceil(fullpix/p)*p; % [pix]
            inc = sobj.white-sobj.gray;
            
            
            %create single static 1D grating image;
            %only need a texture with a single row of pix to define the
            %whole grating!
            x = meshgrid(0:visiblesize-1,1); % made of pixels
            grating = sobj.gray + inc * cos(fr*x);
            
            gratingtex = Screen('MakeTexture', sobj.wPtr, grating, [], 1);
            
            waitframes = 1;
            waitduration = waitframes * sobj.m_int;
            
            %grating speed
            shift_per_frame = sobj.shiftSpd * p * waitduration;
            
            vbl = Screen('Flip', sobj.wPtr);
            
            vbl_end_time = vbl+ sobj.duration;
            xoffset = 0;
            
            %Shifting loop
            while(vbl < vbl_end_time)
                xoffset = xoffset + shift_per_frame;
                
                srcRect = [xoffset 0 xoffset + visiblesize visiblesize];
                Screen('DrawTexture', sobj.wPtr, gratingtex, srcRect, [], angle);
                %Screen('DrawTexture', sobj.wPtr, gratingtex, [], srcRect, angle, [], [], [], [], kPsychDontDoRotation, [0, cycles_per_pix, 300 * 0.16, 100, 1, 0, 0, 0]);
                vbl=Screen('Flip', sobj.wPtr, vbl+(waitframes-0.5)*sobj.m_int);
            end
            
            Screen('FillRect', sobj.wPtr, sobj.gray, [0 0 sobj.RECT(3),sobj.RECT(4)]);
            Screen('Flip', sobj.wPtr);
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function close_fig(~, ~)
% close PTB, scleen close all
sca

end
