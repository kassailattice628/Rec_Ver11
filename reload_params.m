function reload_params(~, ~, Testmode, Recmode, SetCam)
% reload all paraemter and settings before start loop.

%% call global vars
global sobj
global recobj

global figUIobj
global plotUIobj

global s
global sOut

global dio

global capture
global lh

global DataSave
global ParamsSave

global imaq

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Visual stimulus settings %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% general %
sobj.MonitorDist = re_write(figUIobj.MonitorDist);

sobj.divnum = re_write(figUIobj.divnum);
set(figUIobj.divnumN, 'string', ['(' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)']);

sobj.center_pos_list = get_stim_center_mat(sobj.RECT, sobj.divnum);

sobj.fixpos = re_write(figUIobj.fixpos);
set(figUIobj.fixposN, 'string',['(in' num2str(sobj.divnum) 'x' num2str(sobj.divnum) 'mat)']);

recobj.prestim = re_write(figUIobj.prestimN);
recobj.cycleNum = 0 - recobj.prestim;

modelist = get(figUIobj.mode, 'string'); % {'Random', 'Fix_Rep', 'Ordered'};
sobj.mode = modelist{get(figUIobj.mode, 'Value')};

% sobj.pattern is reloaded in ./Check_params/change_stim_pattern.m

%% stim 1
sobj.div_zoom = re_write(figUIobj.div_zoom);
sobj.dist = re_write(figUIobj.dist);

sobj.bgcol = re_write(figUIobj.bgcol);

sobj.shape = sobj.shapelist{get(figUIobj.shape, 'Value'), 1};

sobj.stimlumi = re_write(figUIobj.stimlumi);
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

sobj.stimlumi_list = linspace(sobj.bgcol, sobj.stimlumi, 5)';

if strcmp(sobj.pattern, 'Looming') || strcmp(sobj.pattern, 'MoveBar')
    %stimu duration is automatically changes in Looming mode
else
    sobj.flipNum = re_write(figUIobj.flipNum);
    sobj.duration = sobj.flipNum*sobj.m_int;
end

sobj.delayPTBflip = re_write(figUIobj.delayPTBflip);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;

sobj.size_pix_list = repmat(round(Deg2Pix(sobj.stimsz_deg_list, sobj.MonitorDist, sobj.pixpitch)), 1, 2);

if get(figUIobj.auto_size, 'Value') == 1
    %set(figUIobj.auto_size, 'Value',0, 'string', 'Auto OFF')
else
    sobj.stimsz = getStimSize(sobj.MonitorDist, figUIobj.size, sobj.pixpitch);
    
end

%% Stim specific parameters.
mode =  get(figUIobj.mode, 'Value');
switch sobj.pattern
    case {'Uni', 'Size_rand', 'Looming'}
        %%
        if mode ==  3
            [sobj.concentric_dist_deg_list, sobj.concentric_angle_deg_list,...
                sobj.concentric_mat, sobj.concentric_mat_deg] = get_concentric_position(1);
        end
        
    case {'2P', 'B/W'}
        %%
        %Position
        [sobj.concentric_dist_deg_list, sobj.concentric_angle_deg_list,...
            sobj.concentric_mat, sobj.concentric_mat_deg] = get_concentric_position(1);
        
        % Set stim size, size(fix)
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
                
        sobj.stim_size2 = sobj.stimsz2;
        sobj.size_deg2 = str2double(get(figUIobj.size2, 'String'));
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Color
        if strcmp(sobj.pattern, 'B/W')
            sobj.bgcol = sobj.gray;
        end
        
    case {'MoveBar'}
        %Move angle
        [~, sobj.concentric_angle_deg_list, ~, ~] = get_concentric_position(1);
        
        sobj.stim_center=[0,0];
        
        % set color / luminance
        sobj.stimcol = sobj.stimlumi;
        
        % set size
        sobj.stim_size = sobj.stimsz;
        sobj.size_deg = str2double(get(figUIobj.size, 'String'));
        
    case {'Sin', 'Rect', 'Gabor'}
        %% Grating 
        %Position
        if mode ==  3
            [sobj.concentric_dist_deg_list, sobj.concentric_angle_deg_list,...
                sobj.concentric_mat, sobj.concentric_mat_deg] = get_concentric_position(2);
        end
        
        %Grating
        sobj.shiftDir = get(figUIobj.shiftDir, 'Value');
        %Angle
        [~, sobj.grating_angle_deg_list, ~, ~] = get_concentric_position(1);
        
        sobj.shiftSpd = sobj.shiftSpd_list(get(figUIobj.shiftSpd, 'Value'));
        sobj.gratFreq = sobj.gratFreq_list(get(figUIobj.gratFreq, 'Value'));
        
        %Gabor on/off
        if strcmp(sobj.pattern, 'Gabor')
            sobj.bgcol = sobj.gray;
        end
        
    case 'Images'
        %% Select Image Set
        
        sobj.img_list = randperm(256);
        sobj.ImageNum = re_write(figUIobj.ImageNum);
        sobj.img_sublist = sobj.img_list(1:sobj.ImageNum)';
        
        %position
        if mode ==  3
            [sobj.concentric_dist_deg_list, sobj.concentric_angle_deg_list,...
                sobj.concentric_mat, sobj.concentric_mat_deg] = get_concentric_position(1);
        end
        
    case 'Mosaic'
        %% Multi dots
        rng('shuffle');
        sobj.int_seed = randperm(1000);
        sobj.stim_size = sobj.stimsz;
        dim = sobj.dist; % deg
        div = sobj.div_zoom; % deg
        div_step = dim/div;
        [x_deg, y_deg] = meshgrid(-(dim-1)/2:div_step:(dim-1)/2,...
            -(dim-1)/2:div_step:(dim-1)/2); % deg
        numAllDots = numel(x_deg);
        sobj.positions_deg = [reshape(x_deg, 1, numAllDots); reshape(y_deg, 1, numAllDots)];
        
        sobj.dots_density = re_write(figUIobj.dots_density);
        sobj.num_dots = round(numAllDots * sobj.dots_density/100);
        
    case 'FineMap'
        %% Get small area for fine mapping
        FineMapArea_deg = [0, 0, sobj.dist, sobj.dist]; % deg
        FineMapArea = Deg2Pix(FineMapArea_deg, sobj.MonitorDist, sobj.pixpitch);
        
        % get center position in pixel
        center = sobj.center_pos_list(sobj.fixpos,:);
        
        % get corner positions in pixel
        RECT = CenterRectOnPointd(FineMapArea, center(1), center(2));
        
        sobj.center_pos_list_FineMap = get_stim_center_mat(RECT, sobj.div_zoom);
        
end

%% stim 2 
sobj.shape2 = sobj.shapelist{get(figUIobj.shape2, 'Value'), 1};
sobj.stimlumi2 = re_write(figUIobj.stimlumi2);
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;

sobj.flipNum2 = re_write(figUIobj.flipNum2);
sobj.duration2 = sobj.flipNum2*sobj.m_int;

sobj.delayPTBflip2 = re_write(figUIobj.delayPTBflip2);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;

sobj.stimsz2 = getStimSize(sobj.MonitorDist,figUIobj.size2, sobj.pixpitch);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% NIDAQ Recording %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

recobj.interval = re_write(figUIobj.interval);
recobj.sampf = re_write(figUIobj.sampf)*1000;
recobj.recp = recobj.sampf*recobj.rect/1000;

if Recmode == 2
    recobj.pulseDuration = re_write(figUIobj.pulseDuration);
    recobj.pulseDelay = re_write(figUIobj.pulseDelay);
    recobj.pulseAmp = re_write(figUIobj.pulseAmp);
    
    recobj.stepCV(1,1) = re_write(figUIobj.Cstart);
    recobj.stepCV(1,2) = re_write(figUIobj.Cend);
    recobj.stepCV(1,3) = re_write(figUIobj.Cstep);
    recobj.stepCV(2,1) = re_write(figUIobj.Vstart);
    recobj.stepCV(2,2) = re_write(figUIobj.Vend);
    recobj.stepCV(2,3) = re_write(figUIobj.Vstep);
    
    plotnum = get(figUIobj.plot, 'Value')+1;
    recobj.stepAmp = recobj.stepCV(plotnum,1):recobj.stepCV(plotnum,3):recobj.stepCV(plotnum,2);
end

%% TTL
recobj.TTL3.duration = re_write(figUIobj.durationTTL3); % ms
recobj.TTL3.delay = re_write(figUIobj.delayTTL3); % ms
recobj.TTL3.Freq = re_write(figUIobj.freqTTL3);
recobj.TTL3.DutyCycle = re_write(figUIobj.dutycycleTTL3);

%% DAQ
if Testmode == 0
    % DAQ sessions are not defined in the TEST-mode
    if s.IsRunning
        s.stop;
        disp('stop s')
    end
    if sOut.IsRunning
        sOut.stop;
        disp('stop sOut')
    end
    s.Rate = recobj.sampf;
    sOut.Rate = recobj.sampf;
    
    %%%%%% data capture settings %%%%%%
    % Specify triggered capture timespan, in seconds
    capture.TimeSpan = recobj.rect/1000;% sec
    
    % Specify continuous data plot timespan
    capture.plotTimeSpan = 2; %sec
    
    % Determine the timespan corresponding to the block of samples supplied
    % to the DataAvailable event callback function.
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    
    % Determine required buffer timespan, seconds
    capture.bufferTimeSpan = max([capture.TimeSpan * 3, callbackTimeSpan * 3]);
    
    % Determine data buffer size
    capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);
    
    delete(lh)% <-- important!!!
    
    DataSave =[]; %reset save data
    ParamsSave =[]; % reset save parameters
    lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj, Recmode, SetCam)); 
    % dio reset
    outputSingleScan(dio.TrigAIFV,[0,0])
    outputSingleScan(dio.VSon,0)
    disp('reset s, dio, EventListener')
    
    %%%%%% session for TTL3 counter pulse generation %%%%%%
    if get(figUIobj.TTL3, 'Value')
        delay = zeros(recobj.sampf * recobj.TTL3.delay / 1000,1);
        size_pulseON = round(recobj.sampf / recobj.TTL3.Freq * recobj.TTL3.DutyCycle);
        pulseON = ones(size_pulseON, 1);
        size_pulseOFF = round(recobj.sampf / recobj.TTL3.Freq * (1 - recobj.TTL3.DutyCycle));
        pulseOFF = zeros(size_pulseOFF, 1);
        pulse = repmat([pulseON;pulseOFF], str2double(get(figUIobj.pulsenumTTL3, 'string')),1);
        recobj.TTL3AO = [delay; pulse; zeros(recobj.recp-size(delay, 2) - size(pulse, 2), 1)];
        recobj.TTL3AO = zeros(recobj.recp, 1);
        recobj.TTL3AO(1:size([delay;pulse], 1), 1) = [delay; pulse];
    end
    
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% IMAQ Camera %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if SetCam == 1
    imaq = imaq_ini(recobj);
    %imaq.vid.FramesPerTrigger = (recobj.rect/1000 * imaq.frame_rate)-10; 
