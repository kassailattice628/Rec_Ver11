function reload_params(~, ~, Testmode, Recmode, SetCam)
% reload all paraemter and settings before start loop.
% 

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

global imaq

global DataSave
global ParamsSave

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

recobj.cycleNum = 0 - recobj.prestim;

recobj.prestim = re_write(figUIobj.prestimN);
set(figUIobj.prestim, 'string',['loops=',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)), 'sec']);

modelist = get(figUIobj.mode, 'string'); % {'Random', 'Fix_Rep', 'Ordered'};
sobj.mode = modelist{get(figUIobj.mode, 'value')};

% sobj.pattern is reloaded in ./Check_params/change_stim_pattern.m

%% stim 1
sobj.div_zoom = re_write(figUIobj.div_zoom);
sobj.dist = re_write(figUIobj.dist);

sobj.bgcol = re_write(figUIobj.bgcol);

sobj.shape = sobj.shapelist{get(figUIobj.shape, 'value'), 1};

sobj.stimlumi = re_write(figUIobj.stimlumi);
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

sobj.stimlumi_list = linspace(sobj.bgcol, sobj.stimlumi, 5)';

if strcmp(sobj.pattern, 'Looming')
    %stimu duration is automatically changes in Looming mode
else
    sobj.flipNum = re_write(figUIobj.flipNum);
    sobj.duration = sobj.flipNum*sobj.m_int;
end

sobj.delayPTBflip = re_write(figUIobj.delayPTBflip);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;

sobj.size_pix_list = repmat(round(Deg2Pix(sobj.stimsz_deg_list, sobj.MonitorDist, sobj.pixpitch)), 1, 2);

if get(figUIobj.auto_size, 'value') == 1
    %set(figUIobj.auto_size, 'value',0, 'string', 'Auto OFF')
else
    sobj.stimsz = getStimSize(sobj.MonitorDist, figUIobj.size, sobj.pixpitch);
end

%% Stim specific parameters.
switch sobj.pattern
    case {'Sin', 'Rect', 'Gabor', '1P_Conc', '2P_Conc', 'B/W'}
        %% Grating
        
        sobj.shiftDir = get(figUIobj.shiftDir, 'value');
        sobj.shiftSpd = sobj.shiftSpd_list(get(figUIobj.shiftSpd, 'value'));
        sobj.gratFreq = sobj.gratFreq_list(get(figUIobj.gratFreq, 'value'));
        
        if strcmp(sobj.pattern, 'Gabor')
            sobj.bgcol = sobj.gray;
        end
        
        %% Concentric positions
        
        sobj.shiftDir = get(figUIobj.shiftDir, 'value');
        
        % chekc_concentric_position
        % Max distance = sobj.dist
        % number of division = sobj.div_zoom
        sobj.concentric_dist_deg_list = (sobj.dist/sobj.div_zoom) : (sobj.dist/sobj.div_zoom) : sobj.dist; % for save
        conc_dist_pix_list = Deg2Pix(sobj.concentric_dist_deg_list, sobj.MonitorDist, sobj.pixpitch);
        
        if get(figUIobj.shiftDir, 'value') < 9
            % when angle is fixed
            prep_mat = [[0,1:sobj.div_zoom]; [0, get(figUIobj.shiftDir, 'value')*ones(1, sobj.div_zoom)]];
            sobj.concentric_angle_deg_list = linspace(0, 315, 8);
            conc_angle_rad_list = linspace(0, 2*pi- 2*pi/8, 8);
            num_directions = get(figUIobj.shiftDir, 'value');
        else
            if get(figUIobj.shiftDir, 'value') < 11
                % when angle is random or ordered
                num_directions = 8;
            else
                num_directions = 16;
            end
            % 8 or 16 directions and center (: +1)
            prep_mat = zeros(2,sobj.div_zoom*num_directions + 1);
            for i_div = 1:sobj.div_zoom
                prep_mat(1,num_directions*(i_div-1)+2:num_directions*i_div+1) = i_div*ones(1,num_directions);
            end
            prep_mat(2,:) = [0,repmat(1:num_directions, 1,sobj.div_zoom)];
            sobj.concentric_angle_deg_list = 0: 360/num_directions: 360-360/num_directions;
            conc_angle_rad_list = 0: 2*pi/num_directions: 2*pi-2*pi/num_directions;
        end
        
        % for BW:Black/White concentric mapping (position + color)
        % 1st: distance, 2nd: direction, 3rd: 1=white, 2=black
        sobj.concentric_mat = ones(size(prep_mat,2)*2, 3);
        sobj.concentric_mat(:, 1:2) = repmat(prep_mat', 2, 1);
        sobj.concentric_mat(1+size(sobj.concentric_mat,1)/2:end, 3) = 2;
        sobj.concentric_mat_deg = sobj.concentric_mat;
        for n = sobj.div_zoom:-1:1
            %distance in pixel length
            sobj.concentric_mat(sobj.concentric_mat(:,1)==n, 1) = conc_dist_pix_list(n);
            sobj.concentric_mat_deg(sobj.concentric_mat_deg(:,1)==n, 1) = sobj.concentric_dist_deg_list(n);
        end
        for n = 1:num_directions
            sobj.concentric_mat(sobj.concentric_mat(:,2)==n, 2) = conc_angle_rad_list(n);
            sobj.concentric_mat_deg(sobj.concentric_mat_deg(:,2)==n, 2) = sobj.concentric_angle_deg_list(n);
        end
        
        % Color
        if strcmp(sobj.pattern, 'B/W')
            sobj.bgcol = sobj.gray;
        end
        
        
    case 'Images'
        %% Select Image Set
        
        sobj.img_list = randperm(256);
        sobj.ImageNum = re_write(figUIobj.ImageNum);
        sobj.img_sublist = sobj.img_list(1:sobj.ImageNum)';
        
    case 'Mosaic'
        %% Multi dots
        
        rng('shuffle');
        sobj.int_seed = randperm(1000);
        
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
        %%  get small area for fine mapping
        FineMapArea_deg = [0, 0, sobj.dist, sobj.dist]; % deg
        FineMapArea = Deg2Pix(FineMapArea_deg, sobj.MonitorDist, sobj.pixpitch);
        
        % get center position in pixel
        center = sobj.center_pos_list(sobj.fixpos,:);
        
        % get corner positions in pixel
        RECT = CenterRectOnPointd(FineMapArea, center(1), center(2));
        
        sobj.center_pos_list_FineMap = get_stim_center_mat(RECT, sobj.div_zoom);
        
end

%% stim 2 
sobj.shape2 = sobj.shapelist{get(figUIobj.shape2, 'value'), 1};
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
    
    plotnum = get(figUIobj.plot, 'value')+1;
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
    if get(figUIobj.TTL3, 'value')
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
    frame_rate = 100;
    imaq.vid.FramesPerTrigger = (recobj.rect/1000 * frame_rate)-10;    
end

%% figures
if isfield(plotUIobj, 'plot')
    switch get(figUIobj.plot, 'value') %V-plot or I-plot
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