end

%% figures
if isfield(plotUIobj, 'plot')
    switch get(figUIobj.plot, 'Value') %V-plot or I-plot
        case 0
            col = 'b';
        case 1
            col = 'r';
    end
    set(plotUIobj.plot1, 'Color', col);
end

%% check vars

end



%% %%%%%%%%%%%%%%%%%%%%   subfunctions   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function centerXY_list= get_stim_center_mat(RECT, divnum)
RECT_x = RECT(3) - RECT(1);
RECT_y = RECT(4) - RECT(2);

step_x = RECT_x / divnum;
step_y = RECT_y / divnum;

center_div = floor([RECT(1) + step_x/2 : step_x : RECT(3) - step_x/2;...
    RECT(2) + step_y/2 : step_y : RECT(4) - step_y/2]);

centerXY_list = zeros(divnum^2, 2);

for m = 1:divnum
    centerXY_list(divnum*(m-1)+1:divnum*m, 1) = center_div(1, m);
    centerXY_list((1:divnum:divnum^2)+(m-1), 2) = center_div(2, m);
end

end

%%
function [dist_list, angle_list, conc_mat, conc_mat_deg] = get_concentric_position(n)
% example
% [sobj.concentric_dist_deg_list, sobj.concentric_angle_deg_list,
% sobj.concentric_mat, sobj.concentric_mat_deg] =
% get_concentric_position(1)


global sobj
global figUIobj
%% Concentric positions
if n == 1
shiftDir = get(figUIobj.shiftDir, 'Value');
sobj.shiftDir = shiftDir;
elseif n == 2
shiftDir = get(figUIobj.shiftDir2, 'Value');
sobj.shiftDir2 = shiftDir;
end

% chekc_concentric_position
% Max distance = sobj.dist
% number of division = sobj.div_zoom
dist_list = (sobj.dist/sobj.div_zoom) : (sobj.dist/sobj.div_zoom) : sobj.dist; % for save
conc_dist_pix_list = Deg2Pix(dist_list, sobj.MonitorDist, sobj.pixpitch);

if shiftDir < 9
    % when angle is fixed
    prep_mat = [[0,1:sobj.div_zoom]; [0, shiftDir * ones(1, sobj.div_zoom)]];
    angle_list = linspace(0, 315, 8);
    conc_angle_rad_list = linspace(0, 2 * pi - 2 * pi/8, 8);
    num_directions = shiftDir;
else
    if shiftDir < 11
        % when angle is random or ordered
        num_directions = 8;
    elseif shiftDir == 11
        num_directions = 16;
    elseif shiftDir == 12
        num_directions = 12;
    end
    % 8, 16, 12 directions and center (: +1)
    prep_mat = zeros(2,sobj.div_zoom*num_directions + 1);
    for i_div = 1:sobj.div_zoom
        prep_mat(1,num_directions*(i_div-1)+2:num_directions*i_div+1) = i_div*ones(1,num_directions);
    end
    prep_mat( 2,:) = [0,repmat(1:num_directions, 1,sobj.div_zoom)];
    angle_list = 0: 360/num_directions: 360-360/num_directions;
    conc_angle_rad_list = 0: 2*pi/num_directions: 2*pi-2*pi/num_directions;
end

% for BW:Black/White concentric mapping (position + color)
% 1st: distance, 2nd: direction, 3rd: 1=white, 2=black
conc_mat = ones(size(prep_mat,2)*2, 3);
conc_mat(:, 1:2) = repmat(prep_mat', 2, 1);
conc_mat(1+size(conc_mat,1)/2:end, 3) = 2;

conc_mat_deg = conc_mat;

for n = sobj.div_zoom:-1:1
    %distance in pixel length
    conc_mat(conc_mat(:,1)==n, 1) = conc_dist_pix_list(n);
    conc_mat_deg(conc_mat_deg(:,1)==n, 1) = dist_list(n);
end

for n = 1:num_directions
    conc_mat(conc_mat(:,2)==n, 2) = conc_angle_rad_list(n);
    conc_mat_deg(conc_mat_deg(:,2)==n, 2) = angle_list(n);
end
end